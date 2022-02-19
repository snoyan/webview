import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MaterialApp(home: WebWidget()));
}

class WebWidget extends StatefulWidget {
  @override
  WebState createState() => WebState();
}

class WebState extends State<WebWidget> {
  late WebViewController controller;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
  }

  Future<bool?> onBackPressed() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      setState(() {});
      return false;
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('آیا میخواید از برنامه خارج شوید؟'),
              content: Text('برای خروج از برنامه دکمه بستن را بزنید.'),
              actions: <Widget>[
                TextButton(
                  child: Text('لغو'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('بستن'),
                  onPressed: () {
                    exit(0);
                  },
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? result = await onBackPressed();
        if (result == null) {
          result = false;
        }
        return result;
      },
      child: SafeArea(
        child: Container(
            child: Column(
          children: [
            /*  Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              color: Colors.teal,
            ),*/
            Expanded(
              child: Stack(
                children: [
                  WebView(
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebResourceError: (WebResourceError WebErorr) async {
                        await loadHtmlFromAssets(
                            'assets/index.html', controller);
                      },
                      initialUrl: "https://sitesazz.ir",
                      onWebViewCreated: (controller) {
                        this.controller = controller;
                      },
                      onPageFinished: (finish) {
                        setState(() {
                          isLoading = false;
                        });
                      }),
                  isLoading
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.lightGreen,
                          child: Container(
                              child:
                                  Center(child: CircularProgressIndicator())))
                      : Stack()
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}

Future<void> loadHtmlFromAssets(String filename, controller) async {
  String fileText = await rootBundle.loadString(filename);
  controller.loadUrl(Uri.dataFromString(fileText,
          mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
      .toString());
}
