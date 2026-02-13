import 'package:flutter/material.dart';
import 'package:phr/data/models/table_row_data.dart';

class TableEditor extends StatefulWidget {
  final List<String> columns;
  final List<TableRowData> rows;
  final VoidCallback onAddRow;
  final Function(int) onDeleteRow;
  final VoidCallback onAddColumn;
  final Function(String) onDeleteColumn;

  const TableEditor({
    super.key,
    required this.columns,
    required this.rows,
    required this.onAddRow,
    required this.onDeleteRow,
    required this.onAddColumn,
    required this.onDeleteColumn,
  });

  static const double cellWidth = 160;

  @override
  State<TableEditor> createState() => _TableEditorState();
}

class _TableEditorState extends State<TableEditor> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableWidth = widget.columns.length * TableEditor.cellWidth + 48;

    return Column(
      children: [
        _header(tableWidth),

        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalController,
            child: SizedBox(
              width: tableWidth,
              child: ListView.builder(
                itemCount: widget.rows.length,
                itemBuilder: (_, i) => _row(i, widget.rows[i]),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: widget.onAddRow,
                icon: const Icon(Icons.add),
                label: const Text("Add Row"),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: widget.onAddColumn,
                icon: const Icon(Icons.view_column),
                label: const Text("Add Column"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(double width) {
    return SizedBox(
      height: 42,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _horizontalController,
        child: SizedBox(
          width: width,
          child: Container(
            color: Colors.grey.shade200,
            child: Row(
              children: [
                for (final col in widget.columns)
                  _HeaderCell(
                    text: col,
                    onDelete: () => widget.onDeleteColumn(col),
                  ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(int index, TableRowData row) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          for (final col in widget.columns)
            _cell(
              value: row.cells[col] ?? '',
              onChanged: (v) => row.cells[col] = v,
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: () => widget.onDeleteRow(index),
          ),
        ],
      ),
    );
  }

  Widget _cell({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      width: TableEditor.cellWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;

  const _HeaderCell({required this.text, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: TableEditor.cellWidth,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade400)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 14, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
