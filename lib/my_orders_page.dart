  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hellogram/my_orders_page2.dart';

  class MyOrdersPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Orders'),
          backgroundColor: Color.fromARGB(255, 182, 200, 247),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Orders_pending')
              .doc(FirebaseAuth.instance.currentUser!.email)
              .collection('orders')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

   if (snapshot.hasError) {
        print('Error retrieving orders: ${snapshot.error}');
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      final orders = snapshot.data!.docs;
      

      if (orders.isEmpty) {
        return Center(
          child: Text(
            'You have no orders',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      }

      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final orderData = orders[index].data() as Map<String, dynamic>;

         // Accessing order details
          String userEmail = orders[index].id; // Using document ID as user email
          String Ordered_date = orderData['orderedDate'];
          String Ordered_time = orderData['orderedTime'];
          String totalAmount = orderData['totalAmount'].toString(); // Ensure it's converted to String
          List<dynamic> selectedServicesList = orderData['selectedServices'];
          String selectedServices = selectedServicesList.join(', ');

          return ListTile(
            title: Text('Order ${index + 1}',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ordered Date: $Ordered_date',
                  style: TextStyle(fontSize: 16),
                ),
                 Text(
                  'Ordered Time: $Ordered_time',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'totalAmount: $totalAmount',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'selectedServices: $selectedServices',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Service Centre Email: $userEmail',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            onTap: () {
               Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyOrdersPage1()),
                  );
            },
          );
        },
);
          },
        ),
      );
    }
  }