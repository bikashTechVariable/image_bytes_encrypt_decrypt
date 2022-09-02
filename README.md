# Image Bytes Encryption Decryption

## Objective :
To pick an image from your device and convert it into bytes array(list). Then, iterate through this list and divide this bytes into 3 sub-lists. Dividing the bytes in byte array to the 3 strings by concatenating them and it should not directly be done as done by splitting the list instead insert every next byte into different sub strings. After that encrypt these 3 substrings using a symmetric encryption algorithm. Here, we have used AES encryption which uses symmetric key encryption. After that decrypt the encrypted strings using the same key. Now, again recover these strings to the original list of bytes array. After that recover the image.

## Symmetric Key Cryptography
In Symmetric Key Cryptography same key is both for the purpose of encryption and decryption.

## AES
The Advanced Encryption Standard (AES) is a symmetric block cipher chosen by the U.S. government to protect classified information.
AES is implemented in software and hardware throughout the world to encrypt sensitive data. It is essential for government computer security, cybersecurity and electronic data protection. Symmetric key cryptography is a type of encryption scheme in which the similar key is used both to encrypt and decrypt messages.

## Additional Packages used in this project:

### encrypt
***encrypt :*** A set of high-level APIs over PointyCastle for two-way cryptography. Click [here](https://pub.dev/packages/encrypt) for link to the library.

### Image Picker plugin for Flutter
***image_picker :*** A Flutter plugin for iOS and Android for picking images from the image library, and taking new pictures with the camera. Click [here](https://pub.dev/packages/image_picker) for link to the source.

## Explanation on splitting the bytes array into 3 substrings:
The image is picked from the device of the user using the statement:
<code>var picked = await picker.pickImage(source: ImageSource.gallery);</code>

Then it has been converted into bytes array and saves to variable t using the expression:
<code>var tobytes = await File(picked!.path).readAsBytes();</code>

Save the length of the bytes array to a variable "i".
Also, at the top of the class we will create and initiate list *s_converted* to store to store the bytes converted to strings:
<code>List s_converted = ["", "", ""];</code>

And, use *s_encrypted* to store the encrypted values of the corresponding strings.



When the app loads, click on the FloatingActionButton to select an image from the device. After that convert it to bytes array. After that convert the bytes array into 3 strings as per the following code:
<code>
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
</code>

Then after storing the strings into *s_converted* list encrypt the data using the AES Algorithm which is a symmetric key algorithm where same key is both for the purpose of encryption and decryption. The 3 strings in a *s_converted* list have been encrypted and their corresponding encrypted values have been stored in the *s_encrypted* list of strings.
<code>
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
</code>
After that the encrypted text is again decrypted and stored into a list of list named as *s_decrypted*.

Now, the *s_decrypted* list is filtered and stored into a list *final_values* which is required for the purpose of reconstruction of the image. Code snippet for processing of the data from *s_decrypted* to *final_values*.

<code>
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

</code>

Now, the state of the wiget will be updated using the following code snippet which will eventually lead to the reconstruction of the encrypted and then decrypted image bytes array.

<code>
          setState(() {
            print(Uint8List.fromList(final_values).length == tobytes.length);
            fileurl = final_values;
          });
</code>
