import 'package:app_ui/app_ui.dart';
import 'package:club_app/utils/pdf_generator.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:club_app/pages/schedules_page/bloc/schedule_bloc.dart';
import 'package:club_repository/club_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:schedule_repository/schedule_repository.dart';
import 'package:club_app/main.dart';

class ScheduleFormPage extends StatelessWidget {
  final String clubId;
  final ScheduleModel? schedule;
  const ScheduleFormPage({required this.clubId, this.schedule, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ScheduleBloc(scheduleRepository: getIt<IScheduleRepository>());
        if (schedule != null) {
          bloc.add(LoadScheduleDetailsRequired(scheduleId: schedule!.id));
        } else {
          bloc.add(PrepareNewScheduleTemplate(clubId: clubId));
        }
        return bloc;
      },
      child: ScheduleFormView(clubId: clubId, isEditing: schedule != null, schedule: schedule),
    );
  }
}

class ScheduleFormView extends StatefulWidget {
  final String clubId;
  final bool isEditing;
  final ScheduleModel? schedule;
  const ScheduleFormView({required this.clubId, required this.isEditing, this.schedule, super.key});

  @override
  State<ScheduleFormView> createState() => _ScheduleFormViewState();
}

class _ScheduleFormViewState extends State<ScheduleFormView> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  List<ScheduleBlockModel> _blocks = [];
  List<TeachersModel> _teachers = [];
  bool _initialized = false;
  int? _editingBlockIndex;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final result = await getIt<IClubRepository>().getUsers(id: widget.clubId);
    result.when(
      (success) => setState(() => _teachers = success),
      (failure) => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state.status == ScheduleStatus.success && !_initialized && state.selectedSchedule != null) {
          setState(() {
            _selectedDate = state.selectedSchedule!.date;
            _blocks = List.from(state.selectedSchedule!.blocks);
            _initialized = true;
          });
        } else if (state.status == ScheduleStatus.success && _initialized) {
          showCustomSnackBar(
            context,
            widget.isEditing ? 'Escala atualizada com sucesso!' : 'Escala criada com sucesso!',
            type: SnackBarType.success,
          );
          context.pop();
        } else if (state.status == ScheduleStatus.failure) {
          showCustomSnackBar(
            context,
            state.errorMessage ?? 'Ocorreu um erro ao salvar a escala.',
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        if (state.status == ScheduleStatus.loading && !_initialized) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
          appBar: AppBar(
            title: Text(widget.isEditing ? 'Editar Escala' : 'Nova Escala'),
            centerTitle: true,
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            actions: [
              if (widget.isEditing && _initialized)
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () async {
                    String finalClubName = 'Clubinho';
                    try {
                      final clubRepo = getIt<IClubRepository>();
                      final result = await clubRepo.getClubInfo(id: widget.clubId);
                      result.when(
                        (club) {
                          if (club.name.isNotEmpty) {
                            finalClubName = club.name;
                          }
                        },
                        (failure) => null,
                      );
                    } catch (_) {}

                    final schedule = ScheduleModel(
                      id: widget.schedule?.id ?? '',
                      clubId: widget.clubId,
                      date: _selectedDate,
                      blocks: _blocks,
                    );
                    PdfGenerator.generateAndPrint(
                      schedule: schedule,
                      clubName: finalClubName,
                    );
                  },
                ),
              if (widget.isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // --- Basic Info ---
                   Text('Informações Básicas', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   ListTile(
                    title: const Text('Data da Escala'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE', 'pt_BR').format(_selectedDate).toUpperCase(),
                          style: TextStyle(
                            color: context.colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate),
                          style: TextStyle(color: context.colors.onSurface),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: context.colors.onSurface.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Blocks ---
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.isEditing)
                          TabBar(
                            isScrollable: true,
                            dividerColor: Colors.transparent,
                            indicatorColor: context.colors.primary,
                            labelColor: context.colors.primary,
                            unselectedLabelColor: context.colors.onSurface.withOpacity(0.5),
                            labelStyle: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                                final isMusicsTab = widget.isEditing && tabController.index == 1;
                                final filteredBlocks = isMusicsTab
                                    ? _blocks.where((b) => b.title.toLowerCase().contains('música')).toList()
                                    : _blocks;

                                if (isMusicsTab && filteredBlocks.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      child: Text('Nenhuma música encontrada no roteiro'),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: filteredBlocks.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final block = filteredBlocks[index];
                                    final originalIndex = _blocks.indexOf(block);
                                    return _buildBlockCard(context, originalIndex, block, forceTimeline: !isMusicsTab);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: CustomButton(
                      onPressed: _saveSchedule,
                      isLoading: state.status == ScheduleStatus.loading,
                      label: widget.isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR ESCALA',
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildBlockCard(BuildContext context, int index, ScheduleBlockModel block, {bool forceTimeline = false}) {
    if (!widget.isEditing) {
      return _buildCreationCard(context, index, block);
    }

    final isEditing = _editingBlockIndex == index;
    final isMusic = block.title.toLowerCase().contains('música');

    if (!isEditing) {
      if (isMusic && !forceTimeline) {
        return _buildMusicItem(context, index, block);
      }
      return _buildTimelineItem(context, index, block);
    }

    return Card(
      key: ValueKey('block_edit_${index}_${block.order}'),
      elevation: 4,
      color: context.colors.onPrimary,
      shadowColor: context.colors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.colors.primary, width: 2),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: context.colors.primary,
                  child: Text(
                    '${block.order}',
                    style: TextStyle(color: context.colors.onPrimary, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isMusic ? 'Editando Música' : 'Editando Atividade',
                    style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _editingBlockIndex = null),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (isMusic) ...[
              CustomTextField(
                hint: 'Título da Música',
                textEditingController: TextEditingController(text: block.description)
                  ..selection = TextSelection.collapsed(offset: block.description.length),
                textInputAction: TextInputAction.next,
                onChanged: (val) {
                  setState(() {
                    _blocks[index] = _blocks[index].copyWith(description: val);
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Link da Música (YouTube/Drive)',
                textEditingController: TextEditingController(text: block.link ?? '')
                  ..selection = TextSelection.collapsed(offset: (block.link ?? '').length),
                textInputAction: TextInputAction.next,
                onChanged: (val) {
                  setState(() {
                    _blocks[index] = _blocks[index].copyWith(link: val.trim());
                  });
                },
              ),
            ] else ...[
              CustomTextField(
                hint: 'Título da Atividade',
                textEditingController: TextEditingController(text: block.title)
                  ..selection = TextSelection.collapsed(offset: block.title.length),
                textInputAction: TextInputAction.next,
                onChanged: (val) {
                  setState(() {
                    _blocks[index] = _blocks[index].copyWith(title: val);
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Duração: ${block.durationMinutes} minutos',
                    style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Responsáveis', style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => _addResponsible(context, index),
                    icon: Icon(Icons.person_add_alt_1, color: context.colors.primary),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...block.responsibleNames.map((name) => Chip(
                      label: Text(name, style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        setState(() {
                          final current = List<String>.from(_blocks[index].responsibleNames);
                          current.remove(name);
                          _blocks[index] = _blocks[index].copyWith(responsibleNames: current);
                        });
                      },
                    )),
                if (block.responsibleNames.isEmpty)
                  Text(
                    'Nenhum responsável adicionado',
                    style: context.text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _editingBlockIndex = null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('CONCLUIR EDIÇÃO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, int index, ScheduleBlockModel block) {
    final isLast = index == _blocks.length - 1;

    return InkWell(
      onTap: () => setState(() => _editingBlockIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left side: Indicator
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
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
                          fontSize: 12,
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
            ),
            const SizedBox(width: 12),
            // Right side: Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            block.title,
                            style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.colors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${block.durationMinutes} min',
                            style: TextStyle(
                              color: context.colors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (block.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        block.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.primary.withOpacity(0.8),
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
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Icon(Icons.edit_outlined, size: 16, color: context.colors.onSurface.withOpacity(0.3)),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicItem(BuildContext context, int index, ScheduleBlockModel block) {
    final thumbnailUrl = _getYoutubeThumbnail(block.link);

    return Card(
      key: ValueKey('block_music_${index}_${block.order}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colors.onSurface.withOpacity(0.1)),
      ),
      elevation: 0,
      color: context.colors.onPrimary,
      child: InkWell(
        onTap: () => setState(() => _editingBlockIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 70,
                height: 50,
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
                    ? Icon(Icons.music_note, color: context.colors.primary, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block.title,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      block.description.isNotEmpty ? block.description : 'Sem título',
                      style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (block.responsibleNames.isNotEmpty)
                      Text(
                        'Resp: ${block.responsibleNames.join(', ')}',
                        style: context.text.bodySmall?.copyWith(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, size: 16, color: context.colors.onSurface.withOpacity(0.3)),
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

  Widget _buildCreationCard(BuildContext context, int index, ScheduleBlockModel block) {
    final isMusic = block.title.toLowerCase().contains('música');

    return Card(
      key: ValueKey('block_create_${index}_${block.order}'),
      elevation: 0,
      color: context.colors.onSurface.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        iconColor: Colors.black,
        collapsedIconColor: Colors.black,
        initiallyExpanded: false,
        onExpansionChanged: (expanded) {
          if (expanded) {
            FocusScope.of(context).unfocus();
          }
        },
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: context.colors.primary,
          child: Text(
            '${block.order}',
            style: TextStyle(color: context.colors.onPrimary, fontSize: 12),
          ),
        ),
        title: Text(
          isMusic && block.description.isNotEmpty ? block.description : block.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${block.durationMinutes} min • ${block.responsibleNames.isEmpty ? 'Sem responsáveis' : block.responsibleNames.join(', ')}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMusic) ...[
                  CustomTextField(
                    hint: 'Título da Música',
                    textEditingController: TextEditingController(text: block.description)
                      ..selection = TextSelection.collapsed(offset: block.description.length),
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      setState(() {
                        _blocks[index] = _blocks[index].copyWith(description: val);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Link da Música (YouTube/Drive)',
                    textEditingController: TextEditingController(text: block.link ?? '')
                      ..selection = TextSelection.collapsed(offset: (block.link ?? '').length),
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      setState(() {
                        _blocks[index] = _blocks[index].copyWith(link: val.trim());
                      });
                    },
                  ),
                ] else ...[
                  CustomTextField(
                    hint: 'Título da Atividade',
                    textEditingController: TextEditingController(text: block.title)
                      ..selection = TextSelection.collapsed(offset: block.title.length),
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      setState(() {
                        _blocks[index] = _blocks[index].copyWith(title: val);
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Duração: ${block.durationMinutes} minutos',
                        style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Responsáveis', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => _addResponsible(context, index),
                      icon: Icon(Icons.person_add_alt_1, color: context.colors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...block.responsibleNames.map((name) => Chip(
                          label: Text(name, style: const TextStyle(fontSize: 12)),
                          onDeleted: () {
                            setState(() {
                              final current = List<String>.from(_blocks[index].responsibleNames);
                              current.remove(name);
                              _blocks[index] = _blocks[index].copyWith(responsibleNames: current);
                            });
                          },
                        )),
                    if (block.responsibleNames.isEmpty)
                      Text(
                        'Nenhum responsável adicionado',
                        style: context.text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addResponsible(BuildContext context, int blockIndex) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final suggestions = _teachers
                .where((t) => t.name.toLowerCase().contains(controller.text.toLowerCase()))
                .where((t) => t.userRole != UserRole.admin) // Only exclude admins
                .where((t) => !_blocks[blockIndex].responsibleNames.contains(t.name)) // Don't repeat in same field
                .toList();

            return AlertDialog(
              title: const Text('Adicionar Responsável'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        textEditingController: controller,
                        hint: 'Nome do Professor/Líder',
                        textInputAction: TextInputAction.done,
                        onChanged: (val) => setDialogState(() {}),
                      ),
                      if (suggestions.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...suggestions.map((teacher) => ListTile(
                              title: Text(teacher.name),
                              onTap: () {
                                setState(() {
                                  final current = List<String>.from(_blocks[blockIndex].responsibleNames);
                                  if (!current.contains(teacher.name)) {
                                    current.add(teacher.name);
                                    _blocks[blockIndex] = _blocks[blockIndex].copyWith(responsibleNames: current);
                                  }
                                });
                                context.pop();
                              },
                            )),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => context.pop(), child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      setState(() {
                        final names = controller.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final current = List<String>.from(_blocks[blockIndex].responsibleNames);
                        for (final n in names) {
                          if (!current.contains(n)) current.add(n);
                        }
                        _blocks[blockIndex] = _blocks[blockIndex].copyWith(responsibleNames: current);
                      });
                      context.pop();
                    }
                  },
                  child: const Text('ADICIONAR'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    final bloc = context.read<ScheduleBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Escala?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              bloc.add(DeleteScheduleRequired(
                scheduleId: widget.schedule!.id,
                clubId: widget.clubId,
              ));
              Navigator.pop(ctx);
            },
            child: Text('EXCLUIR', style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  void _saveSchedule() {
    if (_formKey.currentState!.validate()) {
      // Check if all blocks have at least one responsible
      final hasEmptyResponsible = _blocks.any((b) => b.responsibleNames.isEmpty);
      if (hasEmptyResponsible) {
        showCustomSnackBar(
          context,
          'Atenção: Todos os cards devem ter pelo menos um responsável.',
          type: SnackBarType.error,
        );
        return;
      }

      final schedule = ScheduleModel(
        id: widget.isEditing ? widget.schedule!.id : '',
        clubId: widget.clubId,
        date: _selectedDate,
        blocks: _blocks,
      );

      if (widget.isEditing) {
        context.read<ScheduleBloc>().add(UpdateScheduleRequired(schedule: schedule));
      } else {
        context.read<ScheduleBloc>().add(CreateScheduleRequired(schedule: schedule));
      }
    }
  }
}

