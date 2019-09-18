import 'package:flutter/material.dart';
import 'Mapa.dart';
class Mantenimiento extends StatefulWidget{
  var nombre;
  var correo;
  Mantenimiento({Key key, @required this.nombre, this.correo}) : super (key : key);
  @override
  _Mantenimiento createState() => _Mantenimiento();
}
int _darkBlue = 0xFF022859;
class _Mantenimiento extends State<Mantenimiento>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Mantenimiento"),
        backgroundColor: Color(_darkBlue),
      ),
      drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text(widget.nombre),
                decoration: BoxDecoration(color: Color(_darkBlue)),
                accountEmail: new Text(widget.correo),
                currentAccountPicture: new CircleAvatar(
                  backgroundImage: ExactAssetImage("assets/images/user.png"),
                ),
              ),
            new ListTile(
                title: Text("Mapa Dispensadores"),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:(BuildContext context) => Mapa(nombre: widget.nombre,correo: widget.correo,)),
                  );
                },
              ),
              new ListTile(
                title: Text("Resumen"),
                onTap: (){/*
                  Navigator.push(
                    context,
                    FadeRoute(
                      page: new HomeDashboard(nombre: widget.nombre,correo: widget.correo,)),
                  );
                */},
              ),
              new ListTile(
                title: Text("Agregar Dispensador"),
                onTap: (){/*
                  Navigator.push(
                    context,
                    FadeRoute(
                      page: new HomeAgregarPage(nombre: widget.nombre,correo: widget.correo,)),
                  );
                */},
              ),
              new ListTile(
                title: Text("Mantenimientos"),
                onTap: (){/*
                  Navigator.push(
                    context,
                    FadeRoute(
                      page: new MantenimientosSample(nombre: widget.nombre,correo: widget.correo,)),
                  );
                */},
              ),
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              
            ],
          ),
        ),
      ),
    );
  }
}