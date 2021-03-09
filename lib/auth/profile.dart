import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:savings/auth/authselector.dart';
import 'package:savings/auth/profile_info.dart';
import 'package:savings/auth/profile_info_local.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool signedIn = false;

  @override
  void initState() {
    signedIn = _auth.currentUser != null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (!signedIn ||
            _auth.currentUser == null ||
            _auth.currentUser.isAnonymous)
        ? FadeIn(
            child: Scaffold(
              body: Builder(builder: (BuildContext context) {
                return ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          ProfileInfoLocal(),
                          OutlineButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => AuthSelector(() => {
                                        setState(() {
                                          signedIn = true;
                                        })
                                      })));
                            },
                            child: const Text(
                              'Sign in',
                              style: TextStyle(color: Colors.greenAccent),
                            ),
                            borderSide: BorderSide(color: Colors.greenAccent),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(30),
                            child: Text(
                              'If you sign in, your savings will be backed up in the cloud. \nIf you log in with another device, your savings will be restored',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            duration: Duration(milliseconds: 250),
          )
        : FadeIn(
            child: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  return ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(30),
                        child: Column(
                          children: [
                            ProfileInfo(),
                            OutlineButton(
                              onPressed: () async {
                                await _auth.signOut();
                                setState(() {
                                  signedIn = false;
                                });
                              },
                              child: const Text(
                                'Sign out',
                                style: TextStyle(color: Colors.red),
                              ),
                              borderSide: BorderSide(color: Colors.red),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            duration: Duration(milliseconds: 250),
          );
  }
}
