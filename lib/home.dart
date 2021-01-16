import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'Helpers/global.dart';
import 'Helpers/drawer.dart';
import 'Models/Product.dart';
import 'Models/User.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHome>{
  Widget _drawer ;
  String _title;

  bool _loaded,_isNormal;
  int _touchedIndex;
  double _firstTotal, _secondTotal;
  var _lineData, _pieData;

  _MyHomePageState(){
    _title = "Accueil";
    _drawer = Divider(color: Colors.transparent,height: 0);
  }

  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  void dispose() {
    super.dispose();
  }
  void init(){
    setState(() {
      _loaded = false;
    });
    Future.microtask(() async {
      var user = await User.get();
      _isNormal = user.isNormal();
      _pieData = await Product.getPieData();
      _lineData =  await Product.getLine();
      _firstTotal = await Product.getMemberSum();
      _secondTotal = await Product.getGroupSum();
      _drawer = AppDrawer(user);
      if(!_isNormal) _title = "Inventaire : ${(await (await user.team()).inventory()).caption}";
      setState(() {
        _loaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      drawer: _drawer,
      body: _loaded?
        !_isNormal ?
          SingleChildScrollView(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: ListTile(
                title: Column(
                  children: [
                    Text("Nombre d'article par jour"),
                    Text("Total : $_firstTotal article"+(_firstTotal>1?"s":"")),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.fromLTRB(0,30,0,0),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      lineBarsData:linesBarData1(_lineData),
                      titlesData: FlTitlesData(
                          bottomTitles: SideTitles(
                            showTitles: true,
                            /*reservedSize: 22,*/
                            getTextStyles: (value) => const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            /*getTitles: (value) {
                            var val = value.toInt();
                            var toShow = '';
                            var day = DateFormat('d').format(DateTime.fromMillisecondsSinceEpoch(val * 1000));
                            if(titles.indexOf(val) >= 0) return null;
                            else {
                              print(val);
                              titles.add(val);
                              return '$day';
                            }
                            print(titles.indexOf(val));
                            return toShow;
                          },*/
                          ),
                          leftTitles: SideTitles(showTitles: false)
                      ),
                      gridData: FlGridData(show: false,),
                      borderData: FlBorderData(
                        border: const Border(
                          bottom: BorderSide(
                            color: Colors.lightBlue,
                          ),
                          left: BorderSide(
                            color: Colors.transparent,
                          ),
                          right: BorderSide(
                            color: Colors.transparent,
                          ),
                          top: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Column(
                  children: [
                    Text("Nombre d'article par membre d'équipe :"),
                    Text("Total : $_secondTotal article"+(_secondTotal>1?"s":"")),
                  ],
                ),
                subtitle: PieChart(
                  PieChartData(
                      pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse.touchInput is FlLongPressEnd ||
                              pieTouchResponse.touchInput is FlPanEnd) {
                            _touchedIndex = -1;
                          } else {
                            _touchedIndex = pieTouchResponse.touchedSectionIndex;
                          }
                        });
                      }),
                      startDegreeOffset: 180,
                      borderData: FlBorderData(
                        show: false,
                      ),
                      centerSpaceRadius: 50,
                      sections: getPie()
                  ),
                ),
              ),
            )
          ]
        ),
      ):
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15.0),
                Text("Bienvenue",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),textAlign: TextAlign.center,),
                SizedBox(height: 15.0),
                Image(
                  image: AssetImage("images/homeImg.png"),
                  fit: BoxFit.fill,
                )
              ],
            ),
          ) :
        Center(child: CircularProgressIndicator())
    );
  }

  List<LineChartBarData> linesBarData1(data) {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: data,
      isCurved: true,
      colors: [Colors.blue,],
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    return [lineChartBarData1,];
  }
  List<PieChartSectionData> getPie(){
    TextStyle ts = TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: Colors.black);
    var data = List<PieChartSectionData>();
    int i = 0;
    for (var t in _pieData) {
      final isTouched = i == _touchedIndex;
      final double radius = isTouched ? 75 : 70;
      if(i == MyGlobal.colorsList().length) i = 0;
      data.add(PieChartSectionData(
        color: MyGlobal.colorsList()[i],
        value: double.parse('${t["quantity"]}'),
        radius: radius,
        title: isTouched?'${t["quantity"]}':t["username"],
        titleStyle: ts,
      ));
      i++;
    }
    return data;
  }
}