import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

class ViewHospitalScreen extends StatefulWidget {
  final String? hspimg;
  final String? hspname;
  final String? hspdetails;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;

  const ViewHospitalScreen({
    Key? key,
    this.hspimg,
    this.hspname,
    this.hspdetails,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<ViewHospitalScreen> createState() => _ViewHospitalScreenState();
}

class _ViewHospitalScreenState extends State<ViewHospitalScreen> {
  Future<void> openMap(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      MapsLauncher.launchCoordinates(latitude, longitude);
    } else {
      // Handle the case when latitude or longitude is null
      // You can display an error message or take some other action here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.network(
              widget.hspimg.toString(),
              fit: BoxFit.fitHeight,
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            DraggableScrollableSheet(
              maxChildSize: 1,
              initialChildSize: 0.6,
              minChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Container(
                              width: 80,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              widget.hspname.toString(),
                              style: const TextStyle(
                                fontSize: 30,
                                letterSpacing: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Address',
                            style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(widget.address.toString()),
                          Text('Phone${widget.phone.toString()}'),
                          const SizedBox(height: 30),
                          const Text(
                            'Hospital Details',
                            style: TextStyle(
                              fontSize: 20,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            widget.hspdetails.toString(),
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(146, 1, 128, 122),
                                maximumSize: Size(150, 60),
                              ),
                              onPressed: () {
                                openMap(widget.latitude, widget.longitude);
                              },
                              child: const Text(
                                'Get Direction',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
