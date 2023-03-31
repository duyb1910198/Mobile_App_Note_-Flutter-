
class Note {
  final int id;
  String? content;
  List<String>? images;
  String? labelImages;
  int? backgroundColor;
  String? backgroundImage;
  List<int>? label;
  bool pin;

  Note(
      {required this.id,
      this.content,
      this.images,
      this.labelImages = '',
      this.backgroundColor,
      this.backgroundImage,
      this.label,
      this.pin = false});

  Note.fromJson( Map<String, dynamic> json) :
      id               = json['id'],
      content          = json['content'],
      images           = json['images'].cast<String>(),
      labelImages      = json['labelImages'],
      backgroundColor  = json['backgroundColor'],
      backgroundImage  = json['backgroundImage'],
      label            = json['label'].cast<int>(), // convert from list dynamic to list int
      pin         = json['pin'];

  Map<String,dynamic> toJson() => {
    'id'              : id,
    'content'         :content,
    'images'          :images,
    'labelImages'     :labelImages,
    'backgroundColor' :backgroundColor,
    'backgroundImage' :backgroundImage,
    'label'           :label,
    'pin'        :pin
  };

  isVaild({required Note note}) {
    print('isVaild founction:');
    print('isVaild founction: note id is ${note.id}');
    print('isVaild founction: note images is empty is ${note.images!.isEmpty}');
    print('isVaild founction: note content is empty is ${note.content!.isEmpty}');
    print('isVaild founction: note condition is ${note.images!.isEmpty && note.content!.isEmpty}');
    if ( note.images!.isEmpty && note.content!.isEmpty) {
      return false;
    }
    return true;
  }


}
