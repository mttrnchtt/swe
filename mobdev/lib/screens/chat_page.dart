import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String chatId; // Chat ID, passed from navigation
  final String userId; // Current user ID
  final String receiverId; // ID of the user being chatted with

  const ChatPage({
    required this.chatId,
    required this.userId,
    required this.receiverId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  // Dummy message list (Replace with database data)
  List<Map<String, dynamic>> messages = [
    {'senderId': 'user1', 'message': 'Hello!', 'timestamp': DateTime.now()},
    {
      'senderId': 'user2',
      'message': 'Hi, how can I help?',
      'timestamp': DateTime.now()
    },
  ];

  // Function to send a message
  void sendMessage(String message) {
    final newMessage = {
      'senderId': widget.userId,
      'message': message,
      'timestamp': DateTime.now(),
    };

    // Update local state
    setState(() {
      messages.add(newMessage);
    });

    // Send message to database (mock code; replace with actual DB logic)
    print('Saving message to DB: $newMessage');

    // Clear the input field
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              reverse: true, // Display newest messages at the bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isMe = message['senderId'] == widget.userId;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color:
                          isMe ? Colors.green.shade200 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(message['message']),
                  ),
                );
              },
            ),
          ),

          // Message Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      sendMessage(_messageController.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
