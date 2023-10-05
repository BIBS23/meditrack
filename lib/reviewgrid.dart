import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewGrid extends StatelessWidget {
  final String docid;
  const ReviewGrid({super.key, required this.docid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .doc(docid)
            .collection('reviews')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews yet'));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot documentSnapshot = snapshot.data!.docs[index];
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: documentSnapshot['userprof'] != ''
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(documentSnapshot['userprof']),
                            radius: 20)
                        : CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 20,
                            child: Text(
                              documentSnapshot['firstletter'],
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            )),
                    title: Text(documentSnapshot['username']),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(documentSnapshot['review'],textAlign: TextAlign.justify,style: const TextStyle(fontSize: 14)),
                    ),
                    trailing: Text(documentSnapshot['date'],style: const TextStyle(fontSize: 12)),
                  ));
            },
          );
        });
  }
}