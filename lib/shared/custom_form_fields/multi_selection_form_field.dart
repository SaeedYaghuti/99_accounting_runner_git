// formFields/myMultiselectionFormField.dart ********************

import 'package:flutter/material.dart';

class MyMultiSelectionFormField<T> extends FormField<List<T>> {
  final ValueChanged<List<T>> onChanged;

  final InputDecoration decoration;

  MyMultiSelectionFormField({
    Key? key,
    required List<T> initialValues,
    required List<T> options,
    required Widget Function(T) titleBuilder,
    Widget Function(T)? subtitleBuilder,
    Widget Function(T)? secondaryBuilder,
    required Widget Function(T) chipLabelBuilder,
    Widget Function(T)? chipAvatarBuilder,
    Widget? hint,
    this.decoration = const InputDecoration(),
    required this.onChanged,
    FormFieldSetter<List<T>>? onSaved,
    FormFieldValidator<List<T>>? validator,
    bool autovalidate = false,
    Widget? disabledHint,
    int elevation = 8,
    TextStyle? style,
    TextStyle? chipLabelStyle,
    Widget? underline,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    Color? activeColor,
    Color? checkColor,
    double iconSize = 24.0,
    bool isDense = false,
    bool isExpanded = false,
    double? itemHeight,
    bool autofocus = false,
    FocusNode? focusNode,
    Color? focusColor,
    bool? isItemdense,
    bool isItemThreeLine = false,
    String? deleteButtonTooltipMessage,
    double chipListSpacing = 8.0,
    WrapAlignment chipListAlignment = WrapAlignment.start,
    EdgeInsetsGeometry? chipLabelPadding,
    EdgeInsetsGeometry? chipPadding,
    Widget? chipDeleteIcon,
    Color? chipDeleteIconColor,
    // ShapeBorder? chipShape,
    OutlinedBorder? chipShape,
    Clip chipClipBehavior = Clip.none,
    Color? chipBackgroundColor,
    Color? chipShadowColor,
    MaterialTapTargetSize? chipMaterialTapTargetSize,
    double? chipElevation,
  })  : assert(
          options == null ||
              options.isEmpty ||
              initialValues == null ||
              initialValues.every((value) =>
                  options.where((T option) {
                    return option == value;
                  }).length ==
                  1),
          'There should be exactly one item with [DropdownButton]\'s value: '
          '$initialValues. \n'
          'Either zero or 2 or more [DropdownMenuItem]s were detected '
          'with the same value',
        ),
        assert(itemHeight == null || itemHeight > 0),
        super(
          key: key,
          onSaved: onSaved,
          initialValue: initialValues,
          validator: validator,
          autovalidate: autovalidate,
          builder: (FormFieldState<List<T>> field) {
            final InputDecoration effectiveDecoration = decoration.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );
            return InputDecorator(
              decoration: effectiveDecoration.copyWith(errorText: field.errorText),
              isEmpty: field.value!.isEmpty,
              isFocused: focusNode?.hasFocus ?? false,
              child: MyMultiSelectionField<T>(
                values: field.value!,
                options: options,
                titleBuilder: titleBuilder,
                subtitleBuilder: subtitleBuilder!,
                secondaryBuilder: secondaryBuilder!,
                chipLabelBuilder: chipLabelBuilder,
                chipAvatarBuilder: chipAvatarBuilder!,
                hint: field.value!.isNotEmpty ? hint : null,
                onChanged: field.didChange,
                disabledHint: disabledHint,
                elevation: elevation,
                style: style,
                chipLabelStyle: chipLabelStyle,
                underline: underline,
                icon: icon,
                iconDisabledColor: iconDisabledColor,
                iconEnabledColor: iconEnabledColor,
                activeColor: activeColor,
                checkColor: checkColor,
                iconSize: iconSize,
                isDense: isDense,
                isExpanded: isExpanded,
                itemHeight: itemHeight,
                focusNode: focusNode,
                focusColor: focusColor,
                autofocus: autofocus,
                isItemdense: isItemdense,
                isItemThreeLine: isItemThreeLine,
                deleteButtonTooltipMessage: deleteButtonTooltipMessage,
                chipListSpacing: chipListSpacing,
                chipListAlignment: chipListAlignment,
                chipLabelPadding: chipLabelPadding,
                chipPadding: chipPadding,
                chipDeleteIcon: chipDeleteIcon,
                chipDeleteIconColor: chipDeleteIconColor,
                chipShape: chipShape,
                chipClipBehavior: chipClipBehavior,
                chipBackgroundColor: chipBackgroundColor,
                chipShadowColor: chipShadowColor,
                chipMaterialTapTargetSize: chipMaterialTapTargetSize,
                chipElevation: chipElevation,
              ),
            );
          },
        );

  @override
  FormFieldState<List<T>> createState() => _MyMultiSelectionFormFieldState<T>();
}

