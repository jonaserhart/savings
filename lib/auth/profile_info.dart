import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:savings/FirebaseStorageProvider.dart';
import 'package:savings/Storage.dart';
import 'package:savings/auth/password_modal.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class ProfileInfo extends StatefulWidget {
  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  bool _editEnabled;
  String _currentEmail;
  String _currentDisplayName;
  String _currentCurrency;

  var _storageProvider = Storage.getProvider();
  var _key = GlobalKey<FormState>();
  TextEditingController _displayNameController =
      TextEditingController(text: _auth.currentUser.displayName);
  TextEditingController _emailController =
      TextEditingController(text: _auth.currentUser.email);
  TextEditingController _currencyController = TextEditingController();

  @override
  void initState() {
    _editEnabled = false;
    _currentEmail = _auth.currentUser.email;
    _currentDisplayName = _auth.currentUser.displayName;
    _storageProvider.getCurrency().then((value) {
      if (value != null) {
        _currencyController.text = value.toString();
        _currentCurrency = value.toString();
      }
    });

    super.initState();
  }

  void updateDisplayName() async {
    await _auth.currentUser
        .updateProfile(displayName: _displayNameController.text);
    _currentDisplayName = _displayNameController.text;
  }

  void updateEmail() async {
    await _auth.currentUser.updateEmail(_emailController.text);
    _currentEmail = _emailController.text;
  }

  void onPasswordCorrect(User user) async {
    ScaffoldMessenger.of(context).showSnackBar(
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
    if (_currentEmail != _emailController.text) {
      try {
        updateEmail();
      } catch (error) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
        ));
        return;
      }
    }
    if (_currentDisplayName != _displayNameController.text) {
      try {
        updateDisplayName();
      } catch (error) {
        print(error);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not set new display name')));
        return;
      }
    }

    if (_currentCurrency != _currencyController.text) {
      try {
        await  _storageProvider.setCurrency(_currencyController.text);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message))
        );
        return;
      }
    }
    setState(() {
      _editEnabled = false;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully updated info'))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: GestureDetector(
              onTap: () {
                if (!_editEnabled) return;
                print('clicked');
              },
              child: _auth.currentUser.photoURL == null
                  ? CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).accentColor,
                      child: Text(
                        _auth.currentUser.email.characters.first.toUpperCase(),
                        style: TextStyle(fontSize: 30),
                      ),
                    )
                  : CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(_auth.currentUser.photoURL),
                    ),
            ),
          ),
          TextFormField(
            controller: _displayNameController,
            enabled: (_editEnabled),
            decoration: InputDecoration(
              labelText: 'Display name',
            ),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Display name can not be empty';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            enabled: (_editEnabled),
            decoration: InputDecoration(
              labelText: 'Email',
            ),
            validator: (String value) {
              if (value.isEmpty) {
                return 'Email can not be empty';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _currencyController,
            enabled: (_editEnabled),
            decoration: InputDecoration(
              labelText: 'Currency',
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 120),
            child: _editEnabled
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OutlineButton(
                        borderSide: BorderSide(
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          if (_key.currentState.validate()) {
                            if (_emailController.text != _currentEmail) {
                              showDialog(
                                  context: context,
                                  builder: (_) => PasswordModal(
                                      onPasswordCorrect, (error) => {}));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
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
                              if (_currentCurrency !=
                                  _currencyController.text) {
                                  try {
                                    await _storageProvider.setCurrency(_currencyController.text);
                                  }
                                  catch (error) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error.message))
                                    );
                                    return;
                                  }
                              }
                              if (_currentDisplayName != _displayNameController.text) {
                                try {
                                  updateDisplayName();
                                }
                                catch (error) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error.message))
                                  );
                                  return;
                                }
                              }
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              setState(() {
                                _editEnabled = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Successfully updated info'))
                              );
                            }
                          }
                        },
                        child:
                            Text('Save', style: TextStyle(color: Colors.green)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: OutlineButton(
                          onPressed: () {
                            setState(() {
                              _editEnabled = false;
                              _key.currentState.reset();
                            });
                          },
                          borderSide: BorderSide(color: Colors.orange),
                          child: Text('Cancel',
                              style: TextStyle(color: Colors.orange)),
                        ),
                      ),
                    ],
                  )
                : OutlineButton(
                    onPressed: () {
                      setState(() {
                        _editEnabled = true;
                      });
                    },
                    child: Text('Edit'),
                  ),
          ),
        ],
      ),
    );
  }
}
