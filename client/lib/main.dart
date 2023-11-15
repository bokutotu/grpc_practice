import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';
import 'package:client/generated/chat.pb.dart';
import 'package:client/generated/chat.pbgrpc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatPage(),
    );
  }
}

class ChatClient {
  late ChatServiceClient stub;

  Future<void> connect() async {
    final channel = ClientChannel(
      'localhost',
      port: 50051,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    stub = ChatServiceClient(channel);
  }

  Stream<ChatMessage> chat(String user, String message) async* {
    final request = Stream<ChatMessage>.fromIterable([
      ChatMessage()
        ..user = user
        ..message = message,
    ]);

    await for (var message in stub.chat(request)) {
      yield message;
    }
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  final ChatClient _chatClient = ChatClient();

  @override
  void initState() {
    super.initState();
    _connectToServer();
  }

  Future<void> _connectToServer() async {
    await _chatClient.connect();
  }

  void _sendMessage() {
    final text = _controller.text;
    _controller.clear();
    _chatClient.chat('user123', text).listen((message) {
      setState(() {
        _messages.add('${message.user}: ${message.message}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:client/generated/hello.pbgrpc.dart';
// import 'package:flutter/material.dart';
// import 'package:grpc/grpc.dart';
// import 'package:client/generated/chat.pb.dart';
// import 'package:client/generated/chat.pbgrpc.dart';
//
// class ChatClient {
//   late ChatServiceClient stub;
//
//   Future<void> connect() async {
//     final channel = ClientChannel(
//       'localhost',
//       port: 50051,
//       options: const ChannelOptions(
//         credentials: ChannelCredentials.insecure(),
//       ),
//     );
//     stub = ChatServiceClient(channel);
//   }
//
//   Stream<ChatMessage> chat(String user) async* {
//     final request = Stream<ChatMessage>.fromIterable([
//       ChatMessage()
//         ..user = user
//         ..message = 'Hello from Flutter!',
//     ]);
//
//     await for (var message in stub.chat(request)) {
//       yield message;
//     }
//   }
// }
//
// void main() async {
//   final chatClient = ChatClient();
//   await chatClient.connect();
//
//   final chatStream = chatClient.chat('user123');
//   chatStream.listen((message) {
//     print('Received: ${message.message}');
//   });
//   
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   void init() {
//     final channel = ClientChannel(
//       'localhost',
//       port: 50051,
//       options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
//     );
//
//     final stub = HelloServiceClient(channel);
//
//     stub.sayHello(HelloRequest()..name = 'まんこ').then((response) {
//       print('Greeter client received: ${response.message}');
//     }).catchError((e) {
//       print('Caught error: $e');
//     }).whenComplete(() {
//       channel.shutdown();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     init();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
