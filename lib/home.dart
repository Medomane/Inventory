import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'Helpers/global.dart';
import 'Helpers/drawer.dart';
import 'Helpers/sqlite.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHome>{
  bool loaded = false;//,isManager =false;
  String title = "Inventaire";
  int touchedIndex;
  double firstTotal = 0, secondTotal = 0;
  var lineData = List<FlSpot>();
  var res1;
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
    Future.microtask(() async {
      res1 = await SqLite.getPieData();
      lineData =  await SqLite.getLine();
      //isManager = await MyGlobal.isManager();
      var name = await MyGlobal.getInventory();
      firstTotal = await SqLite.getMemberSum();
      secondTotal = await SqLite.getGroupSum();
      setState(() {
        loaded = true;
        title = "Inventaire : $name";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        drawer: AppDrawer(),
        /*bottomNavigationBar: isManager? BottomNavigationBar(
            onTap: (i){}, // new
            currentIndex: 0, // new
            items: [
              new BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: 'Artcles',
              ),
              new BottomNavigationBarItem(
                icon: Icon(Icons.supervised_user_circle),
                label: 'Equipe',
              ),
              new BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Home',
              )
            ],
          ) :SizedBox(height: 0.0),*/
        body: loaded?
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
                        Text("Total : $firstTotal article"+(firstTotal>1?"s":"")),
                      ],
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.fromLTRB(0,30,0,0),
                      child: LineChart(
                        LineChartData(
                          lineBarsData:linesBarData1(lineData),
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
                        Text("Total : $secondTotal article"+(secondTotal>1?"s":"")),
                      ],
                    ),
                    subtitle: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
                          setState(() {
                            if (pieTouchResponse.touchInput is FlLongPressEnd ||
                                pieTouchResponse.touchInput is FlPanEnd) {
                              touchedIndex = -1;
                            } else {
                              touchedIndex = pieTouchResponse.touchedSectionIndex;
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
          )
          :Center(child: CircularProgressIndicator())
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
    for (var t in res1) {
      final isTouched = i == touchedIndex;
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