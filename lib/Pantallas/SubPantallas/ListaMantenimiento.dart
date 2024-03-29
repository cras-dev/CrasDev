//=====================IMPORTS=====================\\
import 'package:flutter/material.dart';
import '../../Modelo/ListaMant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListaMantenimiento extends StatefulWidget{
  var nro_serie, nombre, correo;
  ListaMantenimiento({Key key, @required this.nro_serie, this.nombre, this.correo}) : super (key : key);
  @override
  _ListaMantenimiento createState() => _ListaMantenimiento();
}

int _darkBlue = 0xFF022859;
ListaMant lista;
Mantenimineto mant;
List<String> serie = [];
List<String> nombre = [];
List<String> fecha = [];
List<String> comentario = [];

final _url = "http://cras-dev.com/Interfaz/interfaz.php?auth=4kebq1J2MD&tipo=lista";

//=====================PANTALLA=====================\\
class _ListaMantenimiento extends State<ListaMantenimiento>{

//=====================FUTURE=====================\\
  Future getList() async{
    var response = await http.get(_url);
    if(response.statusCode == 200){
      lista = ListaMant.fromJson(json.decode(response.body));
      if(lista.realizado == "1"){
       /* for (int i = 0 ; i < lista.mantenimineto.length ; i++){
          serie.add(lista.mantenimineto[i].nroSerie);
          nombre.add(lista.mantenimineto[i].lugar);
          fecha.add(lista.mantenimineto[i].fecha);
          comentario.add(lista.mantenimineto[i].comentario);
        }*/
      }else{

      }
    }else{

    }
    return lista;
  }

  @override
  void initState(){
    super.initState();
    getList();
  }
  @override
  Widget build(BuildContext context){ 
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Mantenimiento"),
        centerTitle: true,
        backgroundColor: Color(_darkBlue),
      ),
      body: FutureBuilder(
        future: getList(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.data == null){
            return Container(
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color(_darkBlue),
                ),
              ),
            );
          }else{
            return _buildListView(lista);
          }
        },
      ),
    );
  }
  Widget _buildListView(ListaMant mant){
    return Row(
      children: <Widget>[
        Flexible(
          child: ListView.builder(
            itemCount: mant == null ? 0 : mant.mantenimineto.length,
            itemBuilder: (BuildContext context, int index) => buildMantListItem(mant.mantenimineto[index]),
          ),
        )
      ],
    );
  }

  Widget buildMantListItem(Mantenimineto item){
    return Card(
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "Dispensador nro: "+item.nroSerie + ", " + item.lugar,
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  item.fecha
                )
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.comentario,
              ),
            )
          ],
        ),
      ),
    );
  }
}