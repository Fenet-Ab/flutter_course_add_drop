import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HeadingTextComponent extends StatelessWidget {
  final String value;

  const HeadingTextComponent({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 20),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.normal,
          color: Colors.blue, // Assuming colorHeading is blue
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class HeadingHomeTextComponent extends StatelessWidget {
  final String value;

  const HeadingHomeTextComponent({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 20),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.blue, // Assuming colorHeading is blue
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class NormalTextComponent extends StatelessWidget {
  final String value;

  const NormalTextComponent({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class TextFieldPhotoComponent extends StatefulWidget {
  final String labelValue;
  final String assetName;
  final String contentDescription;
  final VoidCallback onTap;

  const TextFieldPhotoComponent({
    Key? key,
    required this.labelValue,
    required this.assetName,
    required this.contentDescription,
    required this.onTap,
  }) : super(key: key);

  @override
  _TextFieldPhotoComponentState createState() => _TextFieldPhotoComponentState();
}

class _TextFieldPhotoComponentState extends State<TextFieldPhotoComponent> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: TextField(
        controller: _controller,
        readOnly: true,
        onTap: widget.onTap,
        decoration: InputDecoration(
          labelText: widget.labelValue,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Image.asset(widget.assetName, width: 24, height: 24),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onEditingComplete: () => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

class TextFieldComponent extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String assetPath;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onValueChange;

  const TextFieldComponent({
    Key? key,
    this.controller,
    required this.label,
    required this.assetPath,
    this.validator,
    this.onValueChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Image.asset(assetPath, width: 24, height: 24),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
        onChanged: onValueChange,
        textInputAction: TextInputAction.next,
        maxLines: 1,
      ),
    );
  }
}

class TextFieldAdminComponent extends StatelessWidget {
  final String labelValue;
  final IconData icon;
  final ValueChanged<String> onValueChange;

  const TextFieldAdminComponent({
    Key? key,
    required this.labelValue,
    required this.icon,
    required this.onValueChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: labelValue,
          labelStyle: const TextStyle(color: Colors.grey),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: onValueChange,
        textInputAction: TextInputAction.next,
        maxLines: 1,
      ),
    );
  }
}

class TextFieldAdminFinalComponent extends StatelessWidget {
  final String labelValue;
  final IconData icon;
  final ValueChanged<String> onValueChange;

  const TextFieldAdminFinalComponent({
    Key? key,
    required this.labelValue,
    required this.icon,
    required this.onValueChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: labelValue,
          labelStyle: const TextStyle(color: Colors.grey),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: onValueChange,
        textInputAction: TextInputAction.done,
        maxLines: 1,
      ),
    );
  }
}

class PasswordTextFieldComponent extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String assetPath;
  final bool isVisible;
  final VoidCallback onVisibilityToggle;
  final Function(String)? onValueChange;
  final String? Function(String?)? validator;
  final bool readOnly;

  const PasswordTextFieldComponent({
    super.key,
    required this.controller,
    required this.label,
    required this.assetPath,
    required this.isVisible,
    required this.onVisibilityToggle,
    this.onValueChange,
    this.validator,
    this.readOnly = false,
  });

  @override
  _PasswordTextFieldComponentState createState() => _PasswordTextFieldComponentState();
}

class _PasswordTextFieldComponentState extends State<PasswordTextFieldComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: TextFormField(
        controller: widget.controller,
        onChanged: widget.onValueChange,
        obscureText: !widget.isVisible,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(widget.assetPath, width: 24, height: 24),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              widget.isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: widget.onVisibilityToggle,
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3B82F6)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        textInputAction: TextInputAction.next,
        validator: widget.validator,
      ),
    );
  }
}

class PasswordLoginTextFieldComponent extends StatefulWidget {
  final String labelValue;
  final IconData icon;
  final String contentDescription;
  final ValueChanged<String> onValueChange;

  const PasswordLoginTextFieldComponent({
    Key? key,
    required this.labelValue,
    required this.icon,
    required this.contentDescription,
    required this.onValueChange,
  }) : super(key: key);

  @override
  _PasswordLoginTextFieldComponentState createState() => _PasswordLoginTextFieldComponentState();
}

class _PasswordLoginTextFieldComponentState extends State<PasswordLoginTextFieldComponent> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: TextField(
        obscureText: !_passwordVisible,
        decoration: InputDecoration(
          labelText: widget.labelValue,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(widget.icon, size: 24),
          suffixIcon: IconButton(
            icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: widget.onValueChange,
        textInputAction: TextInputAction.done,
        onEditingComplete: () => FocusScope.of(context).unfocus(),
        maxLines: 1,
      ),
    );
  }
}

class CheckboxComponent extends StatefulWidget {
  final String value;
  final ValueChanged<String> onTextSelected;

  const CheckboxComponent({
    Key? key,
    required this.value,
    required this.onTextSelected,
  }) : super(key: key);

  @override
  _CheckboxComponentState createState() => _CheckboxComponentState();
}

class _CheckboxComponentState extends State<CheckboxComponent> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: _checked,
            onChanged: (value) {
              setState(() {
                _checked = value ?? false;
              });
            },
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: ' Agree with',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: ' terms ',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => widget.onTextSelected('terms'),
                  ),
                  const TextSpan(
                    text: ' and ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: ' conditions ',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => widget.onTextSelected('conditions'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonSignupComponent extends StatelessWidget {
  final String value;
  final VoidCallback onClick;

  const ButtonSignupComponent({
    Key? key,
    required this.value,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: onClick,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(260, 50),
          backgroundColor: Colors.blue, // Assuming colorPrimary is blue
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Medium shape
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ButtonComponent extends StatelessWidget {
  final String value;
  final VoidCallback onClick;
  final bool enabled;

  const ButtonComponent({
    Key? key,
    required this.value,
    required this.onClick,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: enabled ? onClick : null,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(260, 50),
          backgroundColor: enabled ? Colors.blue : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ClickableLoginTextComponent extends StatelessWidget {
  final ValueChanged<String> onTextSelected;

  const ClickableLoginTextComponent({
    Key? key,
    required this.onTextSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          children: [
            // const TextSpan(
            //   text: 'Already have an account? ',
            //   style: TextStyle(color: Colors.black, fontSize: 16),
            // ),
            TextSpan(
              text: 'Log In ',
              style: const TextStyle(color: Colors.blue, fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () => onTextSelected('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}

class ClickableSignUpTextComponent extends StatelessWidget {
  final bool tryingToLogin;
  final ValueChanged<String> onTextSelected;

  const ClickableSignUpTextComponent({
    Key? key,
    this.tryingToLogin = true,
    required this.onTextSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          children: [
            // const TextSpan(
            //   text: 'Don't have an account? ',
            //   style: TextStyle(color: Colors.black, fontSize: 16),
            // ),
            TextSpan(
              text: 'Sign Up ',
              style: const TextStyle(color: Colors.blue, fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () => onTextSelected('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

class UnderLinedTextComponent extends StatelessWidget {
  final bool tryingToLogin;
  final ValueChanged<String> onTextSelected;

  const UnderLinedTextComponent({
    Key? key,
    this.tryingToLogin = true,
    required this.onTextSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Forget your password? ',
              style: const TextStyle(color: Colors.blue, fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () => onTextSelected('Forget your password?'),
            ),
          ],
        ),
      ),
    );
  }
}