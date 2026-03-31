import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:schedule_repository/schedule_repository.dart';

class _CellDef {
  final String text;
  final int span;
  final bool isGray;
  _CellDef(this.text, {this.span = 1, this.isGray = false});
}

class PdfGenerator {
  static Future<void> generateAndPrint({
    required ScheduleModel schedule,
    required String clubName,
  }) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('dd/MM/yyyy', 'pt_BR').format(schedule.date);
    final headerColor = PdfColor.fromHex('#92D050');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          final b = schedule.blocks;
          ScheduleBlockModel? getB(int idx) => b.length > idx ? b[idx] : null;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: pw.BoxDecoration(
                  color: headerColor,
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'Roteiro Clubinho $clubName - dia $dateStr',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                columnWidths: {
                  0: const pw.FixedColumnWidth(30), // No
                  1: const pw.FlexColumnWidth(3), // TEMA
                  2: const pw.FlexColumnWidth(4), // RESPONSÁVEL
                  3: const pw.FixedColumnWidth(60), // TEMPO
                },
                children: [
                  // Headers
                  pw.TableRow(
                    children: [
                      _headerCell('No'),
                      _headerCell('TEMA'),
                      _headerCell('RESPONSÁVEL'),
                      _headerCell('TEMPO'),
                    ],
                  ),

                  // Row 1: Recepção (0) + Água (1)
                  if (getB(0) != null || getB(1) != null)
                    _buildCustomRow(
                      number: _CellDef('1', span: 2, isGray: true),
                      temas: [
                        _CellDef(_formatTitle(getB(0)), isGray: true),
                        _CellDef(_formatTitle(getB(1)), isGray: true),
                      ],
                      responsaveis: [
                        _CellDef(_resp(getB(0)), isGray: true),
                        _CellDef(_resp(getB(1)), isGray: true),
                      ],
                      tempos: [_CellDef('15 Min', span: 2, isGray: true)],
                    ),

                  // Row 2: Contagem (2) + Boas-vindas (3) + Regras (4) + Declaração (5)
                  if (getB(2) != null ||
                      getB(3) != null ||
                      getB(4) != null ||
                      getB(5) != null)
                    _buildCustomRow(
                      number: _CellDef('2', span: 4, isGray: false),
                      temas: [
                        _CellDef(_formatTitle(getB(2)), isGray: false),
                        _CellDef(_formatTitle(getB(3)), isGray: false),
                        _CellDef(_formatTitle(getB(4)), isGray: false),
                        _CellDef(_formatTitle(getB(5)), isGray: true),
                      ],
                      responsaveis: [
                        _CellDef(_uniqueNames([getB(2), getB(3)]),
                            span: 2, isGray: false),
                        _CellDef(_resp(getB(4)), isGray: false),
                        _CellDef(_resp(getB(5)), isGray: true),
                      ],
                      tempos: [_CellDef('10 Min', span: 4, isGray: false)],
                    ),

                  // Row 3: Música 1 (6) + Música 2 (7)
                  if (getB(6) != null || getB(7) != null)
                    _buildCustomRow(
                      number: _CellDef('3', span: 2, isGray: false),
                      temas: [
                        _CellDef(
                            '${_formatTitle(getB(6))}\n${_formatTitle(getB(7))}',
                            span: 2,
                            isGray: false),
                      ],
                      responsaveis: [
                        _CellDef(_resp(getB(6)), isGray: false),
                        _CellDef(_resp(getB(7)), isGray: false),
                      ],
                      tempos: [_CellDef('8 Min', span: 2, isGray: false)],
                    ),

                  // Row 4: Brincadeiras (8)
                  if (getB(8) != null)
                    _buildCustomRow(
                      number: _CellDef('4', span: 1, isGray: true),
                      temas: [_CellDef(_formatTitle(getB(8)), isGray: true)],
                      responsaveis: [_CellDef(_resp(getB(8)), isGray: true)],
                      tempos: [_CellDef('15 Min', span: 1, isGray: true)],
                    ),

                  // Row 5: Música Lenta (9)
                  if (getB(9) != null)
                    _buildCustomRow(
                      number: _CellDef('5', span: 1, isGray: false),
                      temas: [_CellDef(_formatTitle(getB(9)), isGray: false)],
                      responsaveis: [_CellDef(_resp(getB(9)), isGray: false)],
                      tempos: [_CellDef('2 Min', span: 1, isGray: false)],
                    ),

                  // Row 6: Versículo (10) + Fixação (11) + Oração (12)
                  if (getB(10) != null || getB(11) != null || getB(12) != null)
                    _buildCustomRow(
                      number: _CellDef('6', span: 3, isGray: true),
                      temas: [
                        _CellDef(_formatTitle(getB(10)), isGray: true),
                        _CellDef(_formatTitle(getB(11)), isGray: true),
                        _CellDef(_formatTitle(getB(12)), isGray: true),
                      ],
                      responsaveis: [
                        _CellDef(_uniqueNames([getB(10), getB(11), getB(12)]),
                            span: 3, isGray: true),
                      ],
                      tempos: [_CellDef('8 Min', span: 3, isGray: true)],
                    ),

                  // Row 7: História (13) + Apelo (14)
                  if (getB(13) != null || getB(14) != null)
                    _buildCustomRow(
                      number: _CellDef('7',
                          span: 3,
                          isGray:
                              false), // História (13) + Apelo (14) + Trabalho (15)
                      temas: [
                        _CellDef(_formatTitle(getB(13)), isGray: false),
                        _CellDef(_formatTitle(getB(14)), isGray: false),
                        _CellDef(_formatTitle(getB(15)), isGray: true),
                      ],
                      responsaveis: [
                        _CellDef(_uniqueNames([getB(13), getB(14)]),
                            span: 2, isGray: false),
                        _CellDef(_resp(getB(15)), isGray: true),
                      ],
                      tempos: [
                        _CellDef('18 m', span: 2, isGray: false),
                        _CellDef('10 Min', span: 1, isGray: true),
                      ],
                    ),

                  // Row 8: Lanche/oração (16)
                  if (getB(16) != null)
                    _buildCustomRow(
                      number: _CellDef('8', span: 1, isGray: false),
                      temas: [_CellDef(_formatTitle(getB(16)), isGray: false)],
                      responsaveis: [
                        _CellDef(_uniqueNames([getB(16)]), isGray: false)
                      ],
                      tempos: [
                        _CellDef('${getB(16)!.durationMinutes} Min',
                            span: 1, isGray: false)
                      ],
                    ),

                  // Row 9: Aconselhamento (17)
                  if (getB(17) != null)
                    _buildCustomRow(
                      number: _CellDef('9', span: 1, isGray: true),
                      temas: [_CellDef(_formatTitle(getB(17)), isGray: true)],
                      responsaveis: [
                        _CellDef(_uniqueNames([getB(17)]), isGray: true)
                      ],
                      tempos: [
                        _CellDef('${getB(17)!.durationMinutes} Min',
                            span: 1, isGray: true)
                      ],
                    ),

                  // Row 10: Oração Final (18)
                  if (getB(18) != null)
                    _buildCustomRow(
                      number: _CellDef('10', span: 1, isGray: false),
                      temas: [_CellDef(_formatTitle(getB(18)), isGray: false)],
                      responsaveis: [_CellDef(_resp(getB(18)), isGray: false)],
                      tempos: [
                        _CellDef('${getB(18)!.durationMinutes} Min',
                            span: 1, isGray: false)
                      ],
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Escala_${schedule.date.toIso8601String().split('T')[0]}.pdf',
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Center(
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        ),
      ),
    );
  }

