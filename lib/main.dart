
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Scan QR and BarCode'),
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
  String _counter;
  var _value = "";
  GlobalKey globalKey = GlobalKey();

  Future _incrementCounter() async{
    _counter = await FlutterBarcodeScanner.scanBarcode("#004297", "Exit", true);

    setState(() {
      if(_counter!=""){
        _value = _counter;
      }
    });
    
  }

  Widget link(){
    if (_value.startsWith("http")) {
      return InkWell(
        child: Text('Open Browser'),
        onTap: () => launch(_value)
      );
    }else{
      return SizedBox(height: 30,);
    }
  }

  Widget qr(){
    if(_value != ""){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  <Widget>[
          RepaintBoundary (
            key: globalKey,
            child: QrImage(
              data: _value,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            )
          )
        ]
        
      );
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  <Widget>[
          Text("Scan new QR or Barcode"),
          RotatedBox(
            quarterTurns: 2,
            child: Image.asset(
              "assets/images/inicio.png",
              width: 300,
              height: 300
            ),
          ) 
        ]
      );
  }

    @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
    ]);
  }

  Widget _neverSatisfied(){
      return AlertDialog(
        title: Text('Alert'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Save QR is Successfull:'),
              Text("\tThe QR is in Galery")
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Regret'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}

  Future<void> _capturePng() async {
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
     RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    final result = await ImageGallerySaver.saveImage(pngBytes);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
        textAlign: TextAlign.center,),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SelectableText(
              _value,
              style: Theme.of(context).textTheme.display1,
            ),
            SizedBox(height: 30,),
            link(),
            SizedBox(height: 30,),
            qr(),
          ],
        ),
      ),
      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            IconButton(
              icon: Icon(Icons.save,
                color: Colors.green),
              iconSize: 40, 
              onPressed: (){
                _capturePng();
                Navigator.of(context).push(MaterialPageRoute(
                    builder:(context)=> _neverSatisfied(),
                  )
                );
              },
            ),
            SizedBox(
              width: 200, 
            ),
            IconButton(
              icon: Icon(Icons.add_box,
              color: Colors.green),
              iconSize: 40, 
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(
                    builder:(context)=> EditScreen(),
                  )
                ).then((onValue)=>{
                  setState((){
                    if(onValue!=null){
                      _value=onValue;
                    }
                  })
                });
              } 
                ,
            ),
            Container(height: 75.0,)
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.settings_overscan),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class EditScreen extends StatefulWidget{
  @override
  _EditScreenState createState()=>_EditScreenState();
}

class _EditScreenState extends State<EditScreen>{
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new QR",
        textAlign: TextAlign.center,),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40,0, 40,0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                TextField(
                  controller: _controller,
                ),
                RaisedButton(
                  child: Text("Create"),
                  onPressed: (){
                    Navigator.of(context).pop(_controller.text);
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}




