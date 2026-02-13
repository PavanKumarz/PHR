class MedicalCardModel {
  final int? id;
  final String title;
  final String imagePath;
  final String date;

  MedicalCardModel({
    this.id,
    required this.title,
    required this.imagePath,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {"id": id, "title": title, "image_path": imagePath, "date": date};
  }

  factory MedicalCardModel.fromMap(Map<String, dynamic> map) {
    return MedicalCardModel(
      id: map["id"],
      title: map["title"],
      imagePath: map["image_path"],
      date: map["date"],
    );
  }
}
