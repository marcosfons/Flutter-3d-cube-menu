import 'dart:math';
import 'package:flutter/material.dart';
void main() => runApp(MyApp());
var x=0.0;
var y=0.0;
var h = 200.0;
var r = h / 2;
Offset offset = Offset.zero;
List<Color> cores = [
  Color.fromRGBO(61, 63, 76, 1),
  Color.fromRGBO(72, 81, 88, 1),
  Color.fromRGBO(88, 110, 107, 1),
  Color.fromRGBO(115, 142, 127, 1),
  Color.fromRGBO(149, 167, 145, 1),
  Color.fromRGBO(182, 194, 170, 1),
  Color.fromRGBO(228, 217, 197, 1),
  Color.fromRGBO(145, 114, 96, 1),
  Color.fromRGBO(124, 90, 80, 1),
  Color.fromRGBO(90, 58, 63, 1),
  Color.fromRGBO(51, 33, 49, 1),
  Color.fromRGBO(38, 16, 37, 1),
];
List<Face> faces = [
  Face(Page('Perfil', Icons.account_circle, Container(), cores[2]),calc1),
  Face(Page('Configurações', Icons.settings, Container(), cores[3]),calc2),
  Face(Page('Flutter', Icons.backup, Container(), cores[4]),calc3),
  Face(Page('Create', Icons.headset, Container(), cores[9]),calc4),
  Face(Page('Home', Icons.home, Container(), cores[8]), calc5),
  Face(Page('BRASIL', Icons.account_circle, Container(), cores[7]),calc6)
];
List calc6() => [-x+pi,pi,x,y-(pi/2),0.0];
List calc5() => [x,0.0,x,y-(pi/2),0.0];
List calc4() => [x,0.0,x-(pi/2),0.0,y];
List calc3() => [x,pi,x-(pi/2),0.0,y];
List calc2() => [-x+pi,pi,x,y,0.0];
List calc1() => [x,0.0,x,y,0.0];
Matrix4 frente = Matrix4.identity()..setEntry(3, 2, 0.001)..translate(h * sin(pi) * cos(0),h * sin(pi) * sin(0),h * cos(pi) - 50);
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3d Menu Cube',
      home: Menu()
    );
  }
}
class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}
class _MenuState extends State<Menu> {
  @override
  void initState() {
    super.initState();
    faces.map((face) => face.page.configure(click)).toList();
    faces.forEach(((face) => face.update()));
    faces..sort((a, b) => a.matriz.relativeError(frente).compareTo(b.matriz.relativeError(frente)));
  }
  click() => Navigator.of(context).pop();
  @override
  Widget build(BuildContext context) {
    x = offset.dx * 0.013;
    y = offset.dy * 0.013;
    faces.forEach(((face) => face.update()));
    faces..sort((a, b) => a.matriz.relativeError(frente).compareTo(b.matriz.relativeError(frente)));
    return GestureDetector(
      onPanUpdate: (dt) => setState(() { offset = Offset(offset.dx + dt.delta.dy, offset.dy - dt.delta.dx); }),
      onDoubleTap: () => setState(() { x=0;y=0; offset = Offset.zero; }),
      child: Scaffold(
        backgroundColor: cores[0],
        floatingActionButton: RaisedButton.icon(
          icon: Icon(faces[0].page.icon),
          label: Text(faces[0].page.tag),
          onPressed: () => Navigator.push(context, FacePageRoute(face: faces[0])),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Container(
                  height: h,
                  width: h,
                  child: Stack(
                    children: faces.reversed.map((face) => Transform(alignment: Alignment.center,transform: face.matriz,child: face.page.menor,)).toList().cast<Widget>(),
                  ),
                )
              )
            ),
          ],
        ),
      ),
    );
  }
}
class Page {
  String tag;
  var icon;
  Widget child;
  Color cor;
  Widget menor;
  Widget maior;
  var context;
  Function onPressed;
  Page(this.tag, this.icon, this.child, this.cor);
  void configure(Function click) {
    if(menor == null && maior == null) {
    menor = Container(
      height: h,
      width: h,
      color: this.cor,
      child: Icon(icon, size: h/3,),);
    
    maior = Container(
        height: double.infinity,
        width: double.infinity,
        child: Scaffold(
          backgroundColor: cor,
          body: ListView(
            children: <Widget>[
              Container(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(icon, size: 30,),
                  Text(tag, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  IconButton(icon: Icon(Icons.menu, size: 30), onPressed: click,)
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}
class Face {
  double teta;
  double fi;
  double rtX;
  double rtY;
  double rtZ;
  Matrix4 matriz;
  Page page;
  Function calc;
  Face(this.page, this.calc);
  void update() {
    List result = this.calc();
     matriz = Matrix4.identity()
    ..setEntry(3, 2, 0.001)
    ..rotateX(result[2])
    ..rotateY(result[3])
    ..rotateZ(result[4])
    ..translate(
      r * sin(result[1]) * cos(result[0]),
      r * sin(result[1]) * sin(result[0]),
      r * cos(result[1])
    );
  }
}
class FacePageRoute extends PageRouteBuilder {
  final Face face;
  FacePageRoute({this.face}) : super(
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return Scaffold(backgroundColor: cores[6], body: face.page.maior);
    },
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      return ScaleTransition(scale: animation, child: child,);
    }
  );
}
class ScaleMatrixTransition extends AnimatedWidget {
  const ScaleMatrixTransition({
    Key key,
    @required Animation<double> scale,
    this.child,
  }) : assert(scale != null),
       super(key: key, listenable: scale);
  Animation<double> get scale => listenable;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final double scaleValue = scale.value;
    return Transform(
      transform: Matrix4.identity()
        ..scale(0.8 * scaleValue + 0.2, 0.8 * scaleValue + 0.2, 1),
      alignment: Alignment.center,
      child: child,
    );
  }
}