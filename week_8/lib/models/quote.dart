class Quote {
  final String text;
  final String author;

  const Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    final rawText = (json['content'] ?? json['q'] ?? json['text'] ?? '')
        .toString();
    final rawAuthor = (json['author'] ?? json['a'] ?? 'Unknown').toString();

    return Quote(
      text: rawText.isEmpty ? 'No quote available right now.' : rawText,
      author: rawAuthor.isEmpty ? 'Unknown' : rawAuthor,
    );
  }
}
