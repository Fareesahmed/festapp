import 'package:av_app/styles/Styles.dart';
import 'package:av_app/widgets/HtmlDescriptionWidget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/NewsMessage.dart';
import '../services/DataService.dart';
import 'HtmlEditorPage.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsMessage> newsMessages = [];
  final TextEditingController _messageController = TextEditingController();

  void _showMessageDialog(BuildContext context) {
    Navigator.pushNamed(context, HtmlEditorPage.ROUTE, arguments: null).then((value) async {
      if(value != null)
      {
        var message = value as String;
        await sendMessage(message);
        _messageController.clear();
      }
    });
  }

  Future<void> sendMessage(String message) async {
    await DataService.insertNewsMessage(message);
    await loadNewsMessages();
  }

  Future<void> loadNewsMessages() async {
    setState(() {
      newsMessages = [];
    });
    var loadedMessages = await DataService.loadNewsMessages();
    setState(() {
      newsMessages = loadedMessages;
    });

    DataService.setMessagesAsRead(newsMessages.first.id);
  }

  @override
  void initState() {
    super.initState();
    loadNewsMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ohlášky'),
      ),
      body: ListView.builder(
        itemCount: newsMessages.length,
        itemBuilder: (BuildContext context, int index) {
          final message = newsMessages[index];
          final previousMessage = index > 0 ? newsMessages[index - 1] : null;

          final isSameDay = previousMessage != null &&
              message.createdAt.year == previousMessage.createdAt.year &&
              message.createdAt.month == previousMessage.createdAt.month &&
              message.createdAt.day == previousMessage.createdAt.day;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (index != 0 && !isSameDay)
                const Divider(),
              if (index == 0 || !isSameDay)
                Container(
                  padding: const EdgeInsets.only(top: 8.0, right: 16.0, left: 16.0),
                  alignment: Alignment.topRight,
                  child: Text(
                    DateFormat("EEEE d.M.y", "cs").format(message.createdAt),
                    style: message.isRead?readTextStyle:unReadTextStyle,
                  ),
                ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(message.createdBy, style: message.isRead?readTextStyle:unReadTextStyle,)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Container(
                  //color: Colors.white70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: primaryBlue1.withOpacity(0.10)
                  ),
                  //color: Colors.white70,
                  child: Padding(padding: const EdgeInsets.all(16), child: HtmlDescriptionWidget(html: message.message)),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Visibility(
        visible: DataService.isLoggedIn(),
        child: FloatingActionButton(
          onPressed: () => _showMessageDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
  TextStyle unReadTextStyle = const TextStyle(fontWeight: FontWeight.bold);
  TextStyle readTextStyle = const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54);

}