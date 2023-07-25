import 'package:av_app/dataGrids/SingleTableDataGrid.dart';
import 'package:av_app/models/PlaceModel.dart';
import 'package:av_app/services/DataGridHelper.dart';
import 'package:av_app/services/DataService.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../models/EventModel.dart';
import 'HtmlEditorPage.dart';
import 'ModelInformation.dart';

class AdministrationPage extends StatefulWidget {
  static const ROUTE = "/admin";
  const AdministrationPage({Key? key}) : super(key: key);

  @override
  _AdministrationPageState createState() => _AdministrationPageState();
}

class _AdministrationPageState extends State<AdministrationPage> {
  List<InformationModel>? informationData;
  late PlutoGridStateManager stateManager;
  List<String?> places = [];
  List<PlutoColumn> columns = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    var placesRaws =  await DataService.getPlaces();
    var placesStrings = placesRaws.map((p)=>p.toString()).toList();
    placesStrings.add(PlaceModel.WithouPlace);
    places = placesStrings;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
          title: const Text("Admin"),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                  isScrollable: true,
                tabs: [
                  Row(
                  children: [
                    Icon(Icons.info),
                    Padding(padding: EdgeInsets.all(12), child: Text("Info"))
                  ]
                ),
                  Row(
                      children: [
                        Icon(Icons.calendar_month),
                        Padding(padding: EdgeInsets.all(12), child: Text("Události"))
                      ]
                  )
                ]
              ),
            ),
          )),
        body: TabBarView(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child:
                  SingleTableDataGrid<InformationModel>(
                      DataService.getInformation,
                      InformationModel.fromPlutoJson,
                      [
                    PlutoColumn(
                        title: "",
                        field: "delete",
                        type: PlutoColumnType.text(),
                        readOnly: true,
                        enableFilterMenuItem: false,
                        enableSorting: false,
                        enableDropToResize: false,
                        enableColumnDrag: false,
                        enableContextMenu: false,
                        cellPadding: EdgeInsets.zero,
                        width: 40,
                        renderer: (rendererContext) {
                          return IconButton(
                              onPressed: () async{
                                final informationId = rendererContext.row.cells[InformationModel.idColumn]?.valueForSorting;
                                if (informationId == null){
                                  stateManager.removeRows([rendererContext.row]);
                                  return;
                                }
                                setState(() {
                                  rendererContext.row.setState(rendererContext.row.state == PlutoRowState.none ? PlutoRowState.added : PlutoRowState.none);
                                });
                              },
                              icon: const Icon(Icons.delete_forever));
                        }),
                    PlutoColumn(
                        title: "Id",
                        field: InformationModel.idColumn,
                        type: PlutoColumnType.number(),
                        readOnly: true,
                        hide: true),
                    PlutoColumn(
                        title: "Nadpis",
                        field: InformationModel.titleColumn,
                        type: PlutoColumnType.text()),
                    PlutoColumn(
                        width: 150,
                        title: "Popis",
                        field: InformationModel.descriptionColumn,
                        type: PlutoColumnType.text(),
                        renderer: (rendererContext) {
                          return ElevatedButton(
                              onPressed: () async{
                                var oldText = rendererContext.row.cells[InformationModel.descriptionColumn]?.value;
                                Navigator.pushNamed(context, HtmlEditorPage.ROUTE, arguments: oldText).then((value) async {
                                  if(value != null)
                                  {
                                    var newText = value as String;
                                    if(newText!=oldText)
                                    {
                                      rendererContext.row.cells[InformationModel.descriptionColumn]?.value = newText;
                                      setState(() {
                                        rendererContext.row.setState(PlutoRowState.updated);
                                      });
                                    }
                                  }
                                });},
                              child: const Row(children: [Icon(Icons.edit), Padding(padding: EdgeInsets.all(6), child: Text("Editovat")) ])
                          );
                        }),
                  ]).DataGrid()
              ),
            Container(
                padding: const EdgeInsets.all(12),
                child:
                SingleTableDataGrid<EventModel>(
                    DataService.getEventsWithPlaces,
                    EventModel.fromPlutoJson,
                    [
                      PlutoColumn(
                          title: "",
                          field: "delete",
                          type: PlutoColumnType.text(),
                          readOnly: true,
                          enableFilterMenuItem: false,
                          enableSorting: false,
                          enableDropToResize: false,
                          enableColumnDrag: false,
                          enableContextMenu: false,
                          cellPadding: EdgeInsets.zero,
                          width: 40,
                          renderer: (rendererContext) {
                            return IconButton(
                                onPressed: () async{
                                  final informationId = rendererContext.row.cells[EventModel.idColumn]?.valueForSorting;
                                  if (informationId == null){
                                    stateManager.removeRows([rendererContext.row]);
                                    return;
                                  }
                                  setState(() {
                                    rendererContext.row.setState(rendererContext.row.state == PlutoRowState.none ? PlutoRowState.added : PlutoRowState.none);
                                  });
                                },
                                icon: const Icon(Icons.delete_forever));
                          }),
                      PlutoColumn(
                          title: "Id",
                          field: EventModel.idColumn,
                          type: PlutoColumnType.number(),
                          readOnly: true,
                          hide: true),
                      PlutoColumn(
                          title: "Nadpis",
                          field: EventModel.titleColumn,
                          type: PlutoColumnType.text(),
                          width: 300
                      ),
                      PlutoColumn(
                          title: "Datum začátku",
                          field: EventModel.startDateColumn,
                          type: PlutoColumnType.date(),
                          width: 120,
                      ),
                      PlutoColumn(
                          title: "Začátek",
                          field: EventModel.startTimeColumn,
                          type: PlutoColumnType.time(),
                          width: 70,
                      ),
                      PlutoColumn(
                        title: "Datum konce",
                        field: EventModel.endDateColumn,
                        type: PlutoColumnType.date(),
                        width: 120,
                      ),
                      PlutoColumn(
                        title: "Konec",
                        field: EventModel.endTimeColumn,
                        type: PlutoColumnType.time(),
                        width: 70,
                    ),
                      PlutoColumn(
                        title: "Max",
                        field: EventModel.maxParticipantsColumn,
                        type: PlutoColumnType.number(negative: false, defaultValue: null),
                        width: 70,
                      ),
                      PlutoColumn(
                        title: "Místo",
                        field: EventModel.placeColumn,
                        type: PlutoColumnType.select(places),
                        applyFormatterInEditing: true,
                        formatter: DataGridHelper.GetValueFromFormatted,
                      ),
                      PlutoColumn(
                          width: 150,
                          title: "Popis",
                          field: EventModel.descriptionColumn,
                          type: PlutoColumnType.text(),
                          renderer: (rendererContext) {
                            return ElevatedButton(
                                onPressed: () async{
                                  var oldText = rendererContext.row.cells[EventModel.descriptionColumn]?.value;
                                  Navigator.pushNamed(context, HtmlEditorPage.ROUTE, arguments: oldText).then((value) async {
                                    if(value != null)
                                    {
                                      var newText = value as String;
                                      if(newText!=oldText)
                                      {
                                        rendererContext.row.cells[EventModel.descriptionColumn]?.value = newText;
                                        setState(() {
                                          rendererContext.row.setState(PlutoRowState.updated);
                                        });
                                      }
                                    }
                                  });},
                                child: const Row(children: [Icon(Icons.edit), Padding(padding: EdgeInsets.all(6), child: Text("Editovat")) ])
                            );
                          }),
                    ]).DataGrid()
            ),
          ]
        ),
      ),
    );
  }


}