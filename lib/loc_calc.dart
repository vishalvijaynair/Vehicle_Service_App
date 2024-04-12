import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
class LocationCalculation {
  Future<void> calculateAndStoreDistance() async {
    try {
      // Get the current user's email
      String? email = FirebaseAuth.instance.currentUser?.email;

      // Informative message if user is not logged in
      if (email == null) {
        print('Error: User is not logged in. Distance calculation requires valid user location data.');
        return;  // Early exit if user is not logged in
      }

      print('User email: $email');

      // Get a reference to the user's document in Firestore
      DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(email);

      try {
        // Retrieve the user's document
        DocumentSnapshot userSnapshot = await userRef.get();

        // Check if user document exists and has valid latitude/longitude data
        if (userSnapshot.exists) {
          double userLatitude = userSnapshot['latitude'];
          double userLongitude = userSnapshot['longitude'];

          print('User latitude: $userLatitude, longitude: $userLongitude');

          // Get a reference to the 'Service_Centres' collection
          CollectionReference serviceCentersCollection = FirebaseFirestore.instance.collection('Service_Centres');

          // Retrieve the documents from the 'Service_Centres' collection
          QuerySnapshot serviceCentersSnapshot = await serviceCentersCollection.get();

          // Create an instance of the Haversine class

          // Iterate over each document in the 'Service_Centres' collection
         await Future.forEach(serviceCentersSnapshot.docs, (DocumentSnapshot doc) async {
  try {
    // Get service center's latitude and longitude
    double centerLat = doc['locValue']['latitude'];
    double centerLong = doc['locValue']['longitude'];

    print('Service center ${doc.id} latitude: $centerLat, longitude: $centerLong');

    // Calculate distance between user and service center using the Haversine formula (in meters)
    double distanceInMeters = Geolocator.distanceBetween(userLatitude, userLongitude, centerLat, centerLong);

    // Convert distance from meters to kilometers
    double distanceInKilometers = distanceInMeters / 1000;

    // Format the distance to have two decimal places
    String formattedDistance = distanceInKilometers.toStringAsFixed(2);

    // Update the existing document with the formatted distance
    await doc.reference.update({'distance': double.parse(formattedDistance)});
    print('Distance to ${doc.id}: $formattedDistance km (updated successfully)');
  } catch (e) {
    print('Error updating distance for ${doc.id}: $e');
  }
});
        } else {
          print('User document not found or no location data available');
        }
      } catch (e) {
        print('Error retrieving user location data: $e');
      }
    } catch (e) {
      print('Error fetching service centers: $e');
    }
  }
}