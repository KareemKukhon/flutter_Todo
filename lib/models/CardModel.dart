import 'dart:convert';

class CardModel {
  int? id;
  int userId;
  String todo;
  bool completed;
  CardModel({
    this.id = 999,
    required this.userId,
    required this.todo,
    this.completed = false,
  });

  CardModel copyWith({
    int? id,
    int? userId,
    String? todo,
    bool? completed,
  }) {
    return CardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'todo': todo,
      'completed': completed,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id']?.toInt() ?? 0,
      userId: map['userId']?.toInt() ?? 0,
      todo: map['todo'] ?? '',
      completed: map['completed'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory CardModel.fromJson(String source) => CardModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CardModel(id: $id, userId: $userId, todo: $todo, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CardModel &&
      other.id == id &&
      other.userId == userId &&
      other.todo == todo &&
      other.completed == completed;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      todo.hashCode ^
      completed.hashCode;
  }
}
