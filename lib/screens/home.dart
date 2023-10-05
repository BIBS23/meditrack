import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as Math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> hospitals =
      []; // Declare this at the beginning of your class
  late Stream<QuerySnapshot> _stream;
  FocusNode inputNode = FocusNode();

  bool expand = false;
  Position? userLocation;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestLocationPermissionAndFetchLocation();
    _stream = FirebaseFirestore.instance.collection('hospitaldata').snapshots();
  }

  Future<void> requestLocationPermissionAndFetchLocation() async {
    final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
    LocationPermission permission = await geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      print('Location permission denied');
    } else if (permission == LocationPermission.deniedForever) {
      print('Location permission denied forever');
    } else {
      getUserLocation().then((position) {
        setState(() {
          userLocation = position;
          print('User location: $userLocation');
        });
      });
    }
  }

  Future<Position> getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int radiusOfEarth = 6371;
    double dLat = (lat2 - lat1) * (3.14159265359 / 180);
    double dLon = (lon2 - lon1) * (3.14159265359 / 180);
    double a = (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(lat1 * (3.14159265359 / 180)) *
            Math.cos(lat2 * (3.14159265359 / 180)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2));
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return radiusOfEarth * c;
  }

  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }

  void _handleSearch(String searchText) {
    if (searchText.isEmpty) {
      setState(() {
        _stream =
            FirebaseFirestore.instance.collection('hospitaldata').snapshots();
      });
    } else {
      String firstLetter = searchText.substring(0, 1);
      String secondLetter =
          searchText.length >= 2 ? searchText.substring(1, 2) : "";
      String thirdLetter =
          searchText.length >= 3 ? searchText.substring(2, 3) : "";
      String fourthLetter =
          searchText.length >= 4 ? searchText.substring(3, 4) : "";
      setState(() {
        _stream = FirebaseFirestore.instance
            .collection('hospitaldata')
            .where('speciality',
                isGreaterThanOrEqualTo:
                    firstLetter + secondLetter + thirdLetter + fourthLetter)
            .where('speciality',
                isLessThan:
                    '$firstLetter$secondLetter$thirdLetter${fourthLetter}z')
            .snapshots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String appTitle = 'Home';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(146, 1, 128, 122),
        title: expand
            ? null
            : Text(appTitle,
                style: const TextStyle(fontSize: 20, letterSpacing: 2)),
        centerTitle: true,
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: expand ? MediaQuery.of(context).size.width : 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 100),
              child: expand
                  ? TextField(
                      textCapitalization: TextCapitalization.sentences,
                      focusNode: inputNode,
                      controller: _searchController,
                      onChanged: _handleSearch,
                      style: const TextStyle(
                          fontSize: 18, letterSpacing: 2, color: Colors.white),
                      decoration: InputDecoration(
                          hintText: expand ? 'search for speciality' : null,
                          hintStyle: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 2,
                              color: Color.fromARGB(172, 255, 255, 255)),
                          border: InputBorder.none))
                  : null,
            ),
          ),
        ),
        leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    expand = !expand;
                  });
                  _searchController.clear();
                  _stream = FirebaseFirestore.instance
                      .collection('hospitaldata')
                      .snapshots();
                },
                icon: Icon(expand ? Icons.close : Icons.search))),
      ),
      body: FutureBuilder<Position>(
        future: getUserLocation(),
        builder:
            (BuildContext context, AsyncSnapshot<Position> locationSnapshot) {
          if (locationSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (locationSnapshot.hasError) {
            return Center(
                child: TextButton(
                    onPressed: () {
                      requestLocationPermissionAndFetchLocation();
                    },
                    child: Text('Enable Location')));
          } else if (!locationSnapshot.hasData) {
            return const Center(child: Text('User location not available'));
          }

          userLocation = locationSnapshot.data;

          return StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No data'));
              } else {
                List<DocumentSnapshot> hospitals = snapshot.data!.docs;

                // Filter hospitals based on the entered speciality
                hospitals = hospitals.where((hospital) {
                  String speciality =
                      hospital['speciality'].toString().toLowerCase();
                  String searchValue = searchController.text.toLowerCase();
                  return speciality.contains(searchValue);
                }).toList();

                // Sort filtered hospitals based on distance in ascending order
                hospitals.sort((a, b) {
                  double lat1 = double.tryParse(a['latitude'] ?? '0.0') ?? 0.0;
                  double lon1 = double.tryParse(a['longitude'] ?? '0.0') ?? 0.0;
                  double lat2 = double.tryParse(b['latitude'] ?? '0.0') ?? 0.0;
                  double lon2 = double.tryParse(b['longitude'] ?? '0.0') ?? 0.0;

                  double distance1 = calculateDistance(userLocation!.latitude,
                      userLocation!.longitude, lat1, lon1);
                  double distance2 = calculateDistance(userLocation!.latitude,
                      userLocation!.longitude, lat2, lon2);

                  return distance1.compareTo(distance2);
                });

                return ListView.builder(
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot = hospitals[index];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                documentSnapshot['hspimg'],
                                width: 130,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      documentSnapshot['hspname'],
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      documentSnapshot['speciality'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      documentSnapshot['address'],
                                      textAlign: TextAlign.justify,
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  void filterHospitalsBySpeciality(String speciality) {
    // Firestore query to filter hospitals by 'speciality' field
    FirebaseFirestore.instance
        .collection('hospitaldata')
        .where('speciality', isEqualTo: speciality)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Handle the filtered hospitals here
        List<DocumentSnapshot> filteredHospitals = snapshot.docs;
        setState(() {
          hospitals = filteredHospitals;
        });
      } else {
        // Handle the case when no hospitals match the speciality
        setState(() {
          hospitals = [];
        });
      }
    });
  }
}
