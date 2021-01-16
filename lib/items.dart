import 'package:Inventory/Helpers/global.dart';
import 'package:flutter/material.dart';
import 'package:responsive_table/responsive_table.dart';

import 'Helpers/drawer.dart';
import 'Helpers/func.dart';
import 'Helpers/sqlite.dart';
import 'Models/User.dart';
import 'Models/Item.dart';
import 'itemDetail.dart';

class Items extends StatefulWidget {
  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  Widget _drawer ;
  List<Map<String, dynamic>> _list;
  List<DatatableHeader> _headers;
  bool _isSearch,_isLoading;
  TextEditingController _searchController ;

  _ItemsState(){
    _drawer = Divider(color: Colors.transparent,height: 0);
    _list = List<Map<String, dynamic>>();
    _isSearch = false;
    _isLoading = true;
    _searchController = TextEditingController();
    _headers = [
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
      ),
      DatatableHeader(
          value: "sellingPrice",
          headerBuilder: (value) => Func.hTxt("Prix de vente")
      ),
      DatatableHeader(
          value: "inStock",
          headerBuilder: (value) => Func.hTxt("En stock")
      ),
      DatatableHeader(
          value: "buyingPrice",
          headerBuilder: (value) => Func.hTxt("Prix d'achat")
      )
    ];
  }

  _initData(String str) async {
    setState(() => _isLoading = true);
    _list.clear();
    Future.microtask(() async {
      var query = '''select id,code,
        case WHEN length(reference) > ${MyGlobal.maxLength} THEN (substr(reference,0,${MyGlobal.maxLength}) || ' ...') ELSE reference END reference ,
        case WHEN length(designation) > ${MyGlobal.maxLength} THEN (substr(designation,0,${MyGlobal.maxLength}) || ' ...') ELSE designation END designation ,
        case WHEN length(num) > ${MyGlobal.maxLength} THEN (substr(num,0,${MyGlobal.maxLength}) || ' ...') ELSE num END num ,
        case WHEN length(family) > ${MyGlobal.maxLength} THEN (substr(family,0,${MyGlobal.maxLength}) || ' ...') ELSE family END family ,
        sellingPrice,buyingPrice,inStock from item''';
      if(!Func.isNull(str)) query += " WHERE code like '%" + str + "%' or reference like '%" + str + "%' or designation like '%" + str + "%' or num like '%" + str + "%' or family like '%" + str + "%' ";
      var data = await SqLite.select(query);
      var user = await User.get();
      if(!Item.showBuyingPrice(user)) _headers.removeLast();
      _list.addAll(data);
      _drawer = AppDrawer(user);
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
      drawer: _drawer,
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
                    _isSearch?
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
                      ):
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
                  source: _list,
                  autoHeight: false,
                  onTabRow: (data) => Navigator.push(context, MaterialPageRoute(builder:(context)=>ItemPage(action: ItemAction.ShowDetail,id: data["id"],))),
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