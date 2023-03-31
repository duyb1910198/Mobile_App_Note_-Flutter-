
class LoveImage {
  int?   id;
  String?   image;
  bool    isFavorite;
  LoveImage({this.id, this.image, this.isFavorite = false});

  LoveImage.fromJson( Map<String, dynamic> json)
    : id          = json["id"],
      image       = json["image"],
      isFavorite  = false;
}