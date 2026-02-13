class TableRowData {
  Map<String, String> cells;

  TableRowData({Map<String, String>? cells}) : cells = cells ?? {};

  Map<String, dynamic> toMap() => {'cells': cells};

  factory TableRowData.fromMap(Map<String, dynamic> map) {
    return TableRowData(cells: Map<String, String>.from(map['cells'] ?? {}));
  }
}
