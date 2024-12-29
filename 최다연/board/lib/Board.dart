class Board {
  final int id;
  final String title;
  final String contents;
  final int viewCount;

  Board({
    required this.id,
    required this.title,
    required this.contents,
    required this.viewCount,
  });

  factory Board.fromJson(Map<String, dynamic> json){
    return Board(
    id: json['id'], 
    title: json['title'], 
    contents: json['contents'],
    viewCount: json['viewCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'title' : title,
      'contents' : contents,
      'viewCount' : viewCount
    };
  }
}