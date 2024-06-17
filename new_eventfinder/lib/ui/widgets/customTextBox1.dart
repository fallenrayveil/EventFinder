import 'package:flutter/material.dart';

class CustomTextBox1 extends StatefulWidget {
  final String placeholder;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  CustomTextBox1({
    required this.placeholder,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.validator,
  });

  @override
  _CustomTextBox1State createState() => _CustomTextBox1State();
}

class _CustomTextBox1State extends State<CustomTextBox1> {
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _isObscured = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      setState(() {
        if (widget.validator != null) {
          _errorText = widget.validator!(_controller.text);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              TextField(
                controller: _controller,
                obscureText: widget.isPassword ? _isObscured : false,
                style: TextStyle(color: Color(0xFFCBED54), fontFamily: 'Magra'), // Set input text color
                decoration: InputDecoration(
                  labelText: _isFocused || _controller.text.isNotEmpty
                      ? widget.placeholder
                      : null,
                  labelStyle: TextStyle(
                    color: _isFocused ? Color(0xFFCBED54) : Colors.grey,
                    fontSize: _isFocused ? 12 : 16,
                    fontFamily: 'Magra'
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: Icon(widget.icon, color: Color(0xFFCBED54)),
                  suffixIcon: widget.isPassword
                      ? IconButton(
                          icon: Icon(
                            _isObscured ? Icons.visibility : Icons.visibility_off,
                            color: Color(0xFFCBED54),
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        )
                      : _controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Color(0xFFCBED54)),
                              onPressed: () {
                                _controller.clear();
                              },
                            )
                          : null,
                  hintText: !_isFocused ? widget.placeholder : '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFFCBED54)),
                  ),
                  errorText: _errorText,
                ),
              ),
              if (_isFocused || _controller.text.isNotEmpty)
                Positioned(
                  width: 0,
                  height: 0,
                  child: Text(
                    widget.placeholder,
                    style: TextStyle(
                      color: Color(0xFFCBED54),
                      fontSize: 12,
                      fontFamily: 'Magra'
                    ),
                  ),
                ),
            ],
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 5.0),
              child: Text(
                _errorText!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontFamily: 'Magra',
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
}
