import 'package:flutter/material.dart';

int _darkBlue = 0xFF022859;
int _midBlue = 0xFF2E78A6;
int _lightBlue = 0xFF6AAED9;


class Logueo extends StatefulWidget{
  @override
  _Logueo createState() => _Logueo();
}

class _Logueo extends State<Logueo>{
  TextEditingController correo = TextEditingController();
  TextEditingController pwd = TextEditingController();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child:  Padding(
          padding: EdgeInsets.only(top: 25,bottom: 0,left: 25,right: 25),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    color: Colors.transparent,
                    child: Image.asset('assets/images/Logo.png',scale: 6,),
                  ),
                  Container(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: correo,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.email,color: Color(_darkBlue),),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}