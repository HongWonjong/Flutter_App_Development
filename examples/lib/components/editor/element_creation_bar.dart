import 'package:flutter/material.dart';
import '../../models/app_theme.dart';

class ElementCreationBar extends StatelessWidget {
  final AppTheme theme;
  final Function() onImagePressed;
  final Function() onCodePressed;
  final Function() onLinkPressed;
  final Function() onTablePressed;
  final Function()? onChecklistPressed;
  final Function()? onListPressed;
  final Function()? onQuotePressed;
  final Function()? onDividerPressed;

  const ElementCreationBar({
    Key? key,
    required this.theme,
    required this.onImagePressed,
    required this.onCodePressed,
    required this.onLinkPressed,
    required this.onTablePressed,
    this.onChecklistPressed,
    this.onListPressed,
    this.onQuotePressed,
    this.onDividerPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = theme.textColor;
    final backgroundColor = theme.backgroundColor;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: textColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // 첫 번째 줄
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 8),
                _buildElementButton(
                  icon: Icons.image,
                  label: '이미지',
                  onPressed: onImagePressed,
                ),
                const SizedBox(width: 8),
                _buildElementButton(
                  icon: Icons.code,
                  label: '코드',
                  onPressed: onCodePressed,
                ),
                const SizedBox(width: 8),
                _buildElementButton(
                  icon: Icons.link,
                  label: '링크',
                  onPressed: onLinkPressed,
                ),
                const SizedBox(width: 8),
                _buildElementButton(
                  icon: Icons.grid_on,
                  label: '표',
                  onPressed: onTablePressed,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 두 번째 줄
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 8),
                _buildElementButton(
                  icon: Icons.check_box,
                  label: '체크리스트',
                  onPressed: onChecklistPressed ?? () {},
                ),
                const SizedBox(width: 8),
                _buildElementButton(
                  icon: Icons.format_list_bulleted,
                  label: '목록',
                  onPressed: onListPressed ?? () {},
                ),
                const SizedBox(width: 8),
                _buildElementButton(
                  icon: Icons.format_quote,
                  label: '인용구',
                  onPressed: onQuotePressed ?? () {},
                ),
                const SizedBox(width: 8),
                _buildElementButton(
                  icon: Icons.format_paint,
                  label: '구분선',
                  onPressed: onDividerPressed ?? () {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: theme.textColor),
      label: Text(
        label,
        style: TextStyle(color: theme.textColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.appBarColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
