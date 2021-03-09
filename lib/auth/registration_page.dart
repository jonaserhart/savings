import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class RegisterPage extends StatefulWidget {
  final String title = 'Register';
  final VoidCallback signInFunc;

  RegisterPage(this.signInFunc);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameConroller = TextEditingController();

  bool _success;
  String _userEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50, bottom: 40),
                child: Text('Create a new account',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter an email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _displayNameConroller,
                      decoration:
                          const InputDecoration(labelText: 'Display name'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      obscureText: true,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: OutlineButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {

                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(days: 2),
                                content: Row(
                                  children: [
                                    SizedBox(
                                      height: 40,
                                      child: SpinKitChasingDots(
                                        size: 30,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text('Performing changes..'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            try {
                              await _register();
                            }
                            catch (error) {
                              Scaffold.of(context).hideCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.message),
                                )
                              );
                            }
                            Scaffold.of(context).hideCurrentSnackBar();
                          }
                        },
                        borderSide: BorderSide(color: Colors.green),
                        child: Text('Register',
                            style: TextStyle(color: Colors.green)),
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: Text(_success == null
                            ? ''
                            : (_success
                                ? 'Successfully registered $_userEmail'
                                : 'Registration failed'))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.person,
                size: 200,
                color: Theme.of(context).backgroundColor,
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_auth.currentUser == null) {
      final User user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;
      if (user != null) {
        await user.updateProfile(displayName: _displayNameConroller.text);
        setState(() {
          _success = true;
          _userEmail = user.email;
        });
        widget.signInFunc();
        Navigator.of(context).pop();
      } else {
        setState(() {
          _success = false;
        });
      }
    } else {
      var credential = EmailAuthProvider.credential(
          email: _emailController.text, password: _passwordController.text);
      await _auth.currentUser.linkWithCredential(credential);
      await _auth.currentUser.updateProfile(displayName: _displayNameConroller.text);
      setState(() {
        _userEmail = _auth.currentUser.email;
        _success = true;
      });
      Navigator.of(context).pop();
      widget.signInFunc();
      setState(() {
        _success = false;
      });
    }
  }
}
