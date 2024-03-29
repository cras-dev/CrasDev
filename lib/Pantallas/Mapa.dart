//=====================IMPORTS=====================\\
import 'package:cras/Modelo/add_ubicacion.dart';
import 'package:cras/Modelo/inactivos.dart';
import 'package:cras/Modelo/rec_real.dart';
import 'package:cras/Modelo/temp_real.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cras/Modelo/ubicacion.dart';
import 'package:geolocator/geolocator.dart';
import 'AgregarDispensador.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'Dispensadores.dart';
import 'Resumen.dart';

//=====================DECLARACIONES=====================\\
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
TempReal tempReal;

const _urlDispensadores = "http://cras-dev.com/Interfaz/interfaz.php?auth=4kebq1J2MD&tipo=ubicacion";
const _url_add_ubicacion = "http://cras-dev.com/Interfaz/interfaz.php?auth=4kebq1J2MD&tipo=addubicacion";
const _urlObtenerInactivos = "http://cras-dev.com/Interfaz/interfaz.php?auth=4kebq1J2MD&tipo=activo";
const _urlRecReal ="http://cras-dev.com/Interfaz/interfaz.php?auth=4kebq1J2MD&tipo=recrel";
const _urlTmpReal ="http://cras-dev.com/Interfaz/interfaz.php?auth=4kebq1J2MD&tipo=temp_rel";

class Mapa extends StatefulWidget{
  var nombre;
  var correo;
  Mapa({Key key, @required this.nombre, this.correo}) : super (key : key);
  @override
  _MapaState createState() => _MapaState();
}
//=====================CONTROLLERS=====================\\
class _MapaState extends State<Mapa> {

  GlobalKey<ScaffoldState> _scaffoldKey= new GlobalKey<ScaffoldState>();
  _showSnackBar(){
    final snackBar = new SnackBar(
      content: Text(mensaje_snack),
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

//=====================DECLARACIÓN MAPA=====================\\
  GoogleMapController mapController;
  List <Marker> _Marcadores = [];
//=====================MARCADORES=====================\\
Future<List> _getMarkers()async{
  final response = await http.get(_urlDispensadores);
  _dispensador = Dispensador.fromJson(json.decode(response.body));
  for(var i=0;i<_dispensador.dispensadores.length;i++){
    _Marcadores.add(Marker(
      icon: BitmapDescriptor.fromAsset(path),
      infoWindow: InfoWindow(
        title: 'Dispensador'+' '+_dispensador.dispensadores[i].lugar,
        snippet:'\$'+_dispensador.dispensadores[i].total+' | '+_dispensador.dispensadores[i].temperatura+'°C',
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PantallaDispensadores(nombreDisp: _dispensador.dispensadores[i].lugar,nroSerie: _dispensador.dispensadores[i].nroSerie, nombreUsuario: widget.nombre,correoUsuario: widget.correo,)),
          );
        }
      ),
      markerId: MarkerId(i.toString()),
      draggable: true,
      onTap: (){
      },
      position: LatLng(double.parse(_dispensador.dispensadores[i].lat),double.parse(_dispensador.dispensadores[i].long))
    ));
  }
  return _Marcadores;
}
//=====================FUTURE UBICACIÓN=====================\\
Future ubicarDispensador()async{
  position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  latitude = position.latitude;
  longitude = position.longitude;
  var respose = await http.get("$_url_add_ubicacion&serie=$valor&lat=${latitude.toString()}&long=${longitude.toString()}&lugar=${lugarcontroller.text}");
  if(respose.statusCode == 200){
    ubicacion = AddUbicacion.fromJson(json.decode(respose.body));
    print(respose.statusCode);
    print(latitude.toString()+longitude.toString());
    if(ubicacion.realizado == "1"){
      return mensaje_snack = ubicacion.mensaje;
    }else{
      return mensaje_snack = ubicacion.mensaje;
    }
  }
}
//=====================FUTURE OBTENER INACTIVOS=====================\\
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
  return dispInactivos;
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
//=====================SOLICITUD DE PERMISOS PARA LOCALIZACIÓN=====================\\
  PermissionHandler().checkPermissionStatus(PermissionGroup.locationWhenInUse).then(_updateStatus);
}

String valor ;
List<String> dispInactivos = [];

final TextEditingController lugarcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
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
              onTap: (){
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => new Mapa(nombre: widget.nombre,correo: widget.correo,)
                  ),
                );
              },
            ),
            new ListTile(
              title: Text("Resumen"),
              onTap: (){
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => Resumen(nombre: widget.nombre,correo: widget.correo,)
                  ),
                );
              },
            ),
            new ListTile(
              title: Text("Agregar Dispensador"),
              onTap: (){
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => new AgregarDispensador(nombre: widget.nombre,correo: widget.correo,)
                  ),
                );
              },
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
            if(snapshot.data == null){
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Color(_darkBlue),
                  ),
                ),
              );
            }else{
              return GoogleMap(
                markers: Set.from(_Marcadores),
                initialCameraPosition: CameraPosition(
                  target: LatLng(-32.701760, -57.638912),
                  zoom: 7.5
                ),
                onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                },
              );
            }
          },
        ),
      ),
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
                              child: FutureBuilder(
                                future: _getDispIn(),
                                builder: (BuildContext context, AsyncSnapshot snapshot) => dropmenu(inactivos),
                              ),
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
                            position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                            latitude = position.latitude;
                            longitude = position.longitude;
                            var respose = await http.get("$_url_add_ubicacion&serie=$valor&lat=${latitude.toString()}&long=${longitude.toString()}&lugar=${lugarcontroller.text}");
                            if(respose.statusCode == 200){
                              ubicacion = AddUbicacion.fromJson(json.decode(respose.body));
                              print(respose.statusCode);
                              print(latitude.toString()+longitude.toString());
                              if(ubicacion.realizado == "1"){
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => new Mapa(nombre: widget.nombre,correo: widget.correo,)
                                  ),
                                );
                              }else{
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(ubicacion.mensaje),
                                ));
                              }
                            }
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
//=====================LISTA INACTIVOS=====================\\
Widget dropmenu(Inactivos dis){
  return DropdownButton<String>(
    value: valor,
    onChanged: (value){
      setState(() {
        valor = value;
      });
      print(valor);
    },
    items: dispInactivos.map<DropdownMenuItem<String>>((String value){
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
    }).toList(),
  );
}

//=====================PERMISOS LOCALIZACIÓN=====================\\
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


