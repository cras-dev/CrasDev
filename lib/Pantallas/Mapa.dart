import 'package:cras/Modelo/add_ubicacion.dart';
import 'package:cras/Modelo/inactivos.dart';
import 'package:cras/Modelo/rec_real.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cras/Modelo/ubicacion.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

int _darkBlue = 0xFF022859;
double lat;
double long;
Position position;
double latitude;
double longitude;
String inactivo;
String path = 'assets/images/150x150.png';

Inactivos inactivos;
Dispensador _dispensador;
AddUbicacion ubicacion;
RecReal recReal;

const _urlDispensadores = "http://cras-dev.com/Interfaz/interfaz.php?&tipo=ubicacion";
const _url_add_ubicacion = "http://cras-dev.com/Interfaz/interfaz.php?&tipo=addubicacion";
const _urlObtenerInactivos = "http://cras-dev.com/Interfaz/interfaz.php?&tipo=activo";
const _urlRecReal ="http://cras-dev.com/Interfaz/interfaz.php?&tipo=recrel";

class Mapa extends StatefulWidget{
  var nombre;
  var correo;
  Mapa({Key key, @required this.nombre, this.correo}) : super (key : key);
  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {

  GoogleMapController mapController;
  List <Marker> _Marcadores = [];
  
Future _getMarkers()async{
  var response = await http.get(_urlDispensadores);
  _dispensador = Dispensador.fromJson(json.decode(response.body));

  for(var i=0;i<_dispensador.dispensadores.length;i++){
    _Marcadores.add(Marker(
      icon: BitmapDescriptor.fromAsset(path),
      infoWindow: InfoWindow(title: 'Dispensador'+' '+_dispensador.dispensadores[i].lugar,snippet: '\$8500',onTap: (){/*Navigator.push(context,FadeRoute(page: new HomeDispensadores(nombreDisp: _dispensador.dispensadores[i].lugar,nroSerie: _dispensador.dispensadores[i].nroSerie, nombreUsuario: widget.nombre,correoUsuario: widget.correo,)),);*/}),
      markerId: MarkerId(i.toString()),
      draggable: true,
      onTap: (){
      },
      position: LatLng(double.parse(_dispensador.dispensadores[i].lat),double.parse(_dispensador.dispensadores[i].long))
    ));
  }
}

Future ubicarDispensador()async{
  position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  latitude = position.latitude;
  longitude = position.longitude;
  var respose = await http.get("${_url_add_ubicacion}&serie=$valor&lat=${latitude.toString()}&long=${longitude.toString()}&lugar=${lugarcontroller.text}");
  if(respose.statusCode == 200){
    ubicacion = AddUbicacion.fromJson(json.decode(respose.body));
    print(respose.statusCode);
    print(latitude.toString()+longitude.toString());
    if(ubicacion.realizado == "1"){
      print('ubicado');
    }else{ 
    }
  }
}

Future _getDispIn()async{
var response = await http.get(_urlObtenerInactivos);
  if(response.statusCode == 200){
    inactivos = Inactivos.fromJson(json.decode(response.body));
    dispInactivos.clear();
      _getDispIn();
      for(int i = 0;i<inactivos.dispensadores.length;i++){
        dispInactivos.add(inactivos.dispensadores[i].serie);
      }
  }
}
  PermissionStatus _status;
  var geolocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
var name;
var email;
@override
void initState() {
  super.initState();
  email= widget.nombre;
  PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse).then(_updateStatus);
}

String valor ;
List<String> dispInactivos = [];

TextEditingController lugarcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        actions: <Widget>[
        ],
        centerTitle: true,
        title: Text("Mapa Dispensadores",),
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
              onTap: (){/*
                Navigator.push(
                  context,
                  FadeRoute(
                    page: new MapSample(nombre: widget.nombre,correo: widget.correo,)),
                );
              */},
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
    width: MediaQuery.of(context).size.width,
    child: FutureBuilder(
        future: _getMarkers(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return GoogleMap(
            markers: Set.from(_Marcadores),
            initialCameraPosition: CameraPosition(
              target: LatLng(-32.701760, -57.638912),
              zoom: 7.5),
            onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          );
        },
    ),),
  floatingActionButton: Align(
    alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.only(left:30,bottom: 15),
        child: FloatingActionButton(
        backgroundColor: Color(_darkBlue),
        child: Icon(Icons.add),
        onPressed: () async{
          _askPermission();
          showDialog(
            context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                    //contentPadding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(35))),
                    backgroundColor: Colors.white,
                    title: new Text("Agregar Ubicación".toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                    actions: <Widget>[
                         Column(
                          	children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(right:10,left: 20),
                                      alignment: Alignment.centerLeft,
                                      /*child: FutureBuilder(
                                        future: _getDispIn(),
                                        builder: (BuildContext context, AsyncSnapshot snapshot) => dropmenu(inactivos),
                                      ),*/
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      //height: MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width/3,
                                      child: TextField(
                                        //controller: clavecontroller,
                                        obscureText: false,
                                        controller: lugarcontroller,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          labelStyle: TextStyle(color: Colors.grey),
                                          prefixIcon: Icon(Icons.place,color: Color(_darkBlue),),
                                          labelText: 'Lugar',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(8))
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          	    IconButton(
                                  iconSize: 90,
                                  icon: Icon (Icons.location_on,color: Colors.redAccent,size: 70,),
                                  onPressed: ()async{
                                    ubicarDispensador();
                                    Navigator.of(context).pop();
                                    Timer(Duration(seconds: 2), (){
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>new Mapa(nombre: widget.nombre,correo: widget.correo,)
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    });
                                  },
                                ),
                          	  ],
                          	),
                    ],
                  );
                },
              );
        }
    ),
      ),
  ),
);
}
void _updateStatus(PermissionStatus status){
    if(status != _status){
      setState(() {
        _status =  status;
      });
    }
  }

  void _askPermission(){
    PermissionHandler().requestPermissions(
      [PermissionGroup.locationWhenInUse]).then(_onStatusRequested);
  }

  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> statusses){
    final status = statusses[PermissionGroup.locationWhenInUse];
    _updateStatus(status);
  }
}


