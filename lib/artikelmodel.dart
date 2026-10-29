class Artickel{
  final String title;
  final String? description;
  final String? urlToImage;

  Artickel({
    required this.title,
    this.description,
    this.urlToImage
  });

  factory Artickel.fromJson(Map<String, dynamic> json){
    return Artickel(
      title: json['title'] ?? "Judul Tidak Tersedia",
      description: json['description'] as String?,
      urlToImage: json['urlToImage'] as String?
      );
  }
}