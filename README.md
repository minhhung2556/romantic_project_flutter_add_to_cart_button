# Flutter Add To Cart Button

A Flutter package to create Add To Cart Button. It will be useful for your awesome app.

This creates a button that is used to let the users can add items to their shopping cart. This will be useful for the eCommerce app.

![Imgur](https://imgur.com/download/AxSPR0Z)

### Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_add_to_cart_button/flutter_add_to_cart_button.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AddToCartButtonStateId stateId = AddToCartButtonStateId.idle;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Add To Cart'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AddToCartButton(
                    trolley: Image.asset(
                      'assets/ic_cart.png',
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                    text: Text(
                      'Add to cart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    check: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(24),
                    backgroundColor: Colors.deepOrangeAccent,
                    onPressed: (id) {
                      if (id == AddToCartButtonStateId.idle) {
                        //handle logic when pressed on idle state button.
                        setState(() {
                          stateId = AddToCartButtonStateId.loading;
                          Future.delayed(Duration(seconds: 3), () {
                            setState(() {
                              stateId = AddToCartButtonStateId.done;
                            });
                          });
                        });
                      } else if (id == AddToCartButtonStateId.done) {
                        //handle logic when pressed on done state button.
                        setState(() {
                          stateId = AddToCartButtonStateId.idle;
                        });
                      }
                    },
                    stateId: stateId,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

### Development environment

```
[✓] Flutter (Channel stable, 2.0.5, on macOS 11.2.3 20D91 darwin-x64, locale en-VN)
    • Flutter version 2.0.5
    • Framework revision adc687823a (11 days ago), 2021-04-16 09:40:20 -0700
    • Engine revision b09f014e96
    • Dart version 2.12.3

[✓] Android toolchain - develop for Android devices (Android SDK version 30.0.3)
    • Platform android-30, build-tools 30.0.3
    • Java binary at: /Applications/Android Studio.app/Contents/jre/jdk/Contents/Home/bin/java
    • Java version OpenJDK Runtime Environment (build 1.8.0_242-release-1644-b3-6915495)
    • All Android licenses accepted.

[✓] Xcode - develop for iOS and macOS
    • Xcode at /Applications/Xcode_12.app/Contents/Developer
    • Xcode 12.4, Build version 12D4e
    • CocoaPods version 1.10.1

[✓] Chrome - develop for the web
    • Chrome at /Applications/Google Chrome.app/Contents/MacOS/Google Chrome

[✓] Android Studio (version 4.1)
    • Android Studio at /Applications/Android Studio.app/Contents
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 1.8.0_242-release-1644-b3-6915495)
```