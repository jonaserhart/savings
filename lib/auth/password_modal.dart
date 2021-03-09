

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class PasswordModal extends StatefulWidget {
  final void Function(User) onPasswordCorrect;
  final void Function(dynamic) onPasswordReject;
  PasswordModal(this.onPasswordCorrect, this.onPasswordReject);
  @override
  _PasswordModalState createState() => _PasswordModalState();
}

class _PasswordModalState extends State<PasswordModal> {
  var _passwordFormKey = GlobalKey<FormState>();
  var _passwordController = TextEditingController();

  @override
  void initState() {
    _passwordController.text = '';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save changes'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Please enter your password to perform changes'),
          Form(
              key: _passwordFormKey,
              child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  }
              )
          )
        ],
      ),
      actions: <Widget>[
        new OutlineButton(
          onPressed: () async {
            if (_passwordFormKey.currentState.validate()) {
              try {
                var email = _auth.currentUser.email;
                var user = (
                    await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: _passwordController.text)
                ).user;
                widget.onPasswordCorrect(user);
              }
              catch (error) {
                widget.onPasswordReject(error);
              }
              //close modal
              Navigator.of(context).pop();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