  static pw.TableRow _buildCustomRow({
    required _CellDef number,
    required List<_CellDef> temas,
    required List<_CellDef> responsaveis,
    required List<_CellDef> tempos,
  }) {
    return pw.TableRow(
      children: [
        _buildColumn([number]),
        _buildColumn(temas),
        _buildColumn(responsaveis),
        _buildColumn(tempos),
      ],
    );
  }

  static pw.Widget _buildColumn(List<_CellDef> cells) {
    return pw.Column(
      children: cells
          .map((c) => _subCell(c.text, span: c.span, isGray: c.isGray))
          .toList(),
    );
  }

  static pw.Widget _subCell(String text, {int span = 1, bool isGray = false}) {
    return pw.Container(
      height: 20.0 * span,
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: isGray ? PdfColors.grey200 : null,
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: pw.Center(
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),
    );
  }

  static String _formatTitle(ScheduleBlockModel? block) {
    if (block == null) return '';
    if (block.title.contains('Música') && block.description.isNotEmpty) {
      return '${block.title} - ${block.description}';
    }
    return block.title;
  }

  static String _resp(ScheduleBlockModel? block) {
    if (block == null) return '';
    return block.responsibleNames.join(', ');
  }

  static String _uniqueNames(List<ScheduleBlockModel?> blocks) {
    final names = <String>[];
    for (final b in blocks) {
      if (b != null) {
        for (final n in b.responsibleNames) {
          if (!names.contains(n)) {
            names.add(n);
          }
        }
      }
    }
    return names.join(', ');
  }
}
