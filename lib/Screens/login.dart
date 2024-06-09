import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maids_todo_app/Providers/todoProvider.dart';
import 'package:maids_todo_app/Screens/MainPage.dart';
import 'package:maids_todo_app/Utils/customTextField.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 50, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      // color: Colors.green,
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: Color.fromRGBO(43, 47, 78, 1),
                            fontFamily: 'Portada ARA',
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              CircleAvatar(
                child: Image.asset("images/login.png"),
                radius: 90,
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomTextField(
                        text: 'Email',
                        controller: _emailController,
                        type: TextInputType.emailAddress,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: CustomTextField(
                            text: "Password", controller: passwordController),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_emailController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              Map<String, dynamic> map = {
                                "username": _emailController.text,
                                "password": passwordController.text,
                              };
                              int statusCode = await Provider.of<TodoProvider>(
                                      context,
                                      listen: false)
                                  .signIn(map);
                              //login logic
                              if (statusCode == 200) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MainPage();
                                    },
                                  ),
                                );
                                print("Login Successful");
                              } else if (statusCode == 401) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("الحساب غير موجود"),
                                ));
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontFamily: "Portada ARA",
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color.fromRGBO(19, 169, 179, 1)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ))),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
