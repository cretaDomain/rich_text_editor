import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showEditableHexColorPicker({
  required BuildContext context,
  required String title,
  required Color initialColor,
  required ValueChanged<Color> onColorChanged,
}) {
  final TextEditingController hexController =
      TextEditingController(text: _colorToHex(initialColor));
  Color currentColor = initialColor;
  String? errorText;

  Future<void> closeDialog() async {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          void updateColor(Color color) {
            currentColor = color;
            hexController.value = TextEditingValue(
              text: _colorToHex(color),
              selection: TextSelection.collapsed(offset: hexController.text.length),
            );
            errorText = null;
            setStateDialog(() {});
            onColorChanged(color);
          }

          void onHexChanged(String value) {
            final sanitized = value.replaceAll('#', '');
            if (sanitized.isEmpty) {
              errorText = null;
              setStateDialog(() {});
              return;
            }

            if (sanitized.length < 6) {
              errorText = null;
              setStateDialog(() {});
              return;
            }

            final Color? parsed = _tryParseHexColor(sanitized);
            if (parsed != null) {
              updateColor(parsed);
            } else {
              errorText = 'Invalid hexadecimal value.';
              setStateDialog(() {});
            }
          }

          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ColorPicker(
                    color: currentColor,
                    onColorChanged: updateColor,
                    enableOpacity: true,
                    pickersEnabled: const <ColorPickerType, bool>{
                      ColorPickerType.both: false,
                      ColorPickerType.primary: true,
                      ColorPickerType.accent: true,
                      ColorPickerType.wheel: true,
                    },
                    width: 40,
                    height: 40,
                    borderRadius: 12,
                    showColorCode: true,
                    colorCodeHasColor: true,
                    colorCodeReadOnly: false,
                    colorCodePrefixStyle: const TextStyle(fontSize: 12),
                    colorCodeTextStyle: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: hexController,
                    decoration: InputDecoration(
                      labelText: 'Hex',
                      prefixText: '#',
                      counterText: '',
                      errorText: errorText,
                    ),
                    maxLength: 8,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    onEditingComplete: () => onHexChanged(hexController.text),
                    //onChanged: onHexChanged,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Please enter an 8-digit or 6-digit hexadecimal value including Alpha',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: closeDialog,
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  ).whenComplete(hexController.dispose);
}

String _colorToHex(Color color) {
  final alpha = _channelToHex(color.a);
  final red = _channelToHex(color.r);
  final green = _channelToHex(color.g);
  final blue = _channelToHex(color.b);
  return '$alpha$red$green$blue';
}

Color? _tryParseHexColor(String input) {
  final sanitized = input.toUpperCase();
  if (sanitized.length != 6 && sanitized.length != 8) {
    return null;
  }

  final hexWithAlpha = sanitized.length == 6 ? 'FF$sanitized' : sanitized;

  try {
    final alpha = int.parse(hexWithAlpha.substring(0, 2), radix: 16);
    final red = int.parse(hexWithAlpha.substring(2, 4), radix: 16);
    final green = int.parse(hexWithAlpha.substring(4, 6), radix: 16);
    final blue = int.parse(hexWithAlpha.substring(6, 8), radix: 16);
    return Color.fromARGB(alpha, red, green, blue);
  } catch (_) {
    return null;
  }
}

String _channelToHex(double channel) {
  final intValue = (channel.clamp(0.0, 1.0) * 255).round().clamp(0, 255);
  return intValue.toRadixString(16).padLeft(2, '0').toUpperCase();
}
