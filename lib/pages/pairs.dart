import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newapp/imports/navbar.dart';
import 'package:newapp/pages/profile_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Pairs extends StatefulWidget {
  @override
  _PairesPageState createState() => _PairesPageState();
}

class _PairesPageState extends State<Pairs> {

  final receiverTokenCTRL = TextEditingController();  

  String userid;
  String apiToken;
  String authToken;
  String newAuthToken;
  bool checkStatus = false;
  bool checkPairStatus = false;

  String requestUsername;
  String requestFullname;
  String requestSenderID;

  doInitialActions() async{
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      userid = prefs.getString("user_id") ?? "null";
      apiToken = prefs.getString("apiToken") ?? "null";
      authToken = prefs.getString("authToken") ?? "null";
      prefs.setInt("navbarIndex",2);
      newAuthToken = authToken;
    });

    Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
      'Authorization':'$apiToken'
    };

    final response2 = await http.post("http://34.72.70.18/api/users/checkPair", headers: headers);
    if(response2.statusCode == 200){
      var datauser = json.decode(response2.body);
      setState(() {
        checkPairStatus = false;
      });
      if(datauser["data"]["success"] == true) {
        setState(() {
          checkPairStatus = true;
        });
      }
    }

    var body = json.encode({"authtoken":authToken});
    final response = await http.post("http://34.72.70.18/api/users/pairs/check", body: body, headers: headers);
    if(response.statusCode == 200){
      var datauser = json.decode(response.body);
      if(datauser["data"]["success"] == true) {
        setState(() {
          checkStatus = true;
          requestFullname = datauser["data"]["data"]["fullname"];
          requestUsername = datauser["data"]["data"]["username"];
          requestSenderID = datauser["data"]["data"]["id"];
        });
      }
    }
  }

  Future<void> cancelPair() async {
    Map<String,String> headers = {
      'Content-type' : 'application/json', 
      'Accept': 'application/json',
      'Authorization':'$apiToken'
    };

    final response = await http.post("http://34.72.70.18/api/users/pairs/cancel", headers: headers);

    if(response.statusCode == 200){

      var datauser = json.decode(response.body);

      if(datauser["data"]["success"] == true) {
        setState(() {
          checkPairStatus = false;
        });
        _showMyDialog("Eşleşme Kaldırıldı!");
      } 
    }
  }

  initState(){
    super.initState();
    doInitialActions();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Eşleşme"),
        centerTitle: true,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.white),
        child: Navbar()
      ),
      drawer: ProfileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[ 
            if(checkStatus == true)(
              Container(
                height : 180,
                child :Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                  elevation: 5.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.person, size: 50),
                        title: Text("$requestFullname"),
                        subtitle: Text("$requestUsername"),
                      ),
                      SizedBox(height :30,),
                      ButtonBar(
                        children: <Widget>[
                          RaisedButton(
                            onPressed: acceptRequest,
                            color: Colors.green[500],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                            child: Center(child: Text("Kabul et",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),),
                          ),
                          RaisedButton(
                            onPressed: rejectRequest,
                            color: Colors.red[500],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                            child: Center(child: Text("Reddet",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ),
            if(checkPairStatus == false)(
              Container(
                height : 180,
                child :Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                  elevation: 5.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(title: Text('Kod Giriniz',style: TextStyle(fontSize : 20,fontWeight: FontWeight.w900),),),
                      TextField(
                        controller: receiverTokenCTRL,
                        decoration: InputDecoration(
                          icon: Icon(Icons.edit),
                          border: InputBorder.none,
                          hintText: 'Bağlantı kodunu giriniz.'
                        ),
                      ),
                      ButtonBar(
                        children: <Widget>[
                          RaisedButton(
                            onPressed: requestPair,
                            color: Colors.blue[500],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                            child: Center(child: Text("Gönder",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ),
            Container(
              height : 180,
              child :Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                elevation: 5.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('Kodunuz',style: TextStyle(fontSize : 20,fontWeight: FontWeight.w900),),
                      subtitle: Text('$newAuthToken'),
                    ),
                    SizedBox(height : 30,),
                    ButtonBar(
                      children: <Widget>[
                        RaisedButton(
                          onPressed: resetAuthToken,
                          color: Colors.blue[500],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                          child: Center(child: Text("Yenile",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if(checkPairStatus == true)(   
              Container(
                height : 180,
                child :Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                  elevation: 5.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text('Eşleşmeyi Kaldır',style: TextStyle(fontSize : 20,fontWeight: FontWeight.w900),),
                        subtitle: Text(''), 
                      ),
                      SizedBox(height : 30,),
                      ButtonBar(
                        children: <Widget>[
                          RaisedButton(
                            onPressed: cancelPair,
                            color: Colors.blue[500],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),),
                            child: Center(child: Text("Kaldır",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            )
          ]
        ),
      ),
    );
  }
  Future<void> resetAuthToken() async {
    
    final response = await http.post("http://34.72.70.18/api/users/resettoken", headers: {
      "Authorization": apiToken,
    });
  
    if(response.statusCode == 200){
      var datauser = json.decode(response.body);
      if(datauser["data"]["success"] == false){
        // Service unavailable!
      } else {
        setState(() {
          newAuthToken = datauser["data"]["data"];
          authToken = newAuthToken;
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("authToken", authToken);
      }  
    } else {
     // Service unavailable!
    }
  }

  Future<void> requestPair() async {
    if(receiverTokenCTRL.text.trim() == ""){
      _showMyDialog("Bağlantı kodu boş olamaz!");
    } else {
      final response = await http.post("http://34.72.70.18/api/users/pairs/create", headers: {
        "Authorization": apiToken,
      },
      body: {
        "receiver_token": receiverTokenCTRL.text.trim(),
      });
      if(response.statusCode == 200){
        var datauser = json.decode(response.body);
        if(datauser["data"]["success"] == false){
           _showMyDialog("Istek gönderilemedi! Böyle bir kod yok ya da bekleyen bir isteğiniz var!");
        } else {
          _showMyDialog("İstek Gönderildi!");
        }  
      } else {
        _showMyDialog("Şuanda bu işlemi gerçekleştiremiyoruz!");
      }
    }
  }

  Future<void> acceptRequest() async {
    final response = await http.post("http://34.72.70.18/api/users/pairs/update", headers: {
      "Authorization": apiToken,
    },
    body: {
      "approve": "1",
      "sender_id": requestSenderID,
    });
    if(response.statusCode == 200){
      var datauser = json.decode(response.body);
      if(datauser["data"]["success"] == false){
        print("Server Error!");
      } else {
        print("Pair Operation Completed!");
        setState(() {
          checkStatus = false;
        });
      }  
    } else {
     // Service unavailable!
    }
  }

  Future<void> rejectRequest() async {
    final response = await http.post("http://34.72.70.18/api/users/pairs/update", headers: {
      "Authorization": apiToken,
    },
    body: {
      "approve": "-1",
      "sender_id": requestSenderID,
    });
    if(response.statusCode == 200){
      var datauser = json.decode(response.body);
      if(datauser["data"]["success"] == false){
        print("Server Error!");
      } else {
        setState(() {
          checkStatus = false;
        });
        print("Pair Operation Rejected!");
      }  
    } else {
     // Service unavailable!
    }
  }

  Future<void> _showMyDialog(text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notice'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
