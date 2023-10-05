import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medifinder/txtfield.dart';

class ViewHospitalScreen extends StatefulWidget {
  final String? hspimg;
  final String? hspname;
  final String? hspdetails;
  final String? phone;
  final String? address;

  const ViewHospitalScreen(
      {Key? key,
      this.hspimg,
      this.hspname,
      this.hspdetails,
      this.phone,
      this.address})
      : super(key: key);

  @override
  State<ViewHospitalScreen> createState() => _ViewHospitalScreenState();
}

class _ViewHospitalScreenState extends State<ViewHospitalScreen> {
  String? name;
  String photoUrl = '';
  final TextEditingController reviewController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  late Future<void> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    // Simulating an asynchronous API call to fetch the user profile
    await Future.delayed(const Duration(seconds: 1));

    // Set the user profile data
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    setState(() {
      name = googleUser!.displayName;
      photoUrl = googleUser.photoUrl ?? '';

      // Check if the profile picture is available
      if (googleUser.photoUrl != null) {
        photoUrl = googleUser.photoUrl!.replaceAll("s96-c", "s192-c");
      } else {
        photoUrl =
            ''; // Set an empty string if profile picture is not available
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: FutureBuilder<void>(
                future: _userProfileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text('Loading...'));
                  }

                  return Stack(children: [
                    Image.network(
                      widget.hspimg.toString(),
                      fit: BoxFit.contain,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  borderRadius:
                                                      BorderRadius.circular(2),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            const Text(
                                              'Address',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  letterSpacing: 2),
                                            ),
                                            Text(widget.address.toString()),
                                            Text(
                                                'Phone${widget.phone.toString()}'),
                                            const SizedBox(height: 30),
                                            const Text(
                                              'Hospital Details',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  letterSpacing: 2),
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
                                            Row(
                                              children: [
                                                const Text(
                                                  'Hospital Review',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return Column(
                                                          children: [
                                                            const SizedBox(
                                                                height: 30),
                                                            const Text(
                                                              'Add your review',
                                                              style: TextStyle(
                                                                fontSize: 25,
                                                                letterSpacing:
                                                                    2,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 30),
                                                            TxtField(
                                                              mycontroller:
                                                                  reviewController,
                                                              type: TextInputType
                                                                  .multiline,
                                                              mylabel:
                                                                  'Add your Review',
                                                              maxlines: 5,
                                                            ),
                                                            const SizedBox(
                                                                height: 18),
                                                            Center(
                                                              child:
                                                                  ElevatedButton
                                                                      .icon(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  splashFactory:
                                                                      NoSplash
                                                                          .splashFactory,
                                                                  backgroundColor:
                                                                      const Color
                                                                          .fromRGBO(
                                                                          69,
                                                                          160,
                                                                          54,
                                                                          100),
                                                                  minimumSize:
                                                                      const Size(
                                                                          200,
                                                                          55),
                                                                  disabledBackgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                  ),
                                                                ),
                                                                icon: const Icon(
                                                                    Icons.add),
                                                                label:
                                                                    const Text(
                                                                  'Add Review',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    letterSpacing:
                                                                        2,
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  icon: const Icon(Icons.add),
                                                ),
                                              ],
                                            )
                                          ]))));
                        })
                  ]);
                })));
  }
}
