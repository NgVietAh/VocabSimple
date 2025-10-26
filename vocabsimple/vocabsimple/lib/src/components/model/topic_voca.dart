class TopicVoca {
  String topic;
  int topic_index;
  String name;
  String image;
  int length;
  int percent;

  TopicVoca(
    this.topic,
    this.topic_index,
    this.name,
    this.image,
    this.length,
    this.percent,
  );

  factory TopicVoca.fromMap(String key, Map<String, dynamic> data) {
    return TopicVoca(
      key,
      data["topic_index"] ?? 0,
      data["name"] ?? '',
      data["image"] ?? '',
      data["length"] ?? 0,
      data["percent"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "topic": topic,
      "index": topic_index,
      "name": name,
      "image": image,
      "length": length,
      "percent": percent,
    };
  }
}
