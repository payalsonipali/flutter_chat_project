import 'dart:io';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:chatting_app/shared_preference.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final String chatRoomId, name;

  ChatRoom({required this.chatRoomId, required this.name});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late SharedPreferences sharedPreferences;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) async {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore.collection(widget.chatRoomId).doc(fileName).set({
      "sender": sharedPreferences.getString("email"),
      "message": "",
      "type": "img",
      "timestamp": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore.collection(widget.chatRoomId).doc(fileName).delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection(widget.chatRoomId)
          .doc(fileName)
          .update({"message": imageUrl});
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sender": sharedPreferences.getString("email"),
        "message": _message.text,
        "type": "text",
        "timestamp": FieldValue.serverTimestamp(),
      };
      await _firestore.collection(widget.chatRoomId).add(messages);
      _message.clear();
    } else {
      print("Enter Some Text");
    }
  }

  @override
  void initState() {
    super.initState();
    sharedPreferences = SharedPref.instance;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xfff7f7f7),
          appBar: AppBar(
            elevation: 0,
            toolbarHeight: 80,
            primary: false,
            automaticallyImplyLeading: false,
            actions: [
              StreamBuilder<DocumentSnapshot>(
                stream:
                    _firestore.collection("users").doc(widget.name).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black,
                                  spreadRadius: 20,
                                  blurRadius: 1)
                            ]),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              BouncingWidget(
                                onPressed: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.name,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
            backgroundColor: Color(0xffF4F4F5),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  width: size.width,
                  color: Color(0xfff7f7f7),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection(widget.chatRoomId)
                        .orderBy("timestamp", descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.data != null) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> map =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return messages(size, map, context);
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 66,
                width: size.width,
                child: Wrap(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 5)
                        ],
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => getImage(),
                            child: Container(
                              height: 30,
                              width: 40,
                              child: Icon(
                                Icons.attach_file_rounded,
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: TextField(
                                controller: _message,
                                style: TextStyle(fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                    hintText: "Send Message",
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintStyle:
                                        TextStyle(fontWeight: FontWeight.w600),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 12),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    )),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: onSendMessage,
                            child: Container(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.only(left: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
            width: size.width,
            alignment: map['sender'] == sharedPreferences.getString("email")
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(1),
                ),
                color: Colors.blue,
              ),
              child: Text(
                map['message'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: map['sender'] == sharedPreferences.getString("email")
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['message'],
                  ),
                ),
              ),
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                alignment: map['message'] != "" ? null : Alignment.center,
                child: map['message'] != ""
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          map['message'],
                          fit: BoxFit.cover,
                        ),
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: size.height,
            width: size.width,
            color: Colors.black,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BouncingWidget(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.clear_rounded,
                            size: 30,
                            color: Colors.white,
                          )),
                      BouncingWidget(
                          onPressed: () {},
                          child: Icon(Icons.download_rounded,
                              size: 30, color: Colors.white))
                    ],
                  ),
                ),
                Center(child: Image.network(imageUrl)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
