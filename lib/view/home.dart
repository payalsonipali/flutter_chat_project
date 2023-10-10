import 'package:chatting_app/services/authentication_service.dart';
import 'package:chatting_app/view/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  Home({Key? key});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> with WidgetsBindingObserver {
  String chatRoomId(String user1, String user2) {
    int comparison = user1.compareTo(user2);
    if (comparison < 0) {
      return "$user1&$user2";
    } else {
      return "$user2&$user1";
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Friends'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout), // You can change the icon as needed.
            onPressed: () async {
              await AuthenticationService(context).signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<String>>(
          future: getChatList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Text('No Friends available.'),
              );
            } else {
              var data = snapshot.data as List<String>;
              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () async {
                      SharedPreferences sharedPreference = await SharedPreferences.getInstance();
                      String roomId = chatRoomId(
                          sharedPreference.getString("email")!,
                          data[index]);
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (_) => ChatRoom(
                            chatRoomId: roomId,
                            name: data[index],
                          ),
                        ),
                      ).then((flag) {
                      });
                    },
                    child:Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.02),
                            blurRadius: 5, // soften the shadow
                            spreadRadius: 3, //extend the shadow
                          )
                        ],
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                      ),
                      child: Text(data[index]),
                    )
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 8,
                    thickness: 0,
                    color: Colors.transparent,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<String>> getChatList() async {
    try {
      SharedPreferences sharedPreference = await SharedPreferences.getInstance();
      String myEmail = sharedPreference.getString("email") ?? "";

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isNotEqualTo: myEmail)
          .get();

      List<String> userEmails = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data['email'] as String;
      }).toList();

      return userEmails;
    } catch (e) {
      return [];
    }
  }
}
