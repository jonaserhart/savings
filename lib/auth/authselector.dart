import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';

import './registration_page.dart';
import './signin_page.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class AuthSelector extends StatefulWidget {
  final VoidCallback signInFunc;
  AuthSelector(this.signInFunc);

  @override
  _AuthSelectorState createState() => _AuthSelectorState();
}

class _AuthSelectorState extends State<AuthSelector> {
  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeIn(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Register a new account',
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                        OutlineButton(
                          child: Text(
                            'Register',
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                          borderSide:
                              BorderSide(color: Theme.of(context).buttonColor),
                          onPressed: () => _pushPage(
                              context, RegisterPage(widget.signInFunc)),
                        ),
                      ],
                    )),
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Already a user?',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      OutlineButton(
                        child: Text(
                          'Sign in',
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                        borderSide:
                            BorderSide(color: Theme.of(context).buttonColor),
                        onPressed: () =>
                            _pushPage(context, SignInPage(widget.signInFunc)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child:
                      _auth.currentUser != null && _auth.currentUser.isAnonymous
                          ? Column(
                              children: <Widget>[
                                Text('Currently signed in anonimously:',
                                    style: TextStyle(fontSize: 18)),
                                Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(
                                      'user ID: ${_auth.currentUser.uid}',
                                      style: TextStyle(
                                          color: Colors.amber[800],
                                          fontSize: 15),
                                    ))
                              ],
                            )
                          : Text('currently not signed in'),
                ),
                OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text('Go back'))
              ],
            ),
          ),
        ),
        duration: Duration(milliseconds: 250),
      ),
    );
  }
}
