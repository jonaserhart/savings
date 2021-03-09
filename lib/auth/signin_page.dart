import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SignInPage extends StatefulWidget {
  final String title = 'Sign in';
  final VoidCallback signInfunc;
  SignInPage(this.signInfunc);
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (BuildContext context) {
        return ListView(
          padding: const EdgeInsets.all(8),
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
                child: Text(
                  'Choose a method',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            _EmailPasswordForm(widget.signInfunc),
            _AnonymousSignInForm(),
          ],
        );
      }),
    );
  }
}

class _EmailPasswordForm extends StatefulWidget {
  final VoidCallback signInFunc;
  _EmailPasswordForm(this.signInFunc);

  @override
  __EmailPasswordFormState createState() => __EmailPasswordFormState();
}

class __EmailPasswordFormState extends State<_EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Sign in with email and password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Pease enter an email';
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
                  padding: const EdgeInsets.only(top: 16),
                  alignment: Alignment.center,
                  child: OutlineButton(
                      borderSide: BorderSide(color: Colors.blue),
                      child: Text(
                        'Sign in',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          await _signInWithEmailAndPassword();
                        }
                      }),
                ),
              ],
            )),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
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
              child: Text('Signing in..'),
            ),
          ],
        ),
      ),
    );
    try {
      var user = (await _auth.signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text))
          .user;
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('${user.email} signed in')));
      widget.signInFunc();
      Navigator.of(context).pop();
    } catch (error) {
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Email and password')),
      );
    }
  }
}

class _AnonymousSignInForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Sign in anonymously',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 16),
              alignment: Alignment.center,
              child: OutlineButton(
                  borderSide: BorderSide(color: Colors.blue),
                  child: Text(
                    'Sign in',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () async {
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
                                child: Text('Signing in..'),
                              ),
                            ],
                          ),
                        ),
                      );

                      try {
                        await _auth.signInAnonymously();
                        Scaffold.of(context).hideCurrentSnackBar();
                        Navigator.of(context).pop();
                      }
                      catch(error) {
                        Scaffold.of(context).hideCurrentSnackBar();
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.message)
                          ),
                        );
                      }

                    }
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
