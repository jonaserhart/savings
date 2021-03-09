import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:savings/Storage.dart';

class ProfileInfoLocal extends StatefulWidget {
  @override
  _ProfileInfoLocalState createState() => _ProfileInfoLocalState();
}

class _ProfileInfoLocalState extends State<ProfileInfoLocal> {
  bool _editEnabled;
  String _currentDisplayName;
  String _currentCurrency;

  var _storageProvider = Storage.getProvider();
  var _key = GlobalKey<FormState>();
  TextEditingController _displayNameController = TextEditingController(text: '');
  TextEditingController _currencyController = TextEditingController(text: '');

  @override
  void initState() {
    _editEnabled = false;
    _storageProvider.getCurrency().then((value) {
      if (value != null) {
        _currencyController.text = value.toString();
        _currentCurrency = value.toString();
      }
    });
    _storageProvider.getDisplayName().then((value) {
      _displayNameController.text = value;
      _currentDisplayName = value;
    });

    super.initState();
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
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).accentColor,
                  child: Text(
                    _currentDisplayName == null || _currentDisplayName.isEmpty ? 'U' : _currentDisplayName?.characters?.first?.toUpperCase() ?? 'U',
                    style: TextStyle(fontSize: 30),
                  ),
                )),
          ),
          TextFormField(
            controller: _displayNameController,
            enabled: (_editEnabled),
            decoration: InputDecoration(
              labelText: 'Display name',
            ),
          ),
          TextFormField(
            controller: _currencyController,
            enabled: (_editEnabled),
            decoration: InputDecoration(
              labelText: 'Currency',
            ),
            validator: (value) {
              if (value.length > 3) {
                return 'Please enter a maximum of three characters (EUR, \$, ...)';
              }
              return null;
            },
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
                            if (_currentCurrency != _currencyController.text) {
                              try {
                                await _storageProvider
                                    .setCurrency(_currencyController.text);
                              } catch (error) {
                                Scaffold.of(context)
                                    .hideCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(content: Text(error.message)));
                                return;
                              }
                            }
                            if (_currentDisplayName !=
                                _displayNameController.text) {
                              try {
                                await _storageProvider.setDisplayName(_displayNameController.text);
                              } catch (error) {
                                Scaffold.of(context)
                                    .hideCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(content: Text(error.message)));
                                return;
                              }
                            }
                            Scaffold.of(context).hideCurrentSnackBar();
                            setState(() {
                              _editEnabled = false;
                            });
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Successfully updated info')));
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
