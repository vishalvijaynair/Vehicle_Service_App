import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class RatingSubmissionPage extends StatefulWidget {
  final String userEmail;

  const RatingSubmissionPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _RatingSubmissionPageState createState() => _RatingSubmissionPageState();
}

class _RatingSubmissionPageState extends State<RatingSubmissionPage> {
  double rate = 0;
  bool hasExistingRating = false;
  double existingRating = 0;

  @override
  void initState() {
    super.initState();
    // Check if the service center already has a rating
    FirebaseFirestore.instance
        .collection('Service_Centres')
        .doc(widget.userEmail)
        .get()
        .then((doc) {
      if (doc.exists && doc.data()!['rate'] != null) {
        setState(() {
          hasExistingRating = true;
          existingRating = doc.data()!['rate'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Rating'),
        backgroundColor: Color.fromARGB(255, 207, 173, 210),
      ),
body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Rate your experience:',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      RatingBar.builder(
        initialRating: rate,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: 50.0,
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (newRating) {
          setState(() {
            rate = newRating;
          });
        },
      ),
      SizedBox(height: 20), // Add space between rating bar and button
      ElevatedButton(
        onPressed: () {
          double newRatingValue = hasExistingRating
              ? (existingRating + rate) / 2
              : rate;
          FirebaseFirestore.instance
              .collection('Service_Centres')
              .doc(widget.userEmail)
              .update({'rate': newRatingValue})
              .then((value) => print('Rating updated successfully'))
              .catchError((error) => print('Failed to update rating: $error'));
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: Colors.purple.withOpacity(0.9),
        ),
        child: Text(
          "Submit Rating",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ],
  ),
),

    );
  }
}
