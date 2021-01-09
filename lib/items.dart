import 'package:Inventory/itemDetail.dart';
import 'package:flutter/material.dart';
import 'package:responsive_table/responsive_table.dart';

import 'Helpers/func.dart';
import 'Helpers/drawer.dart';
import 'Helpers/sqlite.dart';

class Items extends StatefulWidget {
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  List<DatatableHeader> _headers = [
    DatatableHeader(
      text: "id",
      value: "id",
      show: false
    ),
    DatatableHeader(
      value: "reference",
      headerBuilder: (value) => Func.hTxt("Référence")
    ),
    DatatableHeader(
        value: "designation",
        headerBuilder: (value) => Func.hTxt("Désignation")
    ),
    DatatableHeader(
        value: "code",
        headerBuilder: (value) => Func.hTxt("Code")
    ),
    DatatableHeader(
        value: "family",
        headerBuilder: (value) => Func.hTxt("Famille")
    ),
    DatatableHeader(
      value: "num",
      headerBuilder: (value) => Func.hTxt("N°Lot/Serie")
    )
  ];
  bool _isSearch = false;
  List<Map<String, dynamic>> _source = List<Map<String, dynamic>>();
  bool _isLoading = true;
  int length = 20;
  final _searchController = TextEditingController();

  _initData(String str) async {
    setState(() => _isLoading = true);
    Future.delayed(Duration(seconds: 1)).then((value) async {
      _source.clear();
      var query = '''select 
        case WHEN length(reference) > $length THEN (substr(reference,0,$length) || ' ...') ELSE reference END reference ,
        case WHEN length(designation) > $length THEN (substr(designation,0,$length) || ' ...') ELSE designation END designation ,
        case WHEN length(num) > $length THEN (substr(num,0,$length) || ' ...') ELSE num END num ,
        case WHEN length(family) > $length THEN (substr(family,0,$length) || ' ...') ELSE family END family ,
        code,id from item''';
      if(!Func.isNull(str)) query += " WHERE code like '%" + str + "%' or reference like '%" + str + "%' or designation like '%" + str + "%' or num like '%" + str + "%' or family like '%" + str + "%' ";
      var data = await SqLite.select(query);
      _source.addAll(data);
      setState(() => _isLoading = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _initData(null);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Articles"),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: (MediaQuery. of(context).size.height)-80,
              ),
              child: Card(
                elevation: 1,
                shadowColor: Colors.black,
                clipBehavior: Clip.none,
                child: ResponsiveDatatable(
                  actions: [
                    if (_isSearch)
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              icon: Icon(Icons.cancel),
                              onPressed: () {
                                setState(() {
                                  _isSearch = false;
                                });
                              }
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                var str = _searchController.text.replaceAll(new RegExp(r"[^\s\w]"),'');
                                _initData(str);
                              }
                            )
                          ),
                        )
                      ),
                    if (!_isSearch)
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearch = true;
                          });
                        }
                      )
                  ],
                  headers: _headers,
                  source: _source,
                  autoHeight: false,
                  onTabRow: (data) => Navigator.push(context, MaterialPageRoute(builder:(context)=>Item(data["id"],false))),
                  isLoading: _isLoading,
                ),
              ),
            ),
          ]
        )
      )
    );
  }
}