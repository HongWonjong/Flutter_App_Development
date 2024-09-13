import 'package:flutter/material.dart';

class BrightnessContrastSaturationControl extends StatelessWidget {
  final String selectedProperty;
  final double brightnessValue;
  final double contrastValue;
  final double saturationValue;
  final ValueChanged<String> onPropertyChanged;
  final ValueChanged<double> onSliderChanged;


  const BrightnessContrastSaturationControl({
    Key? key,
    required this.selectedProperty,
    required this.brightnessValue,
    required this.contrastValue,
    required this.saturationValue,
    required this.onPropertyChanged,
    required this.onSliderChanged,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => onPropertyChanged('밝기'),
                style: TextButton.styleFrom(
                  backgroundColor: selectedProperty == '밝기'
                      ? Colors.deepPurpleAccent
                      : Colors.grey[800],
                ),
                child: Text(
                  '밝기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: selectedProperty == '밝기'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => onPropertyChanged('대조'),
                style: TextButton.styleFrom(
                  backgroundColor: selectedProperty == '대조'
                      ? Colors.deepPurpleAccent
                      : Colors.grey[800],
                ),
                child: Text(
                  '대조',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: selectedProperty == '대조'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => onPropertyChanged('채도'),
                style: TextButton.styleFrom(
                  backgroundColor: selectedProperty == '채도'
                      ? Colors.deepPurpleAccent
                      : Colors.grey[800],
                ),
                child: Text(
                  '채도',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: selectedProperty == '채도'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _getSliderValue(),
            min: _getSliderMin(),
            max: _getSliderMax(),
            divisions: 30,
            label: _getSliderValue().toStringAsFixed(2),
            onChanged: (value) {
              onSliderChanged(value);
            },
          ),
        ],
      ),
    );
  }

  double _getSliderValue() {
    if (selectedProperty == '밝기') {
      return brightnessValue;
    } else if (selectedProperty == '대조') {
      return contrastValue;
    } else {
      return saturationValue;
    }
  }

  double _getSliderMin() {
    if (selectedProperty == '대조') {
      return 0.0;
    } else if (selectedProperty == '채도') {
      return 0.0;
    } else {
      return -1.0;
    }
  }

  double _getSliderMax() {
    if (selectedProperty == '대조') {
      return 1.0;
    } else {
      return 2.0;
    }
  }
}


