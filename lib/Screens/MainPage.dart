import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maids_todo_app/Providers/todoProvider.dart';
import 'package:maids_todo_app/Screens/login.dart';
import 'package:maids_todo_app/Utils/todoCard.dart';
import 'package:maids_todo_app/models/UserModel.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:maids_todo_app/models/CardModel.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class MainPage extends StatelessWidget {
  MainPage({super.key});
  TextEditingController taskController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    TodoProvider provider = Provider.of<TodoProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: taskController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(143, 229, 228, 231),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color.fromRGBO(19, 169, 179, 1),
            onPressed: () {
              if (taskController.text.isNotEmpty) {
                CardModel task = CardModel(
                  todo: taskController.text,
                  userId: 2,
                );
                Provider.of<TodoProvider>(context, listen: false).addTask(task);
                taskController.clear();
              }
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        ],
      ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(148, 38, 126, 148),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Container(),
            Text("Maids Todo App"),
            PopupMenuButton(
              color: Colors.white,
              child: CircleAvatar(
                backgroundImage: NetworkImage(provider.user!.image),
              ),
              itemBuilder: (context) => <PopupMenuEntry<SampleItem>>[
                PopupMenuItem<SampleItem>(
                  value: SampleItem.itemOne,
                  child: Text('Logout'),
                  onTap: () {
                    provider.logout();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => Login(),
                    ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(bottom: 100.h),
        child: Consumer<TodoProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.sizeOf(context).width,
                  child: TextField(
                    onChanged: (value) {
                      log(value);
                      Provider.of<TodoProvider>(context, listen: false)
                          .searchTask(value.toLowerCase());
                    },
                    decoration: InputDecoration(
                      hintText: 'search',
                      suffixIcon: Icon(
                        Icons.search,
                        color: Color.fromRGBO(202, 202, 202, 1),
                      ),
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 170, 170, 170),
                            width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromRGBO(22, 197, 209, 1), width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PagedListView<int, CardModel>(
                    pagingController: provider.pagingController,
                    builderDelegate: PagedChildBuilderDelegate<CardModel>(
                      itemBuilder: (context, item, index) => TodoCard(
                        isTaskCompleted: item.completed,
                        taskId: item.id!,
                        taskName: item.todo,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
