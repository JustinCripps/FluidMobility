import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:ttlock_flutter/ttlock.dart';
//import 'package:ttlock_premise_flutter/ttgateway.dart';
//import 'package:ttlock_premise_flutter/ttlock.dart';


//links; https://github.com/ttlock/Android_SDK_Demo/blob/master/README.en.md
//get token; https://open.ttlock.com/doc/oauth2
//chart; https://open.ttlock.com/doc/userGuide
//flutter ex; https://github.com/ttlock/ttlock_flutter

bool firstAppStart = true;
bool failedAttempt = false;
String userToken;
Future<TokenGetter> _futureTokenGetter;
String loginUsername = "";
String loginPassword = "";
bool noLocks = false;

//if user login's correctly set this data
String lockClientId = "b39b8b4ae55245098bb0509231a8f077";
int lockPageNo = 1;
int lockPageSize = 100;

class TokenGetter{
  final String token;
  TokenGetter({this.token});
  factory TokenGetter.fromJson(Map<String, dynamic> json){
    return TokenGetter(
        token: json['access_token']
    );
  }
}

Future<TokenGetter> getToken(String userName, String password) async{
  String endPoint = "https://api.ttlock.com/oauth2/token?client_id=b39b8b4ae55245098bb0509231a8f077&client_secret=812f236dd87f89c0b565837080632bdb";
  String url = endPoint + "&username=" + userName + "&password=" + password;
  final response = await http.post(url, headers: {"Content-Type": "application/x-www-form-urlencoded"});

  if(response.statusCode == 200){ //upon success
    return TokenGetter.fromJson(json.decode(response.body));
  }else{
    throw Exception('Failed to get Token');
  }
}

class Lock{
  String lockId;
  int date;
  String lockName;
  String lockAlias;
  String lockMac;
  int battery;
  int keyboardPwdVersion;
  int specialValue;
  //final int hasGateway; //1 = yes, 0 = no
  //final String lockData;
  Lock({this.lockId, this.date, this.lockName, this.lockAlias, this.lockMac,
    this.battery, this.keyboardPwdVersion, this.specialValue});
  factory Lock.fromJson(Map<String, dynamic> json){
    return Lock(
      lockId: json['list']['lockId'],
      date: json['list']['date'],
      lockName: json['list']['lockName'],
      lockAlias: json['list']['lockAlias'],
      lockMac: json['list']['lockMac'],
      battery: json['list']['electricQuantity'],
      keyboardPwdVersion: json['list']['keyboardPwdVersion'],
      specialValue: json['list']['specialValue']
    );
  }
}


Future<List<Lock>> getLockList(String clientId, String token, int pageNo, int pageSize) async{
  String endPoint = "https://api.ttlock.com/v3/lock/list?";
  String url = endPoint + "clientId=" + clientId + "&accessToken=" + token + "&pageNo=" + pageNo.toString() + "&pageSize=" + pageSize.toString() + "&date=" + DateTime.now().millisecondsSinceEpoch.toString();
  final response = await http.post(url);
  List<Lock> lockList = [];

  if(response.statusCode == 200){ //upon success
    Map<String, dynamic> myMap = json.decode(response.body);
    var i = 0;
    for(i = 0; i < myMap["list"].length; i++){
      Lock tempLock = new Lock();
      if(myMap["list"][i]["lockId"] != null){
        tempLock.lockId = myMap["list"][i]["lockId"];
      }else{
        tempLock.lockId = "No Lock ID Set";
      }if(myMap["list"][i]["date"] != null && myMap["list"][i]["date"] != 0){
        tempLock.date = myMap["list"][i]["date"];
      }else{
        tempLock.date = 0;
      }if(myMap["list"][i]["lockName"] != null){
        tempLock.lockName = myMap["list"][i]["lockName"];
      }else{
        tempLock.lockName = "No Lock Name Set";
      }if(myMap["list"][i]["lockAlias"] != null){
        tempLock.lockAlias = myMap["list"][i]["lockAlias"];
      }else{
        tempLock.lockAlias = "No Lock Alias Set";
      }if(myMap["list"][i]["lockMac"] != null){
        tempLock.lockMac = myMap["list"][i]["lockMac"];
      }else{
        tempLock.lockMac = "No Lock MAC Set";
      }if(myMap["list"][i]["electricQuantity"] != null){
        tempLock.battery = myMap["list"][i]["electricQuantity"];
      }else{
        tempLock.battery = 111; //don't want to use zero, **ask about this** test help
      }if(myMap["list"][i]["keyboardPwdVersion"] != null){
        tempLock.keyboardPwdVersion = myMap["list"][i]["keyboardPwdVersion"];
      }else{
        tempLock.keyboardPwdVersion = 111; //don't want to use zero, **ask about this** test help
      }if(myMap["list"][i]["specialValue"] != null){
        tempLock.specialValue = myMap["list"][i]["specialValue"];
      }else{
        tempLock.specialValue = 11; //don't want to use zero, **ask about this** test help
      }
      lockList.add(tempLock);
    }
    return lockList;
    //return Lock.fromJson(json.decode(response.body));
  }else{
    throw Exception('Failed to get lock list');
  }
}

