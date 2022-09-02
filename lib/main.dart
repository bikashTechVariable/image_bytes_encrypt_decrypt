import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photohashing/encryption.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Encrypt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var picker = ImagePicker();
  List s_converted = ["", "", ""];
  List s_encrypted = ["", "", ""];
  String tmp = "";
  int tmp_len = 0;
  List<int> fileurl = [];

  List s_decrypted = [[], [], []];
  List tmp_list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Bytes Encrypt and Decrypt',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            fileurl.isNotEmpty
                ? SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Image.memory(
                            Uint8List.fromList(fileurl),
                          ),
                          const Text('Decrypted Image'),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'Please select an image to encrypt by tapping on the floating button',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var picked = await picker.pickImage(source: ImageSource.gallery);
          var tobytes = await File(picked!.path).readAsBytes();

          // Timer start (To check the time from encryption to decryption).
          print(
              'Start Timer : ${DateFormat('hh:ss:ms').format(DateTime.now())}');

          int i = tobytes.length;
          bool status = true;
          // String will be divided in reverse order
          while (status) {
            i--;
            tmp = tobytes[i].toString();
            tmp_len = tmp.length;

            tmp = "$tmp.";

            s_converted[i % 3] = s_converted[i % 3] + tmp;
            if (i - 1 == -1) {
              status = false;
            }
          }

          // For splitting with '.' an additional value has been added
          s_converted[0] += '0';
          s_converted[1] += '0';
          s_converted[2] += '0';

          for (int i = 0; i < 3; i++) {
            final key = "This 32 char key have 256 bits..";

            print('Plain text for encryption [$i]: ${s_converted[i]}');

            //Encrypt
            Encrypted encrypted = encryptWithAES(key, s_converted[i]);
            print(encrypted.runtimeType);
            String encryptedBase64 = encrypted.base64;
            print(encryptedBase64.runtimeType);
            print('Encrypted data in base64 encoding [$i]: $encryptedBase64');
            s_encrypted[i] = encrypted;
            //Decrypt
            // String decryptedText = decryptWithAES(key, encrypted);
            String decryptedText = decryptWithAES(key, s_encrypted[i]);
            print('Decrypted data [$i]: $decryptedText');
            s_decrypted[i] = decryptedText;
          }

          s_decrypted[0] = s_decrypted[0].split(".");
          s_decrypted[1] = s_decrypted[1].split(".");
          s_decrypted[2] = s_decrypted[2].split(".");

          s_decrypted[0].removeLast();
          s_decrypted[1].removeLast();
          s_decrypted[2].removeLast();

          List<int> final_values = [];
          int p = s_decrypted[0].length - 1;
          int q = s_decrypted[1].length - 1;
          int r = s_decrypted[2].length - 1;
          bool a = p > r;
          bool b = q > r;
          print("p : " + p.toString());
          print("q : " + q.toString());
          print("r : " + r.toString());

          for (; r > -1; p--, q--, r--) {
            final_values.add(int.parse(s_decrypted[0][p]));
            final_values.add(int.parse(s_decrypted[1][q]));
            final_values.add(int.parse(s_decrypted[2][r]));
          }

          if (a) {
            final_values.add(int.parse(s_decrypted[0][0]));
          }

          if (b) {
            final_values.add(int.parse(s_decrypted[1][0]));
          }

          setState(() {
            print(Uint8List.fromList(final_values).length == tobytes.length);
            fileurl = final_values;
          });

          print(
            'stop timer : ${DateFormat('hh:ss:ms').format(DateTime.now())}',
          );
        },
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
