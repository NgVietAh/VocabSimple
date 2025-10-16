import 'package:firebase_database/firebase_database.dart';

class TopicVoca {
  String topic;
  int index;
  String name;
  String image;
  int length;
  int percent;

  TopicVoca(
    this.topic,
    this.index,
    this.name,
    this.image,
    this.length,
    this.percent,
  );

  // Dùng khi lấy dữ liệu bằng snapshot
  TopicVoca.fromSnapshot(DataSnapshot snapshot)
      : topic = snapshot.key ?? '',
        index = (snapshot.value as Map)["index"] ?? 0,
        name = (snapshot.value as Map)["name"] ?? '',
        image = (snapshot.value as Map)["image"] ?? '',
        length = (snapshot.value as Map)["length"] ?? 0,
        percent = (snapshot.value as Map)["percent"] ?? 0;

  // Dùng khi lấy dữ liệu bằng .get() hoặc .once()
  factory TopicVoca.fromMap(String key, Map data) {
    return TopicVoca(
      key,
      data["index"] ?? 0,
      data["name"] ?? '',
      data["image"] ?? '',
      data["length"] ?? 0,
      data["percent"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "topic": topic,
      "index": index,
      "name": name,
      "image": image,
      "length": length,
      "percent": percent,
    };
  }
}
