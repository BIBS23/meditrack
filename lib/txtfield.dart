import 'package:flutter/material.dart';

class TxtField extends StatelessWidget {
  final TextEditingController mycontroller;
  final String mylabel;
  final TextInputType type;
  final int maxlines;
  final TextInputAction? textInputAction;

  const TxtField({
    super.key,
    required this.mycontroller,
    required this.type,
    required this.mylabel,
    required this.maxlines,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: TextField(
          textCapitalization: TextCapitalization.sentences,
          maxLines: maxlines,
          keyboardType: type,
          controller: mycontroller,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            labelStyle: TextStyle(),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            hintText: mylabel,
          ),
        ),
      ),
    );
  }
}