import 'package:app_ui/app_ui.dart';
import 'package:club_app/utils/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schedule_repository/schedule_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleViewPage extends StatelessWidget {
  final ScheduleModel schedule;
  const ScheduleViewPage({required this.schedule, super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Roteiro do Clubinho'),
          centerTitle: true,
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.onPrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => PdfGenerator.generateAndPrint(
                schedule: schedule,
                clubName: 'Clubinho',
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Card(
                elevation: 4,
                shadowColor: context.colors.primary.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: context.colors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy (EEEE)', 'pt_BR').format(schedule.date),
                            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Tabs ---
              TabBar(
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorColor: context.colors.primary,
                labelColor: context.colors.primary,
                unselectedLabelColor: context.colors.onSurface.withOpacity(0.5),
                labelStyle: context.text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Roteiro de Atividades'),
                  Tab(text: 'Músicas'),
                ],
              ),
              const SizedBox(height: 16),

              Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);
                  return AnimatedBuilder(
                    animation: tabController,
                    builder: (context, _) {
                      if (tabController.index == 0) {
                        return Column(
                          children: schedule.blocks.map((block) => _buildTimelineItem(context, block)).toList(),
                        );
                      } else {
                        final musicBlocks = schedule.blocks
                            .where((b) => b.title.toLowerCase().contains('música'))
                            .toList();

                        if (musicBlocks.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text('Nenhuma música encontrada neste roteiro'),
                            ),
                          );
                        }

                        return Column(
                          children: musicBlocks.map((block) => _buildMusicItem(context, block)).toList(),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, ScheduleBlockModel block) {
    final isLast = schedule.blocks.last == block;

    return IntrinsicHeight(
      child: Row(
        children: [
          // Left side: Indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.primary, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${block.order}',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: context.colors.primary.withOpacity(0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Right side: Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          block.title,
                          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                       ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${block.durationMinutes} min',
                          style: TextStyle(
                            color: context.colors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (block.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      block.description,
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (block.responsibleNames.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Resp: ${block.responsibleNames.join(', ')}',
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicItem(BuildContext context, ScheduleBlockModel block) {
    final thumbnailUrl = _getYoutubeThumbnail(block.link);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: context.colors.onPrimary,
      child: InkWell(
        onTap: block.link != null && block.link!.isNotEmpty
            ? () => launchUrl(Uri.parse(block.link!))
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: context.colors.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  image: thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(thumbnailUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: thumbnailUrl == null
                    ? Icon(Icons.music_note, color: context.colors.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block.title,
                      style: context.text.labelSmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      block.description.isNotEmpty ? block.description : 'Sem título',
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (block.link != null && block.link!.isNotEmpty)
                      Text(
                        'Toque para abrir o link',
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.primary.withOpacity(0.7),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, size: 18, color: context.colors.primary.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  String? _getYoutubeThumbnail(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return null;

      String? videoId;
      if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'];
      } else if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      }

      if (videoId != null && videoId.isNotEmpty) {
        return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
      }
    } catch (_) {}
    return null;
  }
}