class _MyMultiSelectionFormFieldState<T> extends FormFieldState<List<T>> {
  // @override
  // MyMultiSelectionFormField<T> get widget => super.widget;

  // @override
  // void didChange(List<T>? values) {
  //   super.didChange(values);
  //   if (this.hasError) {
  //     this.validate();
  //   }
  //   if (widget.onChanged != null) {
  //     widget.onChanged(values!);
  //   }
  // }
}

// fields/myMultiselectionField.dart ************************

class MyMultiSelectionField<T> extends StatelessWidget {
  final ValueChanged<List<T>> onChanged;
  final List<T>? values;
  final List<T>? options;
  final Widget? hint;
  final Widget? disabledHint;
  final Widget Function(T) titleBuilder;
  final Widget Function(T)? subtitleBuilder;
  final Widget Function(T)? secondaryBuilder;
  final Widget Function(T)? chipLabelBuilder;
  final Widget Function(T)? chipAvatarBuilder;
  final int elevation;
  final TextStyle? style;
  final TextStyle? chipLabelStyle;
  final Widget? underline;
  final Widget? icon;
  final Color? iconDisabledColor;
  final Color? iconEnabledColor;
  final Color? activeColor;
  final Color? checkColor;
  final double iconSize;
  final bool isDense;
  final bool isExpanded;
  final double? itemHeight;
  final Color? focusColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? isItemThreeLine;
  final bool? isItemdense;
  final String? deleteButtonTooltipMessage;
  final double? chipListSpacing;
  final WrapAlignment? chipListAlignment;
  final EdgeInsetsGeometry? chipLabelPadding;
  final EdgeInsetsGeometry? chipPadding;
  final Widget? chipDeleteIcon;
  final Color? chipDeleteIconColor;
  // final ShapeBorder? chipShape;
  final OutlinedBorder? chipShape;
  final Clip? chipClipBehavior;
  final Color? chipBackgroundColor;
  final Color? chipShadowColor;
  final MaterialTapTargetSize? chipMaterialTapTargetSize;
  final double? chipElevation;

