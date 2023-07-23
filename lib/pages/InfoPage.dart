import 'package:av_app/services/DataService.dart';
import 'package:flutter/material.dart';
import '../models/InformationModel.dart';
import '../widgets/HtmlDescriptionWidget.dart';

class InfoPage extends StatefulWidget {
  static const ROUTE = "/info";
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List<InformationModel>? _information;
  _InfoPageState();

  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Informace"),
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList(
          expansionCallback: (panelIndex, isExpanded) {
            _information!.forEach((element) { element.isExpanded = false; });
            _information![panelIndex].isExpanded = !isExpanded;
            setState(() {
            });

          },
          children:
            _information == null ? [] : _information!.map<ExpansionPanel>((InformationModel item) {
              return ExpansionPanel(
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: Text(item.title),
                  );
                },
                body: Padding(
                  padding: const EdgeInsetsDirectional.all(12),
                  child: HtmlDescriptionWidget(html: item.description!),
                ),
                  isExpanded: item.isExpanded,
                  canTapOnHeader: true
              );
            }).toList(),
        ),
      ),
    );
  }

  Future<void> loadData() async {
    _information = await DataService.getInformation();
    setState(() {});
  }
}