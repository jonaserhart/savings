import 'package:flutter/material.dart';

class AddSavingModal extends StatefulWidget {
  final Function(double amount, String description) onSavingAdded;
  AddSavingModal(this.onSavingAdded);
  @override
  _AddSavingModalState createState() => _AddSavingModalState();
}

class _AddSavingModalState extends State<AddSavingModal> {
  var _savingFormKey = GlobalKey<FormState>();
  var _savingController = TextEditingController();
  var _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New entry'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Form(
              key: _savingFormKey,
              child: Column(
                children: [
                  TextFormField(
                      textAlign: TextAlign.center,
                      controller: _savingController,
                      style: TextStyle(fontSize: 35),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 20),
                        hintText: 'Amount',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a value';
                        }
                        if (double.tryParse(value) == null) {
                          if (double.tryParse(value.replaceAll(',', '.')) ==
                              null) {
                            return 'Not a number';
                          }
                        }
                        return null;
                      }),
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: TextFormField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Description',
                      ),
                      validator: (value) {
                        if (value.length > 15) {
                          return 'too long';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ))
        ],
      ),
      actions: <Widget>[
        new OutlinedButton(
          onPressed: () {
            if (_savingFormKey.currentState.validate()) {
              var value = double.tryParse(_savingController.text);
              if (value == null) {
                value = double.tryParse(_savingController.text.replaceAll(',', '.'));
              }
              //close modal
              Navigator.of(context).pop();
              widget.onSavingAdded(value ?? 0, _descriptionController.text);
            }
          },
          child: const Text('Submit'),
        ),
        new OutlinedButton(
          onPressed: () {
            _savingFormKey.currentState.reset();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
