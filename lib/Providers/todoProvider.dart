import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:maids_todo_app/models/CardModel.dart';
import 'package:http/http.dart' as http;
import 'package:maids_todo_app/models/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoProvider extends ChangeNotifier {
  List<CardModel> taskes = [];
  List<CardModel> filteredList = [];
  String? _accessToken;
  String? _refreshToken;
  UserModel? user;
  static const int pageSize = 10;
  final PagingController<int, CardModel> pagingController =
      PagingController(firstPageKey: 0);

  TodoProvider() {
    filteredList = taskes;
    _loadTokens();
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> _refreshTokenIfNeeded() async {
    if (_refreshToken == null) return;

    String refreshUrl = 'https://dummyjson.com/auth/refresh';
    final response = await http.post(
      Uri.parse(refreshUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': _refreshToken}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      _accessToken = json['token'];
      _refreshToken = json['refreshToken'];
      await _saveTokens(_accessToken!, _refreshToken!);
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  Future<void> fetchPage(int pageKey) async {
    log("page key: " +
        pageKey.toString() +
        "page size: " +
        pageSize.toString());
    try {
      String url =
          'https://dummyjson.com/todos/user/${user?.id}?limit=$pageSize&skip=$pageKey';
      final response = await _authenticatedGet(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> todosJson = data['todos'];
        final List<CardModel> newItems =
            todosJson.map((json) => CardModel.fromMap(json)).toList();

        final isLastPage = newItems.length < pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + newItems.length;
          pagingController.appendPage(newItems, nextPageKey);
        }
        taskes.addAll(newItems);
        filteredList = taskes;
      } else {
        throw Exception('Failed to fetch todos');
      }
    } catch (e) {
      pagingController.error = e;
    }
  }

  Future<http.Response> _authenticatedGet(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 401) {
      await _refreshTokenIfNeeded();
      return await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
      );
    }

    return response;
  }

  taskTrigger(int id) async {
    log(taskes.toString());
    for (int i = 0; i < pagingController.itemList!.length; i++) {
      log("from id: " + id.toString());

      if (id == pagingController.itemList?[i].id) {
        log(pagingController.itemList![i].id.toString());
        taskes[i].completed = !taskes[i].completed;
        pagingController.itemList?[i].completed = taskes[i].completed;
        notifyListeners();
        try {
          Map<String, dynamic> requestBody = {
            'completed': taskes[i].completed,
          };
          final response = await http.put(
            Uri.parse('https://dummyjson.com/todos/$id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          );
          if (response.statusCode == 200) {
            print('Todo with ID $id updated successfully');
          } else {
            throw Exception('Failed to update todo status');
          }
          filteredList = taskes;
          break;
        } catch (error) {
          print(error);
        }
      }
    }
  }

  addTask(CardModel task) async {
    if (task.todo.isEmpty) {
      throw Exception("Todo cannot be empty");
    }
    if (task.userId <= 0) {
      throw Exception("Invalid user ID");
    }

    final url = Uri.parse('https://dummyjson.com/todos/add');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: task.toJson(),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        pagingController.itemList?.add(CardModel.fromMap(jsonResponse));
        notifyListeners();
      } else {
        log(response.body);
      }
    } catch (e) {
      throw Exception(e);
    }

    taskes.add(task);
    filteredList = taskes;
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://dummyjson.com/todos/$id'),
      );
      log(response.statusCode.toString());
      if (response.statusCode == 200) {

        pagingController.itemList?.removeWhere((task) => task.id == id);
        filteredList.removeWhere((task) => task.id == id);
        taskes.removeWhere((task) => task.id == id);
        log(pagingController.itemList.toString());
        notifyListeners();
        // pagingController.refresh();
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (error) {
      print(error);
    }
  }

  searchTask(String todo) {
    log(todo);
    final filteredData;
    if (todo != "") {
      filteredData = filteredList
          .where((task) => task.todo.toLowerCase().contains(todo))
          .toList();
    } else {
      filteredData = filteredList;
    }
    log(filteredData.length.toString());
    pagingController.itemList = filteredData;
    notifyListeners();
  }

  signIn(Map map) async {
    String loginUrl = 'https://dummyjson.com/auth/login';
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(map),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      _accessToken = json['token'];
      _refreshToken = json['refreshToken'];
      user = UserModel.fromMap(json);
      await _saveTokens(_accessToken!, _refreshToken!);
      // getAllTodos(json['id']);
      return 200;
    } else {
      throw Exception('Failed to login');
    }
  }

  logout() {
    _accessToken = "";
    _refreshToken = "";
    _clearTokens();
  }

  getAllTodos(int id) async {
    String todosUrl = 'https://dummyjson.com/todos/user/$id';
    final response = await _authenticatedGet(todosUrl);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> todosJson = data['todos'];
      taskes = todosJson.map((json) => CardModel.fromMap(json)).toList();
      filteredList = taskes;
      notifyListeners();
      return 200;
    } else {
      throw Exception('Failed to fetch todos');
    }
  }
}
