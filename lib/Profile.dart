import 'package:connect_plus/models/profile.dart';
import 'package:connect_plus/models/register_request_params.dart';
import 'package:connect_plus/models/user.dart';
import 'package:connect_plus/widgets/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:connect_plus/widgets/app_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connect_plus/services/web_api.dart';
import 'package:connect_plus/services/auth_service/auth_service.dart';
import 'package:connect_plus/injection_container.dart';

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final LocalStorage localStorage = new LocalStorage("Connect+");
  bool _notEditing = true;
  final FocusNode myFocusNode = FocusNode();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController carPlateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //Missing validation that edit profile is success or a failure .. but tested it is working
  void editProfile() async {
    try {
      await sl<AuthService>().updateProfile(
        username: nameController.text == "" ? null : nameController.text,
        phoneNumber: phoneController.text == "" ? null : phoneController.text,
        carPlate: carPlateController.text == "" ? null : phoneController.text,
      );
    } catch (e) {
      CupertinoAlertDialog(
        content: new Text("An Error Occured, Please try again!"),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text(
              "Close",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Utils.header,
                  fontWeight: FontWeight.w600,
                  fontSize: 17),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return CupertinoAlertDialog(
          content: new Text("Profile Edited Successfully!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Close",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Utils.header,
                    fontWeight: FontWeight.w600,
                    fontSize: 17),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getLabel(String value) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Padding(
        padding: EdgeInsets.only(
            left: width * 0.08, right: width * 0.08, top: height * 0.02),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Text(
                  value,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _getField(
      String value, TextEditingController controller, bool isEmail) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Padding(
        padding: EdgeInsets.only(
            left: width * 0.08, right: width * 0.08, top: height * 0.01),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Flexible(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: value,
                ),
                enabled: isEmail ? false : !_notEditing,
                autofocus: !_notEditing,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Utils.background,
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Profile Details"),
          centerTitle: true,
          backgroundColor: Utils.header,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Utils.secondaryColor,
                  Utils.primaryColor,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
        ),
        body: new Container(
          child: new ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  new Container(
                    height: height * 0.23,
                    child: new Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: height * 0.05),
                          child:
                              new Stack(fit: StackFit.loose, children: <Widget>[
                            new Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Container(
                                    width: width * 0.20,
                                    height: height * 0.14,
                                    decoration: new BoxDecoration(
                                      image: new DecorationImage(
                                        image: new ExactAssetImage(
                                            'assets/as.png'),
                                        fit: BoxFit.contain,
                                      ),
                                    )),
                              ],
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  new Container(
                    color: Utils.background,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: height * 0.03),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(right: width * 0.08),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      _notEditing
                                          ? _getEditIcon()
                                          : new Container(),
                                    ],
                                  )
                                ],
                              )),
                          FutureBuilder<User>(
                            future: sl<AuthService>().user,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    height: 60,
                                    width: 60,
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final user = snapshot.data;
                              return Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      _getLabel("Full Name"),
                                      _getField(user.username.toString(),
                                          nameController, false),
                                      _getLabel("Email"),
                                      _getField(user.email.toString(),
                                          emailController, true),
                                      _getLabel("Phone Number"),
                                      _getField(user.phoneNumber.toString(),
                                          phoneController, false),
                                      _getLabel("Car Plate"),
                                      _notEditing
                                          ? _getField(
                                              user.carPlate,
                                              carPlateController,
                                              false,
                                            )
                                          : CarPlateForm(
                                              carPlateController:
                                                  carPlateController,
                                              initialValue: user.carPlate,
                                            ),
                                      !_notEditing
                                          ? _getActionButtons(user)
                                          : new Container(),
                                    ],
                                  ));
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    carPlateController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons(User user) {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  editProfile();
                  setState(() {
                    _notEditing = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _notEditing = true;
                    nameController.text = user.username;
                    emailController.text = user.email;
                    phoneController.text = user.phoneNumber;
                    carPlateController.text = user.carPlate;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Utils.header,
        radius: 20.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 20.0,
        ),
      ),
      onTap: () {
        setState(() {
          _notEditing = false;
        });
      },
    );
  }
}

class CarPlateForm extends StatefulWidget {
  const CarPlateForm({
    Key key,
    @required this.carPlateController,
    @required this.initialValue,
  }) : super(key: key);

  final TextEditingController carPlateController;
  final String initialValue;
  @override
  _CarPlateFormState createState() => _CarPlateFormState();
}

class _CarPlateFormState extends State<CarPlateForm> {
  String _plateLetters = "";
  String _plateNumbers = "";

  @override
  void initState() {
    widget.initialValue.characters.forEach((char) {
      if (isArabicLetter(char)) {
        _plateLetters += char;
      } else if (isArabicNumeral(char)) {
        _plateNumbers += char;
      }
    });
    super.initState();
  }

  bool isArabicLetter(String str) =>
      RegExp("^[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FF]+\$").hasMatch(str);

  bool isArabicNumeral(String str) =>
      RegExp("^[\u0621-\u064A\u0660-\u0669]+\$").hasMatch(str);

  String _validateLetters(String letters) {
    if (_plateLetters.isEmpty && _plateNumbers.isEmpty) {
      return null;
    }
    if (_plateLetters.isEmpty) {
      return "Empty field";
    }

    if (!isArabicLetter(letters)) {
      return "Arabic letters only";
    }
    return null;
  }

  String _validateNumbers(String numbers) {
    if (_plateLetters.isEmpty && _plateNumbers.isEmpty) {
      return null;
    }
    if (_plateNumbers.isEmpty) {
      return "Invalid Input";
    }
    if (!isArabicNumeral(numbers)) {
      return "Arabic numerals only";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(
        left: width * 0.08,
        right: width * 0.08,
        top: height * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: CarPlateTextField(
                  validator: _validateNumbers,
                  initialText: _plateNumbers,
                  onChanged: (numbers) {
                    _plateNumbers = numbers;
                    widget.carPlateController.text =
                        _plateLetters + _plateNumbers;
                  },
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: CarPlateTextField(
                  validator: _validateLetters,
                  initialText: _plateLetters,
                  onChanged: (letters) {
                    _plateLetters = letters;
                    widget.carPlateController.text =
                        _plateLetters + _plateNumbers;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CarPlateTextField extends StatelessWidget {
  final void Function(String value) onChanged;
  final String Function(String value) validator;
  final String initialText;
  const CarPlateTextField({
    Key key,
    this.onChanged,
    this.validator,
    this.initialText = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20.0),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintText: initialText,
      ),
    );
  }
}