class DataRequiredForLandingPage{
  List<Lock> lockList;
  DataRequiredForLandingPage({
    this.lockList
});
}

Future<DataRequiredForLandingPage> _fetchLandingPageData(String clientId, String token, int pageNo, int pageSize) async{
  return DataRequiredForLandingPage(
    lockList: await getLockList(clientId, token, pageNo, pageSize),
  );
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();
}


class _MyAppState extends State<MyApp>{
  Locale _locale;

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      title: '',
      //localization information gotten from
      // https://flutter.dev/docs/development/accessibility-and-localization/internationalization
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).loginPage,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [ //can add more supported languages here
        const Locale('en', ''), // English, no country code
        const Locale('es', ''), // Spanish, no country code
        const Locale('fr', ''), // French, no country code
        const Locale('it', ''), // Italian, no country code
      ],
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final passwordController = new TextEditingController(); //stores the user-entered password
  final usernameController = new TextEditingController(); //stores the user-entered username
  var hidePass = true; //used for the password visibility-toggle
  String dropDownValue;


  void _togglePasswordView() {
    setState(() {
      hidePass = !hidePass;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(firstAppStart){
      dropDownValue = AppLocalizations.of(context).currentLang;
      firstAppStart = false;
    }

    return Scaffold(
      appBar: AppBar(
          title: Row(//<Widget>[
              children: [
                const Icon(Icons.language, color: Colors.black),
                SizedBox(width: 2),
                DropdownButton<String>(
                  value: dropDownValue,
                  icon: const Icon(Icons.arrow_downward, color: Colors.black),
                  iconSize: 15,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                  underline: Container(
                    height: 1,
                    color: Colors.red,
                  ),
                  onChanged: (String newValue){
                    setState(() {
                      dropDownValue = newValue; //set current selected value to the new one
                      String langCode = newValue[0].toLowerCase() + newValue[1]; //gets first 2 chars of the language name
                      MyApp.of(context).setLocale(Locale.fromSubtags(languageCode: langCode)); //change the language to the newly selected one
                    });
                  },
                  items: <String>['English', "Español", "Français", "Italiano"] //list of options
                      .map<DropdownMenuItem<String>>((String _value) {
                    return DropdownMenuItem<String>(
                      value: _value,
                      child: Text(_value),
                    );
                  }).toList(),
                )
              ]
          )
      ),
      body: Center(
        child: (_futureTokenGetter == null) ? //if statement
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context).loginInfo),
            Text(''),
            Container(
              width: 300.0,
              child: TextFormField(controller: usernameController,
                  decoration: InputDecoration(border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context).enterUsername),
                  maxLength: 40),
            ),
            Container(
              width: 300.0,
              child: TextField(controller: passwordController,
                  decoration: InputDecoration(border: OutlineInputBorder(),
                      suffixIcon: InkWell(
                          onTap: _togglePasswordView,
                          child: Icon(
                              Icons.visibility)
                      ),
                      labelText: AppLocalizations.of(context).enterPassword),maxLength: 40,
                  obscureText: hidePass),
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).submit),
              onPressed: () {
                setState(() {
                  if(usernameController.text == "test" && passwordController.text == "test"){ //STRICTLY FOR TESTING. REMOVE THIS AFTER.
                    loginUsername = "fajb_fluidtest1";
                    loginPassword = "9415e1aa08e35a4b56dc84420678a9f0";
                  }else{
                    loginUsername = usernameController.text;
                    loginPassword = passwordController.text;
                  }
                  _futureTokenGetter = getToken(loginUsername, loginPassword);
                });
              },
            ),
            if(failedAttempt)Container(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(AppLocalizations.of(context).invalidUserPass),
                )
            ),

          ],
        ):
        FutureBuilder<TokenGetter>(
            future: getToken(loginUsername, loginPassword),
            builder: (context, snapshot){
              if(snapshot.hasData){ //snapshot.hasData
                if(snapshot.data.token != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    failedAttempt = false;
                    userToken = snapshot.data.token; //stores the users token
                    Navigator.push( //Goes to the landing page
                        context,
                        MaterialPageRoute(builder: (context) => LandingPage())
                    );
                    _futureTokenGetter = null;
                    setState(() {
                      //just call this at the end to re-establish the login screen if the user presses the back button
                    });
                  });
                }else{ //if there is some form of error, return a failed attempt
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    failedAttempt = true;
                    setState(() {
                      //just call this at the end to re-establish the login screen if the user presses the back button
                    });
                  });
                }
              }else if(snapshot.hasError){ //if there is some form of error, return a failed attempt
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  failedAttempt = true;
                  setState(() {
                    //just call this at the end to re-establish the login screen if the user presses the back button
                  });
                });
              }
              _futureTokenGetter = null;
              return CircularProgressIndicator(); //display a loading icon while data is being fetched from the API
            }
        ),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>{
  Future<DataRequiredForLandingPage>_dataRequiredForLandingPage;

  @override
  void initState(){
    super.initState();
    _dataRequiredForLandingPage = _fetchLandingPageData(lockClientId, userToken, lockPageNo, lockPageSize);
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).lockList),
        actions: <Widget>[
          //Container(width: 100, height: 100, child: Text("Add Lock")),
          ElevatedButton(
            child: Icon(Icons.add_circle),
            onPressed: (){
              //TTLockClient.getDefault().prepareBTService(getApplicationContext());





          },
          )
        ]
      ),
      body: FutureBuilder<DataRequiredForLandingPage>(
        future: _dataRequiredForLandingPage,
        builder: (context, snapshot){
          if(snapshot.hasData){
           // if(snapshot.data.lockList.length < 1){

              //get stuff for the new device
              //figure this part out, display the "add" screen, submit do the bottom stuff in this block. return the info-form-fill-out page

              //on submit & success:
              //snapshot.data.lockList.length = 1;
             // WidgetsBinding.instance.addPostFrameCallback((_) {
              //  setState(() {
              //    //re-loads the builder to account for the newly added device
              //  });
             // });
            //  return Card(
            //      child: Text("Test")
             // );
            //}else{
            if(snapshot.data.lockList.length < 1){
              noLocks = true;
            }
              return !noLocks ? Card(
                  child: ListTile( //adjust this once device is being added properly using index and variable names
                      leading: Icon(Icons.lock_outlined),
                      title: Text("LockName"),
                      subtitle: Text("100" + "%"),
                      trailing: Container(
                        height: 30, width: 60,
                        child: ElevatedButton(
                          child: Icon(Icons.info),
                          onPressed: () {
                            setState(() {
                              //display lock info here by calling function
                              //with a lock as a parameter, pass in the lock
                            });
                          },
                        ),
                      )
                  )):
                  Container(
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context).noLocks, style: TextStyle(fontSize: 18))
                  );
           // }
          }else if(snapshot.hasError){
            Center(
              child: Text("Fatal Error - Could not retrieve lock information. Please restart the application") //test for now, change later
            );
          }
            return CircularProgressIndicator();
        }
      )
    );
  }
}
