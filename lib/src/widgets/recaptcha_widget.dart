import 'package:flutter/material.dart';

import '../../flutter_recaptcha.dart';
import '../tools/recaptcha_config.dart';
import '../tools/recaptcha_result.dart';

/// A convenient widget that wraps reCAPTCHA functionality with automatic initialization.
///
/// This widget provides a simple way to integrate reCAPTCHA verification in your app:
/// - Automatic initialization on widget creation
/// - Loading states and error handling
/// - Flexible child widget or default button UI
/// - Manual or automatic verification triggers
///
/// Example usage:
/// ```dart
/// RecaptchaWidget(
///   config: RecaptchaConfig(
///     siteKey: 'YOUR_SITE_KEY',
///     type: RecaptchaType.smart,
///   ),
///   action: 'login',
///   onResult: (result) {
///     if (result.success) {
///       print('Verification successful!');
///     }
///   },
///   onError: (error) {
///     print('Error: $error');
///   },
/// )
/// ```
class RecaptchaWidget extends StatefulWidget {
  /// Configuration for the reCAPTCHA service
  ///
  /// Includes site key, type, and other verification settings
  final RecaptchaConfig config;

  /// Optional action name for the verification
  ///
  /// Helps track what action is being verified (e.g., 'login', 'submit')
  final String? action;

  /// Optional child widget to display instead of default UI
  ///
  /// If provided, the widget will act as a wrapper and handle verification logic
  final Widget? child;

  /// Callback function called when verification is completed
  ///
  /// Provides the full RecaptchaResult with success status and metadata
  final Function(RecaptchaResult)? onResult;

  /// Callback function called when an error occurs
  ///
  /// Provides error message string for debugging or user feedback
  final Function(String)? onError;

  /// Whether to automatically initialize on widget creation
  ///
  /// Defaults to true. Set to false for manual initialization.
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

/// A button that automatically handles reCAPTCHA verification with built-in loading states.
///
/// This widget combines a button with reCAPTCHA functionality:
/// - Automatic initialization and verification
/// - Loading indicator during verification
/// - Customizable button styling
/// - Success and error callbacks
///
/// Example usage:
/// ```dart
/// RecaptchaButton(
///   config: RecaptchaConfig(
///     siteKey: 'YOUR_SITE_KEY',
///     type: RecaptchaType.smart,
///   ),
///   action: 'submit_form',
///   onVerified: (result) {
///     print('Verified! Token: ${result.token}');
///   },
///   onError: (error) {
///     print('Error: $error');
///   },
///   child: const Text('Submit Form'),
/// )
/// ```
class RecaptchaButton extends StatefulWidget {
  /// Configuration for the reCAPTCHA service
  final RecaptchaConfig config;

  /// Optional action name for the verification
  final String? action;

  /// The button child widget (typically Text or Icon)
  final Widget child;

  /// Optional callback when button is pressed and verification succeeds
  final VoidCallback? onPressed;

  /// Callback function called when verification is successful
  ///
  /// Provides the full RecaptchaResult with token and metadata
  final Function(RecaptchaResult)? onVerified;

  /// Callback function called when an error occurs
  final Function(String)? onError;

  /// Optional button styling
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
      child: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : widget.child,
    );
  }
}

/// A form field that integrates reCAPTCHA verification with form validation.
///
/// This widget extends FormField to provide:
/// - Integration with Flutter form system
/// - Automatic validation state management
/// - Error display and validation messages
/// - Seamless form submission workflow
///
/// Example usage:
/// ```dart
/// Form(
///   key: _formKey,
///   child: Column(
///     children: [
///       TextFormField(
///         decoration: InputDecoration(labelText: 'Email'),
///         validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
///       ),
///       RecaptchaFormField(
///         config: RecaptchaConfig(
///           siteKey: 'YOUR_SITE_KEY',
///           type: RecaptchaType.smart,
///         ),
///         validator: (isVerified) {
///           return isVerified == true ? null : 'Please verify you are human';
///         },
///         onVerified: (result) {
///           print('reCAPTCHA verified!');
///         },
///       ),
///       ElevatedButton(
///         onPressed: () {
///           if (_formKey.currentState!.validate()) {
///             // Submit form
///           }
///         },
///         child: Text('Submit'),
///       ),
///     ],
///   ),
/// )
/// ```
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
