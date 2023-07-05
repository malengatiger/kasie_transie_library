class CounterBag {

  int? count;
  String? description;

  CounterBag(
      {required this.count,
      required this.description,});

  CounterBag.fromJson(Map data) {
    count = data['count'];
    description = data['description'];
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'count': count,
        'description': description,

      };
}
