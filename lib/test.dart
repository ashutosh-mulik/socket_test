import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_test/stream_socket.dart';

class ChatView extends StatefulWidget {
  final StreamSocket streamSocket = StreamSocket();
  final IO.Socket socket = IO.io(
      'https://socket-test-node-test.herokuapp.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build());
  final List<String> entries = <String>[];

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    _connect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(),
            SingleChildScrollView(
              child: StreamBuilder(
                stream: widget.streamSocket.getResponse,
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    widget.entries.add(snapshot.data!);
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.entries.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(widget.entries[index]),
                        );
                      },
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _connect() {
    widget.socket.onConnect((_) {
      print("isConnected : ${widget.socket.connected}");
    });

    widget.socket.onConnectError((data) {
      print("Error : $data");
    });

    widget.socket.onConnectTimeout((data) => print("Timeout : $data"));

    widget.socket.on(
      'message',
      (data) {
        print(data);
        widget.streamSocket.addResponse(data);
      },
    );

    widget.socket.onDisconnect((_) => print('disconnect'));
    widget.socket.on('fromServer', (_) => print(_));

    widget.socket.connect();
  }
}
