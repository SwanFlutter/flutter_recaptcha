import 'package:flutter/material.dart';

import '../flutter_recaptcha.dart';

/// A convenient widget that wraps reCAPTCHA functionality
class RecaptchaWidget extends StatefulWidget {
  final RecaptchaConfig config;
  final String? action;
  final Widget? child;
  final Function(RecaptchaResult)? onResult;
  final Function(String)? onError;
  final bool autoInitialize;

  const RecaptchaWidget({
    super.key,
    required this.config,
    this.action,
    this.child,
    this.onResult,
    this.onError,
    this.autoInitialize = true,
  });

  @override
  State<RecaptchaWidget> createState() => _RecaptchaWidgetState();
}

class _RecaptchaWidgetState extends State<RecaptchaWidget> {
  final _recaptcha = FlutterRecaptcha.instance;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoInitialize) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _recaptcha.initialize(widget.config);
      setState(() {
        _isInitialized = success;
      });

      if (!success) {
        widget.onError?.call('Failed to initialize reCAPTCHA');
      }
    } catch (e) {
      widget.onError?.call('Initialization error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> verify() async {
    if (!_isInitialized) {
      await _initialize();
      if (!_isInitialized) return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _recaptcha.verify(action: widget.action);
      widget.onResult?.call(result);
    } catch (e) {
      widget.onError?.call('Verification error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return widget.child!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoading)
          const CircularProgressIndicator()
        else if (!_isInitialized)
          ElevatedButton(
            onPressed: _initialize,
            child: const Text('Initialize reCAPTCHA'),
          )
        else
          ElevatedButton(onPressed: verify, child: const Text('Verify')),
      ],
    );
  }
}

/// A button that automatically handles reCAPTCHA verification
class RecaptchaButton extends StatefulWidget {
  final RecaptchaConfig config;
  final String? action;
  final Widget child;
  final VoidCallback? onPressed;
  final Function(RecaptchaResult)? onVerified;
  final Function(String)? onError;
  final ButtonStyle? style;

  const RecaptchaButton({
    super.key,
    required this.config,
    required this.child,
    this.action,
    this.onPressed,
    this.onVerified,
    this.onError,
    this.style,
  });

  @override
  State<RecaptchaButton> createState() => _RecaptchaButtonState();
}

class _RecaptchaButtonState extends State<RecaptchaButton> {
  final _recaptcha = FlutterRecaptcha.instance;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final success = await _recaptcha.initialize(widget.config);
      setState(() {
        _isInitialized = success;
      });
    } catch (e) {
      widget.onError?.call('Initialization error: $e');
    }
  }

  Future<void> _handlePress() async {
    if (!_isInitialized) {
      widget.onError?.call('reCAPTCHA not initialized');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _recaptcha.verify(action: widget.action);

      if (result.success) {
        widget.onVerified?.call(result);
        widget.onPressed?.call();
      } else {
        widget.onError?.call(result.errorMessage ?? 'Verification failed');
      }
    } catch (e) {
      widget.onError?.call('Verification error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: widget.style,
      onPressed: _isLoading ? null : _handlePress,
      child:
          _isLoading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : widget.child,
    );
  }
}

/// A form field that integrates reCAPTCHA verification
class RecaptchaFormField extends FormField<bool> {
  RecaptchaFormField({
    super.key,
    required RecaptchaConfig config,
    String? action,
    Function(RecaptchaResult)? onVerified,
    Function(String)? onError,
    super.validator,
    super.initialValue = false,
    super.enabled = true,
    super.autovalidateMode,
  }) : super(
         builder: (FormFieldState<bool> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               RecaptchaWidget(
                 config: config,
                 action: action,
                 onResult: (result) {
                   state.didChange(result.success);
                   onVerified?.call(result);
                 },
                 onError: (error) {
                   state.didChange(false);
                   onError?.call(error);
                 },
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 8.0),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(
                       color: Theme.of(state.context).colorScheme.error,
                       fontSize: 12,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}
