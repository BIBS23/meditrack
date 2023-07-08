import 'package:flutter/material.dart';
import 'package:medifinder/controller/login_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {

      bool isLoading = false;

    return Scaffold(
      extendBody: true,
      body: Consumer<AuthController>(
        builder: (BuildContext context, auth, Widget? child) =>
        Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Opacity(opacity: 0.5,
              child: Image.asset('assets/loginbg.png',fit: BoxFit.cover,))
            ),
            Padding(
             padding: const EdgeInsets.only(top: 50),
             child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset('assets/logo.png',width: 200,height: 200)),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    backgroundColor: const Color.fromARGB(85, 1, 128, 122),
                    minimumSize: const Size(200, 55),
                    disabledBackgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isLoading
                      ? null // Disable the button when loading
                      : () async {
                          setState(() {
                            isLoading = true; // Set loading state to true
                          });
              
                          auth.reset();
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
              
                          try {
                            final user = await auth.handleGoogleSignIn();
                            if (user != null&& context.mounted) {
                                
                              navigator.pushNamedAndRemoveUntil(
                                  '/home', (route) => false);
                            } else {
                              // User is null, stay on the login screen
                              scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                  duration: const Duration(milliseconds: 1000 ),
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  content: Container(
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(55, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: const  Center(child: Text('Unable to sign in',style: TextStyle(letterSpacing: 5) ,))),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            print('Unable to sign in');
                          } finally {
                            setState(() {
                              isLoading =
                                  false; // Set loading state to false
                            });
                          }
                        },
                  icon: isLoading
                      ? const SizedBox.shrink()
                      : SvgPicture.asset(
                          'assets/google.svg',
                          height: 30,
                          width: 30,
                        ),
                  label: isLoading
                      ? const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          
                          ),
                        )
                      : const Text('Login With Google',style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
          ],
        ),
      ) ,
    );
  }

}