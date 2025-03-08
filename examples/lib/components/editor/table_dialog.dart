import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/memo_element.dart';
import '../../models/app_theme.dart';

class TableDialog extends StatefulWidget {
  final AppTheme theme;
  final Function(TableElement) onSave;
  final List<List<String>>? initialData;
  final int? initialRows;
  final int? initialColumns;

  const TableDialog({
    Key? key,
    required this.theme,
    required this.onSave,
    this.initialData,
    this.initialRows,
    this.initialColumns,
  }) : super(key: key);

  @override
  State<TableDialog> createState() => _TableDialogState();
}

class _TableDialogState extends State<TableDialog> {
  late int rows;
  late int columns;
  late List<List<TextEditingController>> controllers;

  @override
  void initState() {
    super.initState();
    // 초기값이 있으면 사용하고, 없으면 기본값으로 시작
    rows = widget.initialRows ?? 2;
    columns = widget.initialColumns ?? 2;

    // 컨트롤러 초기화
    controllers = List.generate(
      rows,
      (i) => List.generate(
        columns,
        (j) => TextEditingController(
          text: widget.initialData != null &&
                  i < widget.initialData!.length &&
                  j < widget.initialData![i].length
              ? widget.initialData![i][j]
              : '',
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _updateTableSize(int newRows, int newColumns) {
    final oldControllers = controllers;

    // 새로운 컨트롤러 배열 생성
    controllers = List.generate(
      newRows,
      (i) => List.generate(
        newColumns,
        (j) {
          // 기존 데이터가 있으면 유지
          if (i < oldControllers.length && j < oldControllers[i].length) {
            return oldControllers[i][j];
          }
          return TextEditingController();
        },
      ),
    );

    // 불필요한 컨트롤러 해제
    for (var i = 0; i < oldControllers.length; i++) {
      for (var j = 0; j < oldControllers[i].length; j++) {
        if (i >= newRows || j >= newColumns) {
          oldControllers[i][j].dispose();
        }
      }
    }

    setState(() {
      rows = newRows;
      columns = newColumns;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.theme.textColor;
    final backgroundColor = widget.theme.backgroundColor;

    return AlertDialog(
      backgroundColor: backgroundColor,
      title: Text('표', style: TextStyle(color: textColor)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('행:', style: TextStyle(color: textColor)),
                    Slider(
                      value: rows.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: rows.toString(),
                      onChanged: (value) {
                        _updateTableSize(value.toInt(), columns);
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('열:', style: TextStyle(color: textColor)),
                    Slider(
                      value: columns.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: columns.toString(),
                      onChanged: (value) {
                        _updateTableSize(rows, value.toInt());
                      },
                      activeColor: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(
                  color: textColor.withOpacity(0.3),
                  width: 1,
                ),
                children: List.generate(
                  rows,
                  (i) => TableRow(
                    children: List.generate(
                      columns,
                      (j) => Container(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          controller: controllers[i][j],
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: '셀 ${i + 1}-${j + 1}',
                            hintStyle: TextStyle(
                              color: textColor.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소', style: TextStyle(color: Colors.blue)),
        ),
        TextButton(
          onPressed: () {
            final data = List.generate(
              rows,
              (i) => List.generate(
                columns,
                (j) => controllers[i][j].text.trim(),
              ),
            );

            final tableElement = TableElement(
              id: const Uuid().v4(),
              data: data,
              rows: rows,
              columns: columns,
              xFactor: 0.1,
              yFactor: 0.3,
              width: columns * 100.0,
              height: rows * 50.0 + 40.0,
            );

            widget.onSave(tableElement);
            Navigator.pop(context);
          },
          child: Text('저장', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
