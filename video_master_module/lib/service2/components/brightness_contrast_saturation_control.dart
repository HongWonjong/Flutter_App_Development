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
      padding: const EdgeInsets.all(16),
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
            // 속성별로 다른 divisions 값을 적용
            divisions: _getSliderDivisions(),
            label: _getSliderLabel(_getSliderValue()),
            onChanged: (value) {
              onSliderChanged(value);
            },
          ),
        ],
      ),
    );
  }

  // 슬라이더 값을 선택된 속성에 맞게 가져오는 함수
  double _getSliderValue() {
    if (selectedProperty == '밝기') {
      return brightnessValue;
    } else if (selectedProperty == '대조') {
      return contrastValue;
    } else {
      return saturationValue;
    }
  }

  // 각 속성에 따른 슬라이더의 최소값 설정
  double _getSliderMin() {
    if (selectedProperty == '대조') {
      return -1.0; // FFmpeg 대조 최소값 설정
    } else if (selectedProperty == '채도') {
      return 0.0;
    } else {
      return -1.0; // 밝기의 최소값은 -1.0
    }
  }

  // 각 속성에 따른 슬라이더의 최대값 설정
  double _getSliderMax() {
    if (selectedProperty == '밝기') {
      return 1.0; // 밝기의 최대값은 1.0으로 제한
    } else if (selectedProperty == '대조') {
      return 1.0; // FFmpeg 대조 최대값 설정
    } else {
      return 2.0; // 채도의 최대값은 2.0
    }
  }

  // 속성에 따른 divisions 값 반환
  int _getSliderDivisions() {
    if (selectedProperty == '밝기') {
      return 40; // 밝기 슬라이더는 소수점 두 자리까지
    } else if (selectedProperty == '대조') {
      return 20; // 대조 슬라이더는 소수점 첫째 자리까지
    } else {
      return 30; // 채도는 기본값
    }
  }

  // 슬라이더 레이블 형식을 속성별로 다르게 설정
  String _getSliderLabel(double value) {
    if (selectedProperty == '대조') {
      return value.toStringAsFixed(1); // 대조는 소수점 첫째 자리
    } else {
      return value.toStringAsFixed(2); // 밝기와 채도는 소수점 두 자리
    }
  }
}





