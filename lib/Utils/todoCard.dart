import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:maids_todo_app/Providers/todoProvider.dart';
import 'package:provider/provider.dart';

class TodoCard extends StatelessWidget {
  TodoCard(
      {required this.isTaskCompleted,
      required this.taskId,
      required this.taskName,
      super.key});
  String taskName;
  bool isTaskCompleted;
  int taskId;
  // void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Slidable(
        endActionPane: ActionPane(motion: StretchMotion(), children: [
          SlidableAction(
            onPressed: (context) {
              Provider.of<TodoProvider>(context, listen: false)
                  .deleteTask(taskId);
            },
            icon: (Icons.delete),
            borderRadius: BorderRadius.circular(15),
            backgroundColor: Color(0xFFF75555),
          )
        ]),
        child: GestureDetector(
          onTap: () {
            Provider.of<TodoProvider>(context, listen: false)
                .taskTrigger(taskId);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: isTaskCompleted
                  ? Color.fromRGBO(19, 168, 179, 0.082)
                  : Colors.white,
              border: Border.all(
                color: Color.fromRGBO(22, 197, 209, 1),
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(taskName)),
                Checkbox(
                  value: isTaskCompleted,
                  activeColor: Color.fromRGBO(22, 197, 209, 1),
                  checkColor: Colors.white,
                  onChanged: (value) {
                    Provider.of<TodoProvider>(context, listen: false)
                        .taskTrigger(taskId);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
