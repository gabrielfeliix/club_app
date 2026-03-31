import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DecisionPdfGenerator {
  /// Generates and prints/shares a decision card PDF using the background image
  /// with the child's name and decision date overlaid on top of the lines.
  static Future<void> generateAndPrint({
    required String childName,
    required DateTime decisionDate,
  }) async {
    final pdf = pw.Document();

    // Load the background image from assets
    final Uint8List imageBytes =
        (await rootBundle.load('assets/branding/cartao_decisao.jpg'))
            .buffer
            .asUint8List();
    final bgImage = pw.MemoryImage(imageBytes);

    // Extract day, month, and year
    final dayStr = DateFormat('dd').format(decisionDate);
    final monthStr = DateFormat('MM').format(decisionDate);
    final yearStr = DateFormat('yyyy').format(decisionDate);

    // The card image is landscape-oriented (~1024x723)
    // We'll use a custom landscape page that matches the aspect ratio
    const double cardWidth = 500; // points
    const double cardHeight = 353; // points (maintains ~1024/723 ratio)

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(cardWidth, cardHeight, marginAll: 0),
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Background image filling the entire page
              pw.Positioned.fill(
                child: pw.Image(bgImage, fit: pw.BoxFit.cover),
              ),

              // Child's name - positioned just above the line under "Parabéns!"
              // The line is roughly at 56% from the top, name sits just above it
              pw.Positioned(
                left: 120,
                right: 120,
                top: cardHeight * 0.48,
                bottom: 140,
                child: pw.Center(
                  child: pw.Text(
                    childName,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),

              // Decision date - Day
              pw.Positioned(
                right: 110,
                bottom: cardHeight * 0.10,
                child: pw.Text(
                  dayStr,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),

              // Decision date - Month
              pw.Positioned(
                right: 71,
                bottom: cardHeight * 0.10,
                child: pw.Text(
                  monthStr,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),

              // Decision date - Year
              pw.Positioned(
                right: 23,
                bottom: cardHeight * 0.10,
                child: pw.Text(
                  yearStr,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Cartao_Decisao_${childName.replaceAll(' ', '_')}.pdf',
    );
  }
}
