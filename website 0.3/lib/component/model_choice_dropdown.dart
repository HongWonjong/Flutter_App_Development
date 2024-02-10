// dropdown_widget.dart

import 'package:flutter/material.dart';
import 'package:website/style/language.dart';

class CustomDropdown extends StatelessWidget {
  final String selectedModel;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    Key? key,
    required this.selectedModel,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: DropdownButton<String>(
        value: selectedModel,
        onChanged: onChanged,
        items: <String>[MainPageLan.modelNameGemini, MainPageLan.modelNameGpt35, /*MainPageLan.modelNameGpt4*/]
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}

