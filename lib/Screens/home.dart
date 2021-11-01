// ignore_for_file: prefer_const_constructors, await_only_futures, unused_local_variable, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertodo/Screens/add_task.dart';
import 'package:fluttertodo/Screens/description.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid = "";
  @override
  void initState() {
    getUid();
    super.initState();
  }

  getUid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = await auth.currentUser!;
    setState(() {
      uid = user.uid;
      print(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TO-DO"),
        actions: [
          IconButton(icon: Icon(Icons.logout),onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },)
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .doc(uid)
                .collection('myTasks')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.requireData;
              return ListView.builder(
                  itemCount: docs.size,
                  itemBuilder: (context, index) {
                    var time = (docs.docs[index]['timeStamp'] as Timestamp).toDate();
                    return InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Description(title: docs.docs[index]['title'], description: docs.docs[index]['desc'])));
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                            color: Color(0xff121211),
                            borderRadius: BorderRadius.circular(10)),
                        height: 90,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  child: Text(
                                    docs.docs[index]['title'],
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Container(
                                  margin: EdgeInsets.only(left: 20),
                                  child: Text(DateFormat.yMd().add_jm().format(time)),)
                              ],
                            ),
                            Container(
                              child: IconButton(
                                icon: Icon(Icons.delete,color: Colors.red,),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                  .collection('tasks')
                                  .doc(uid)
                                  .collection('myTasks')
                                  .doc(docs.docs[index]['time'])
                                  .delete();
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTask()));
        },
      ),
    );
  }
}
