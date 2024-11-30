import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _HomePageState();
}

class _HomePageState extends State<ChatBotScreen> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  // User data setup
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Jack",
    profileImage:
    "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Bot"),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(
        trailing: [
          IconButton(
            onPressed: _sendMediaMessage,
            icon: const Icon(Icons.image),
          ),
        ],
      ),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  // Function to handle sending messages and interacting with Gemini AI
  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });

    try {
      String question = chatMessage.text;
      List<Uint8List>? images;

      // If the message contains an image, fetch and convert it to bytes
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }

      // Send message to Gemini for generating content
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen(
            (event) {
          String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous ${current.text}") ??
              "";

          if (response.isNotEmpty) {
            _addBotMessage(response);
          } else {
            print("No response from Gemini.");
          }
        },
        onError: (error) {
          print("Error from Gemini: $error");
        },
      );
    } catch (e) {
      print("Error in sending message: $e");
    }
  }

  // Function to add the bot's response
  void _addBotMessage(String response) {
    ChatMessage message = ChatMessage(
      user: geminiUser,
      createdAt: DateTime.now(),
      text: response,
    );
    setState(() {
      messages = [message, ...messages];
    });
  }

  // Function to pick an image and send it to the bot
  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          ),
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}