import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String usernameError;

  String username;
  String password;

  bool _loading = false;

  _login() {
    setState(() {
      _loading = true;
    });
    MyApp.api.login(username, password).then((_) {
      setState(() {
        Navigator.pushReplacement(
          context,
          platformPageRoute(
            builder: (context) => MainPage(),
          ),
        );
      });
    }).catchError((error) {
      setState(() {
        _loading = false;
      });
      String errorString = error;
      if (errorString.contains("No internet"))
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorString)));
      else
        usernameError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/loginBg.png"), fit: BoxFit.cover)),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: true,
            body: ModalProgressHUD(
              child: new Stack(
                children: <Widget>[
                  new BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: new Container(
                        decoration: new BoxDecoration(
                          color: Color(0x7F212121),
                        ),
                      )),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: new Column(
                          children: <Widget>[
                            new Image.asset("assets/banner_light.png",
                                width: size.width - 100, fit: BoxFit.scaleDown),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: new Text(
                                  "Safe Hunt makes hunting safer by ensuring that you know the locations of other hunters.",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(fontSize: 20)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: new Text(
                                  "It does this by displaying other hunters (approximate) locations on a familar, topographic, map and notifying you when you leave your designated hunting area.",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(fontSize: 20)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: new Text(
                                  "Additionally several DoC hunting blocks are built in, so it's easier than ever to keep track of your location.",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(fontSize: 20)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: new Text(
                                  "Please note that this app is not a substitute for safe hunting practices, this is merely a guide to help you be more aware of other hunters.",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(fontSize: 20)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: new Text(
                                  "In order to use Safe Hunt, you must login or sign up below.",
                                  textAlign: TextAlign.center,
                                  style: new TextStyle(fontSize: 20)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: TextField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: false,
                                    prefixIcon: Icon(Icons.alternate_email),
                                    labelText: "Email Address",
                                    hintText: "someone@example.com",
                                    errorText: usernameError,
                                    border: OutlineInputBorder()),
                                  onChanged: (content) => username = content
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: TextField(
                                decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: false,
                                    prefixIcon: Icon(Icons.remove_red_eye),
                                    labelText: "Password",
                                    hintText: "password",
                                    errorText: usernameError,
                                    border: OutlineInputBorder()),
                                obscureText: true,
                                onChanged: (content) => password = content,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                new FlatButton(
                                    onPressed: () => null,
                                    child: new Text("Register")),
                                new FlatButton(
                                    onPressed: null,
                                    child: new Text("Forgot Password")),
                                new FlatButton(
                                    onPressed: _login, child: new Text("Login"))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              inAsyncCall: _loading,
              opacity: 0.5,
              progressIndicator: PlatformCircularProgressIndicator(),
            )));
  }
}
