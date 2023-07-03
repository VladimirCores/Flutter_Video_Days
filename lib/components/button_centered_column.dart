import 'package:flutter/material.dart';

typedef OnButtonClick = void Function();

class ButtonCenteredColumn extends StatelessWidget {
  const ButtonCenteredColumn({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final OnButtonClick onPressed;

  ButtonStyle getButtonStyle() =>
      ElevatedButton.styleFrom(backgroundColor: Colors.black.withAlpha(70), elevation: 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: getButtonStyle(),
              child: Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.white.withAlpha(80)),
              ),
            ),
          ],
        ),
        // _buildScreenText(_videoLink),
      ],
    );
  }
}
