// formFields/mySwitchFormField.dart ********************

class MySwitchFormField extends FormField<bool> {
  MySwitchFormField({
    Key? key,
    required bool initialValue,
    this.decoration = const InputDecoration(),
    required this.onChanged,
    required FormFieldSetter<bool> onSaved,
    required FormFieldValidator<bool> validator,
    bool autovalidate = false,
    this.constraints = const BoxConstraints(),
    required Color activeColor,
    required Color activeTrackColor,
    required Color inactiveThumbColor,
    required Color inactiveTrackColor,
    required ImageProvider<dynamic> activeThumbImage,
    required ImageProvider<dynamic> inactiveThumbImage,
    required MaterialTapTargetSize materialTapTargetSize,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    required Color focusColor,
    required Color hoverColor,
    required FocusNode focusNode,
    bool autofocus = false,
  })  : assert(decoration != null),
        assert(initialValue != null),
        assert(autovalidate != null),
        assert(autofocus != null),
        assert(dragStartBehavior != null),
        assert(constraints != null),
        super(
          key: key,
          onSaved: onSaved,
          initialValue: initialValue,
          validator: validator,
          autovalidate: autovalidate,
          builder: (FormFieldState<bool> field) {
            final InputDecoration effectiveDecoration = decoration.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );
            return InputDecorator(
              decoration: effectiveDecoration.copyWith(errorText: field.errorText),
              isEmpty: field.value == null,
              isFocused: focusNode.hasFocus,
              child: Row(
                children: <Widget>[
                  ConstrainedBox(
                    constraints: constraints,
                    child: Switch(
                      value: field.value!,
                      onChanged: field.didChange,
                      activeColor: activeColor,
                      activeTrackColor: activeTrackColor,
                      inactiveThumbColor: inactiveThumbColor,
                      inactiveTrackColor: inactiveTrackColor,
                      activeThumbImage: activeThumbImage!,
                      inactiveThumbImage: inactiveThumbImage,
                      materialTapTargetSize: materialTapTargetSize,
                      dragStartBehavior: dragStartBehavior,
                      focusColor: focusColor,
                      hoverColor: hoverColor,
                      focusNode: focusNode,
                      autofocus: autofocus,
                    ),
                  ),
                ],
              ),
            );
          },
        );

  final ValueChanged<bool> onChanged;
  final InputDecoration decoration;
  final BoxConstraints constraints;

  @override
  FormFieldState<bool> createState() => _MySwitchFormFieldState();
}

class _MySwitchFormFieldState extends FormFieldState<bool> {
  @override
  MySwitchFormField get widget => super.widget;

  @override
  void didChange(bool value) {
    super.didChange(value);
    if (this.hasError) {
      this.validate();
    }
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }
  }
}
