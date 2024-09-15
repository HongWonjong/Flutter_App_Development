List<double> calculateColorMatrix(double brightness, double contrast, double saturation) {
  // 값 제한 (기본값 0, 범위 -1 ~ 1) // 커스텀 필터를 사용해서 모든 범위를 통일함.
  brightness = brightness.clamp(-1, 1);
  contrast = contrast.clamp(-1, 1);
  saturation = saturation.clamp(-1, 1);

  // 1. 밝기 매트릭스
  final List<double> brightnessMatrix = [
    1, 0, 0, 0, brightness * 255, // Red
    0, 1, 0, 0, brightness * 255, // Green
    0, 0, 1, 0, brightness * 255, // Blue
    0, 0, 0, 1, 0                // Alpha
  ];

  // 2. 대비 매트릭스
  final List<double> contrastMatrix = [
    contrast + 1, 0, 0, 0, 128 * (1 - (contrast + 1)), // Red
    0, contrast + 1, 0, 0, 128 * (1 - (contrast + 1)), // Green
    0, 0, contrast + 1, 0, 128 * (1 - (contrast + 1)), // Blue
    0, 0, 0, 1, 0                                  // Alpha
  ];

  // 3. 채도 매트릭스
  final List<double> saturationMatrix = [
    0.213 + 0.787 * saturation, 0.715 - 0.715 * saturation, 0.072 - 0.072 * saturation, 0, 0,
    0.213 - 0.213 * saturation, 0.715 + 0.285 * saturation, 0.072 - 0.072 * saturation, 0, 0,
    0.213 - 0.213 * saturation, 0.715 - 0.715 * saturation, 0.072 + 0.928 * saturation, 0, 0,
    0, 0, 0, 1, 0
  ];

  // 4. 매트릭스 결합 (밝기 -> 대비 -> 채도 순서로 적용)
  return _multiplyColorMatrix(
    _multiplyColorMatrix(brightnessMatrix, contrastMatrix),
    saturationMatrix,
  );
}

// 단위 행렬 반환 (필터가 적용되지 않을 때)
List<double> _identityMatrix() {
  return [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0
  ];
}

// 두 매트릭스를 곱하는 함수 (행렬 곱)
List<double> _multiplyColorMatrix(List<double> a, List<double> b) {
  List<double> result = List.filled(20, 0);
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 5; j++) {
      result[i * 5 + j] =
          a[i * 5 + 0] * b[0 * 5 + j] +
              a[i * 5 + 1] * b[1 * 5 + j] +
              a[i * 5 + 2] * b[2 * 5 + j] +
              a[i * 5 + 3] * b[3 * 5 + j];
      if (j == 4) {
        result[i * 5 + j] += a[i * 5 + 4];
      }
    }
  }
  return result;
}

// FFmpeg 필터로 변환
String convertMatrixToFFmpegFilter(List<double> matrix) {
  return 'colorchannelmixer='
      'rr=${matrix[0]}:rg=${matrix[1]}:rb=${matrix[2]}:ra=${matrix[3]}:'
      'gr=${matrix[5]}:gg=${matrix[6]}:gb=${matrix[7]}:ga=${matrix[8]}:'
      'br=${matrix[10]}:bg=${matrix[11]}:bb=${matrix[12]}:ba=${matrix[13]}:'
      'ar=${matrix[15]}:ag=${matrix[16]}:ab=${matrix[17]}:aa=${matrix[18]}';
}








