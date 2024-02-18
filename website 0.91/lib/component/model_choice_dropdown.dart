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
    final Map<String, String> modelDescriptions = {
      MainPageLan.modelNameGemini: MainPageLan.toolTipGemini,
      MainPageLan.modelNameGpt35: MainPageLan.toolTipGpt35,
      MainPageLan.modelNameGpt4: MainPageLan.toolTipGpt4,
      MainPageLan.modelNamePalm: MainPageLan.toolTipPalm,
      MainPageLan.modelNameFb: MainPageLan.toolTipFb,
    };

    return SizedBox(
      child: DropdownButton<String>(
        value: selectedModel,
        onChanged: onChanged,
        items: modelDescriptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            // Wrap the Text widget with Tooltip
            child: Tooltip(
              // Custom tooltip position
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(8),
              verticalOffset: 20,
              preferBelow: false,
              message: entry.value,
              child: Transform.translate(
                offset: const Offset(24, 0), // Adjust the offset as needed
                child: Text(entry.key),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
