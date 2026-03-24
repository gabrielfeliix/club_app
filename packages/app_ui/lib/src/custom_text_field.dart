// ignore_for_file: prefer_if_null_operators

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    required this.textEditingController,
    required this.textInputAction,
    this.maxLines,
    this.onSubmitted,
    this.onEditingComplete,
    this.validator,
    this.autofillHints,
    this.autovalidateMode,
    this.onChanged,
    this.error,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
  })  : suffixIcon = null,
        enableSuggestions = true,
        isPhone = false,
        autocorrect = false,
        obscure = null,
        autofillHintsBool = null;
  const CustomTextField.pop({
    super.key,
    required this.hint,
    required this.textEditingController,
    required this.textInputAction,
    this.maxLines,
    this.onSubmitted,
    this.onEditingComplete,
    this.validator,
    this.autofillHints,
    this.autovalidateMode,
    this.onChanged,
    this.error,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
  })  : suffixIcon = null,
        enableSuggestions = true,
        isPhone = false,
        autocorrect = false,
        obscure = null,
        autofillHintsBool = null;
  // validatorPhone = null;

  CustomTextField.password({
    super.key,
    required this.hint,
    required this.suffixIcon,
    this.obscure,
    required this.textEditingController,
    required this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.onEditingComplete,
    this.autovalidateMode,
    this.onChanged,
    this.error,
    this.inputFormatters,
  })  : maxLines = 1,
        enableSuggestions = false,
        isPhone = false,
        autocorrect = false,
        keyboardType = TextInputType.visiblePassword,
        autofillHints = [AutofillHints.password],
        autofillHintsBool = null;
  // validatorPhone = null;

  const CustomTextField.suffixIcon({
    super.key,
    required this.hint,
    required this.suffixIcon,
    required this.textEditingController,
    required this.textInputAction,
    this.onEditingComplete,
    this.onSubmitted,
    this.keyboardType,
    this.autovalidateMode,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.error,
    this.inputFormatters,
  })  : maxLines = 1,
        enableSuggestions = false,
        obscure = false,
        isPhone = false,
        autocorrect = true,
        autofillHintsBool = null;
  //  validatorPhone = null;

  const CustomTextField.phone({
    super.key,
    required this.hint,
    required this.suffixIcon,
    required this.textEditingController,
    required this.textInputAction,
    this.onEditingComplete,
    this.autovalidateMode,
    this.onSubmitted,
    this.keyboardType,
    this.autofillHintsBool,
    this.validator,
    this.onChanged,
    this.error,
    this.inputFormatters,
    // this.validatorPhone,
  })  : maxLines = 1,
        enableSuggestions = false,
        obscure = false,
        autocorrect = true,
        isPhone = true,
        autofillHints = null;
  CustomTextField.email({
    super.key,
    required this.hint,
    required this.textEditingController,
    required this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.onEditingComplete,
    this.onChanged,
    this.error,
    this.autovalidateMode,
    this.inputFormatters,
  })  : maxLines = 1,
        obscure = false,
        isPhone = false,
        enableSuggestions = false,
        keyboardType = TextInputType.emailAddress,
        autofillHints = [AutofillHints.email],
        autocorrect = null,
        suffixIcon = null,
        autofillHintsBool = null;
  //  validatorPhone = null;

  const CustomTextField.box({
    super.key,
    required this.hint,
    required int max,
    this.onSubmitted,
    this.autovalidateMode,
    this.onEditingComplete,
    required this.textEditingController,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.error,
    this.keyboardType,
  })  : maxLines = max,
        autofillHints = null,
        isPhone = false,
        textInputAction = TextInputAction.done,
        obscure = false,
        suffixIcon = null,
        enableSuggestions = null,
        autocorrect = null,
        autofillHintsBool = null;
  //  validatorPhone = null;

  final String hint;

  final int? maxLines;

  final Widget? suffixIcon;

  final TextInputAction? textInputAction;

  final Iterable<String>? autofillHints;

  final bool? autofillHintsBool;

  final TextInputType? keyboardType;

  final bool? enableSuggestions;

  final bool? autocorrect;

  final Function(String)? onSubmitted;

  final Function()? onEditingComplete;

  final String? Function(String?)? validator;

  final String? error;

  final bool? obscure;

  final bool isPhone;

  final AutovalidateMode? autovalidateMode;

  final List<TextInputFormatter>? inputFormatters;

  final Function(String)? onChanged;

  final TextEditingController? textEditingController;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();

  bool _hasInteracted = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        focusNode: _focusNode,
        autovalidateMode: widget.autovalidateMode ??
            (_hasInteracted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.onUnfocus //
            ),
        maxLines: widget.maxLines,
        obscureText: widget.obscure ?? false,
        controller: widget.textEditingController,
        onChanged: widget.onChanged, //
        inputFormatters: [
          MaskFormatter.noDoubleSpaceFormatter,
          ...?widget.inputFormatters,
        ],

        onEditingComplete: widget.onEditingComplete, //
        onFieldSubmitted: widget.onSubmitted, //
        textInputAction: widget.textInputAction, //
        autofillHints: widget.autofillHints, //
        keyboardType: widget.keyboardType, //
        enableSuggestions: widget.enableSuggestions ?? true, //
        validator: widget.validator,
        autocorrect: widget.autocorrect ?? true,
        style: TextStyle(
          color: context.colors.onSecondary,
        ),
        decoration: InputDecoration(
          errorText: widget.error != null ? widget.error : null,
          suffixIcon: widget.suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.w,
              color: context.colors.onSurfaceVariant,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.w,
              color: context.colors.onSurfaceVariant,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          labelText: widget.hint,
          labelStyle: TextStyle(color: context.colors.surface),
          floatingLabelStyle: TextStyle(
            color: context.colors.primary,
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.w,
              color: context.colors.error,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.w,
              color: context.colors.error,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && !_hasInteracted) {
      setState(() {
        _hasInteracted = true;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
}
