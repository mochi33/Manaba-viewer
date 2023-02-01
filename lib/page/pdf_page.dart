
import 'package:flutter/material.dart';

class PDFPage extends StatefulWidget {

  String pdfURL;
  PDFPage({Key? key, required this.pdfURL}) : super(key: key);

  @override
  State<PDFPage> createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.pdfURL == '') {
      Navigator.pop(context);
    }
    return Scaffold(
      body: Container(
        //child : const PDF().cachedFromUrl(widget.pdfURL),
      ),
    );
  }
}