  MyMultiSelectionField({
    Key? key,
    this.values,
    required this.options,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.secondaryBuilder,
    required this.chipLabelBuilder,
    this.chipAvatarBuilder,
    this.hint,
    required this.onChanged,
    this.disabledHint,
    this.elevation = 8,
    this.style,
    this.chipLabelStyle,
    this.underline,
    this.icon,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.activeColor,
    this.checkColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight,
    this.autofocus = false,
    this.focusNode,
    this.focusColor,
    this.isItemdense,
    this.isItemThreeLine = false,
    this.deleteButtonTooltipMessage,
    this.chipListSpacing = 8.0,
    this.chipListAlignment = WrapAlignment.start,
    this.chipLabelPadding,
    this.chipPadding,
    this.chipDeleteIcon,
    this.chipDeleteIconColor,
    this.chipShape,
    this.chipClipBehavior = Clip.none,
    this.chipBackgroundColor,
    this.chipShadowColor,
    this.chipMaterialTapTargetSize,
    this.chipElevation,
  })  : assert(options == null ||
            options.isEmpty ||
            values == null ||
            values.every((value) =>
                options.where((T option) {
                  return option == value;
                }).length ==
                1)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: null,
            items: options!
                .map<DropdownMenuItem<T>>(
                  (T option) => DropdownMenuItem<T>(
                    value: option,
                    child: MyCheckboxListTile<T>(
                      selected: values?.contains(option) ?? false,
                      title: titleBuilder(option),
                      subtitle: subtitleBuilder != null ? subtitleBuilder!(option) : null,
                      secondary: secondaryBuilder != null ? secondaryBuilder!(option) : null,
                      isThreeLine: isItemThreeLine ?? false,
                      dense: isItemdense,
                      activeColor: activeColor,
                      checkColor: checkColor,
                      onChanged: (_) {
                        if (!values!.contains(option)) {
                          values!.add(option);
                        } else {
                          values!.remove(option);
                        }
                        onChanged(values!);
                      },
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (BuildContext context) {
              return options!.map<Widget>((T option) {
                return Text('');
              }).toList();
            },
            hint: hint,
            onChanged: onChanged == null ? null : (T? value) {},
            disabledHint: disabledHint,
            elevation: elevation,
            style: style,
            underline: underline,
            icon: icon,
            iconDisabledColor: iconDisabledColor,
            iconEnabledColor: iconEnabledColor,
            iconSize: iconSize,
            isDense: isDense,
            isExpanded: isExpanded,
            itemHeight: itemHeight,
            focusNode: focusNode,
            focusColor: focusColor,
            autofocus: autofocus,
          ),
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: MyChipList<T>(
                values: values!,
                spacing: chipListSpacing!,
                alignment: chipListAlignment!,
                chipBuilder: (T value) {
                  return Chip(
                    label: chipLabelBuilder!(value),
                    labelStyle: chipLabelStyle,
                    labelPadding: chipLabelPadding,
                    avatar: chipAvatarBuilder != null ? chipAvatarBuilder!(value) : null,
                    onDeleted: () {
                      values!.remove(value);
                      onChanged(values!);
                    },
                    deleteIcon: chipDeleteIcon,
                    deleteIconColor: chipDeleteIconColor,
                    deleteButtonTooltipMessage: deleteButtonTooltipMessage,
                    shape: chipShape,
                    clipBehavior: chipClipBehavior!,
                    backgroundColor: chipBackgroundColor,
                    padding: chipPadding,
                    materialTapTargetSize: chipMaterialTapTargetSize,
                    elevation: chipElevation,
                    shadowColor: chipShadowColor,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MyCheckboxListTile<T> extends StatefulWidget {
  MyCheckboxListTile(
      {Key? key,
      required this.title,
      this.subtitle,
      required this.onChanged,
      required this.selected,
      this.activeColor,
      this.checkColor,
      this.dense,
      this.isThreeLine = false,
      this.secondary})
      : super(key: key);

  final Widget title;
  final Widget? subtitle;
  final dynamic onChanged;
  final bool selected;
  final Color? activeColor;
  final Color? checkColor;
  final bool isThreeLine;
  final bool? dense;
  final Widget? secondary;

  @override
  _MyCheckboxListTileState<T> createState() => _MyCheckboxListTileState<T>();
}

class _MyCheckboxListTileState<T> extends State<MyCheckboxListTile<T>> {
  _MyCheckboxListTileState();

  bool? _checked;

  @override
  void initState() {
    _checked = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: _checked,
      selected: _checked ?? false,
      title: widget.title,
      subtitle: widget.subtitle,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) {
        widget.onChanged(checked);
        setState(() {
          _checked = checked ?? false;
        });
      },
      activeColor: widget.activeColor,
      checkColor: widget.checkColor,
      isThreeLine: widget.isThreeLine,
      dense: widget.dense,
      secondary: widget.secondary,
    );
  }
}

class MyChipList<T> extends StatelessWidget {
  const MyChipList({
    required this.values,
    required this.chipBuilder,
    this.spacing = 8.0,
    this.alignment = WrapAlignment.start,
  });

  final List<T> values;
  final Chip Function(T) chipBuilder;
  final double spacing;
  final WrapAlignment alignment;

  List<Widget> _buildChipList() {
    final List<Widget> items = [];
    for (T value in values) {
      items.add(chipBuilder(value));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      alignment: alignment,
      children: _buildChipList(),
    );
  }
}
