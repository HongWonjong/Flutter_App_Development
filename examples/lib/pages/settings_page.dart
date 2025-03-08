import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/app_theme.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('앱 설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 테마 프리셋 선택 섹션
            const Text(
              '테마 프리셋',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 프리셋 테마 카드 - 첫 번째 행
            Row(
              children: [
                _buildThemePresetCard(
                  context: context,
                  title: '다크 모드',
                  color: AppTheme.fromPreset(ThemePreset.dark).backgroundColor,
                  appBarColor:
                      AppTheme.fromPreset(ThemePreset.dark).appBarColor,
                  isSelected: appTheme.preset == ThemePreset.dark,
                  onTap: () => themeNotifier.setPreset(ThemePreset.dark),
                ),
                _buildThemePresetCard(
                  context: context,
                  title: '라이트 모드',
                  color: AppTheme.fromPreset(ThemePreset.light).backgroundColor,
                  appBarColor:
                      AppTheme.fromPreset(ThemePreset.light).appBarColor,
                  isSelected: appTheme.preset == ThemePreset.light,
                  onTap: () => themeNotifier.setPreset(ThemePreset.light),
                ),
                _buildThemePresetCard(
                  context: context,
                  title: '네이처',
                  color:
                      AppTheme.fromPreset(ThemePreset.nature).backgroundColor,
                  appBarColor:
                      AppTheme.fromPreset(ThemePreset.nature).appBarColor,
                  isSelected: appTheme.preset == ThemePreset.nature,
                  onTap: () => themeNotifier.setPreset(ThemePreset.nature),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 프리셋 테마 카드 - 두 번째 행 (추가된 프리셋)
            Row(
              children: [
                _buildThemePresetCard(
                  context: context,
                  title: '엘레강트',
                  color:
                      AppTheme.fromPreset(ThemePreset.elegant).backgroundColor,
                  appBarColor:
                      AppTheme.fromPreset(ThemePreset.elegant).appBarColor,
                  isSelected: appTheme.preset == ThemePreset.elegant,
                  onTap: () => themeNotifier.setPreset(ThemePreset.elegant),
                ),
                _buildThemePresetCard(
                  context: context,
                  title: '선셋',
                  color:
                      AppTheme.fromPreset(ThemePreset.sunset).backgroundColor,
                  appBarColor:
                      AppTheme.fromPreset(ThemePreset.sunset).appBarColor,
                  isSelected: appTheme.preset == ThemePreset.sunset,
                  onTap: () => themeNotifier.setPreset(ThemePreset.sunset),
                ),
                _buildThemePresetCard(
                  context: context,
                  title: '오션',
                  color: AppTheme.fromPreset(ThemePreset.ocean).backgroundColor,
                  appBarColor:
                      AppTheme.fromPreset(ThemePreset.ocean).appBarColor,
                  isSelected: appTheme.preset == ThemePreset.ocean,
                  onTap: () => themeNotifier.setPreset(ThemePreset.ocean),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // 색상 커스터마이징 섹션
            const Text(
              '색상 커스터마이징',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 앱 바 색상 선택
            _buildColorSelector(
              context: context,
              title: '앱 바 색상',
              color: appTheme.appBarColor,
              onColorChanged: (color) => themeNotifier.updateAppBarColor(color),
              appTheme: appTheme,
            ),

            const SizedBox(height: 12),

            // 배경 색상 선택
            _buildColorSelector(
              context: context,
              title: '배경 색상',
              color: appTheme.backgroundColor,
              onColorChanged:
                  (color) => themeNotifier.updateBackgroundColor(color),
              appTheme: appTheme,
            ),

            const SizedBox(height: 12),

            // 텍스트 색상 선택
            _buildColorSelector(
              context: context,
              title: '글자 색상',
              color: appTheme.textColor,
              onColorChanged: (color) => themeNotifier.updateTextColor(color),
              appTheme: appTheme,
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // 설정 초기화 버튼
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('설정 초기화'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.appBarColor,
                  foregroundColor: _contrastColor(appTheme.appBarColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () => themeNotifier.setPreset(ThemePreset.light),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 배경색에 따른 대비 색상 선택 (텍스트 가독성을 위함)
  Color _contrastColor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  // 테마 프리셋 카드 위젯
  Widget _buildThemePresetCard({
    required BuildContext context,
    required String title,
    required Color color,
    required Color appBarColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? appBarColor : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: appBarColor.withOpacity(0.3),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ]
                    : null,
          ),
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 앱 바 미리보기
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: appBarColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color:
                      ThemeData.estimateBrightnessForColor(color) ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              // 선택 표시
              isSelected
                  ? Icon(Icons.check_circle, color: appBarColor, size: 18)
                  : const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  // 색상 선택기 위젯
  Widget _buildColorSelector({
    required BuildContext context,
    required String title,
    required Color color,
    required ValueChanged<Color> onColorChanged,
    required AppTheme appTheme,
  }) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(title)),
        Expanded(
          flex: 7,
          child: GestureDetector(
            onTap:
                () => _showColorPicker(
                  context: context,
                  color: color,
                  onColorChanged: onColorChanged,
                  appTheme: appTheme,
                ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  '탭하여 색상 선택',
                  style: TextStyle(
                    color:
                        ThemeData.estimateBrightnessForColor(color) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 색상 선택 다이얼로그 표시
  void _showColorPicker({
    required BuildContext context,
    required Color color,
    required ValueChanged<Color> onColorChanged,
    required AppTheme appTheme,
  }) {
    Color pickerColor = color;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (newColor) {
                pickerColor = newColor;
              },
              pickerAreaHeightPercent: 0.8,
              displayThumbColor: true,
              enableAlpha: false,
              showLabel: true,
              paletteType: PaletteType.hsvWithHue,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.pop(context);
              },
              // 앱 바 색상에 맞게 버튼 스타일 적용
              style: ElevatedButton.styleFrom(
                backgroundColor: appTheme.appBarColor,
                foregroundColor: _contrastColor(appTheme.appBarColor),
              ),
              child: const Text('선택'),
            ),
          ],
        );
      },
    );
  }
}
