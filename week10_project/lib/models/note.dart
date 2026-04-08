class Note {
  final String id;
  String title;
  String content;
  String? imageUrl;
  DateTime noteDate;
  DateTime lastEdited;
  double imageHeight; // Store height for the image

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.noteDate,
    required this.lastEdited,
    this.imageHeight = 250.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'imageUrl': imageUrl,
    'noteDate': noteDate.toIso8601String(),
    'lastEdited': lastEdited.toIso8601String(),
    'imageHeight': imageHeight,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    imageUrl: json['imageUrl'],
    noteDate: DateTime.parse(json['noteDate'] ?? json['lastEdited']),
    lastEdited: DateTime.parse(json['lastEdited']),
    imageHeight: (json['imageHeight'] as num?)?.toDouble() ?? 250.0,
  );
}
