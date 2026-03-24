import 'package:app_ui/app_ui.dart';
import 'package:club_app/main.dart';
import 'package:decision_repository/decision_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:club_app/pages/decisions_page/bloc/decisions_bloc.dart';
import 'package:intl/intl.dart';

class AddDecisionPage extends StatelessWidget {
  final String clubId;
  const AddDecisionPage({required this.clubId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DecisionsBloc(
        decisionRepository: getIt<IDecisionRepository>(),
      ),
      child: AddDecisionView(clubId: clubId),
    );
  }
}

class AddDecisionView extends StatefulWidget {
  final String clubId;
  const AddDecisionView({required this.clubId, super.key});

  @override
  State<AddDecisionView> createState() => _AddDecisionViewState();
}

class _AddDecisionViewState extends State<AddDecisionView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _counselorController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isVisitor = false;
  bool _isEnrolled = false;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final newDecision = DecisionModel(
        id: '',
        clubId: widget.clubId,
        childName: _nameController.text,
        address: _addressController.text,
        age: _ageController.text,
        phone: _phoneController.text,
        isVisitor: _isVisitor,
        isEnrolled: _isEnrolled,
        decisionDate: _selectedDate,
        counselorName: _counselorController.text,
      );

      context.read<DecisionsBloc>().add(CreateDecisionRequired(decision: newDecision));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Decisão'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
      ),
      body: BlocConsumer<DecisionsBloc, DecisionsState>(
        listener: (context, state) {
          if (state.isSuccess) {
            showCustomSnackBar(
              context,
              state.message ?? 'Decisão salva!',
              type: SnackBarType.success,
            );
            context.pop();
          } else if (state.isFailure) {
            showCustomSnackBar(
              context,
              state.message ?? 'Erro ao salvar. ${state.message}',
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    textEditingController: _nameController,
                    hint: 'Criança (nome completo)',
                    textInputAction: TextInputAction.next,
                    validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField.box(
                    textEditingController: _addressController,
                    hint: 'Endereço',
                    max: 5,
                  ),
                  const SizedBox(height: 16),
                  // Because we want number but CustomTextField only has .phone or default
                  // we can just use the default CustomTextField, it doesn't accept keyboardType directly.
                  // Wait, CustomTextField doesn't accept keyboardType in default constructor.
                  // I will use CustomTextField.phone for phone and just regular for age.
                  CustomTextField(
                    textEditingController: _ageController,
                    hint: 'Idade',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField.phone(
                    textEditingController: _phoneController,
                    hint: 'Telefone',
                    suffixIcon: const SizedBox(),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    textEditingController: _counselorController,
                    hint: 'Conselheiro',
                    textInputAction: TextInputAction.done,
                    validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                          style: TextStyle(color: context.colors.onSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: _presentDatePicker,
                        child: Text(
                          'Escolher Data',
                          style: TextStyle(color: context.colors.onSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _isVisitor,
                            onChanged: (val) {
                              setState(() {
                                _isVisitor = val ?? false;
                                if (_isVisitor) _isEnrolled = false;
                              });
                            },
                          ),
                          Text('Visitante', style: TextStyle(color: context.colors.onSecondary)),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isEnrolled,
                            onChanged: (val) {
                              setState(() {
                                _isEnrolled = val ?? false;
                                if (_isEnrolled) _isVisitor = false;
                              });
                            },
                          ),
                          Text('Matriculada', style: TextStyle(color: context.colors.onSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: 'Salvar Decisão',
                    isLoading: state.isLoading,
                    height: 50,
                    onPressed: _submitData,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
