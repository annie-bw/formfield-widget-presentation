import 'package:flutter/material.dart';

void main() => runApp(const FormFieldDemoApp());

class FormFieldDemoApp extends StatelessWidget {
  const FormFieldDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormField',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
      home: const RegistrationPage(),
    );
  }
}

/// A complete registration form that shows off the FormField family:
///  - TextFormField              (a FormField that wraps a TextField)
///  - DropdownButtonFormField    (a FormField that wraps a dropdown)
///  - `FormField<T>`             (the base widget, used to build custom fields)
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // The key gives us access to FormState: validate(), save(), reset().
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  // Validate live only after the user has tried to submit once.
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  bool _obscurePassword = true;

  // Values filled in by each field's onSaved callback.
  String? _name;
  String? _email;
  String? _track;
  int? _experience;
  bool _acceptedTerms = false;

  static const _tracks = ['Mobile', 'Web', 'Backend', 'Design', 'Data'];

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save(); // calls onSaved on every field
      _showSummary();
    } else {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix these errors')),
      );
    }
  }

  void _reset() {
    _formKey.currentState!.reset(); // returns every field to its initial value
    _passwordController.clear();
    setState(() => _autovalidate = AutovalidateMode.disabled);
  }

  void _showSummary() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Registration complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow('Name', _name!),
            _SummaryRow('Email', _email!),
            _SummaryRow('Track', _track!),
            _SummaryRow('Experience', '$_experience / 5'),
            _SummaryRow('Terms', _acceptedTerms ? 'Accepted' : 'No'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Flutter Workshop Sign-up'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autovalidate,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Create your account',
                          style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        'All fields are required.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),

                      // ---------- TextFormField: name ----------
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name is too short';
                          }
                          return null; // null means valid
                        },
                        onSaved: (value) => _name = value!.trim(),
                      ),
                      const SizedBox(height: 16),

                      // ---------- TextFormField: email ----------
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Please enter your email';
                          final valid =
                              RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
                          return valid ? null : 'Enter a valid email address';
                        },
                        onSaved: (value) => _email = value!.trim(),
                      ),
                      const SizedBox(height: 16),

                      // ---------- TextFormField: password ----------
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          helperText: 'At least 8 characters, including a number',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) return 'Too short (min 8)';
                          if (!value.contains(RegExp(r'\d'))) {
                            return 'Include at least one number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ---------- TextFormField: confirm password ----------
                      // Cross-field validation: compares with the field above.
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_reset_outlined),
                        ),
                        validator: (value) => value != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // ---------- DropdownButtonFormField ----------
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Preferred track',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        items: [
                          for (final t in _tracks)
                            DropdownMenuItem(value: t, child: Text(t)),
                        ],
                        onChanged: (_) {},
                        validator: (value) =>
                            value == null ? 'Please choose a track' : null,
                        onSaved: (value) => _track = value,
                      ),
                      const SizedBox(height: 24),

                      // ---------- Custom FormField<int>: star rating ----------
                      _ExperienceRatingField(
                        onSaved: (value) => _experience = value,
                      ),
                      const SizedBox(height: 8),

                      // ---------- Custom FormField<bool>: terms checkbox ----------
                      FormField<bool>(
                        initialValue: false,
                        validator: (value) => value == true
                            ? null
                            : 'You must accept the terms to continue',
                        onSaved: (value) => _acceptedTerms = value ?? false,
                        builder: (field) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              value: field.value,
                              onChanged: field.didChange,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text(
                                  'I agree to the workshop code of conduct'),
                            ),
                            if (field.hasError)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  field.errorText!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ---------- Actions ----------
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send),
                        label: const Text('Register'),
                        style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _reset,
                        child: const Text('Reset form'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A custom form field built by extending `FormField<int>`.
/// It gets validation, saving and reset from Form, just like TextFormField.
class _ExperienceRatingField extends FormField<int> {
  _ExperienceRatingField({super.onSaved})
      : super(
          initialValue: 0,
          validator: (value) =>
              (value ?? 0) == 0 ? 'Please rate your Flutter experience' : null,
          builder: (field) {
            final theme = Theme.of(field.context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flutter experience',
                    style: theme.textTheme.titleSmall),
                Wrap(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      IconButton(
                        tooltip: '$i / 5',
                        onPressed: () => field.didChange(i),
                        icon: Icon(
                          i <= (field.value ?? 0)
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber.shade700,
                          size: 32,
                        ),
                      ),
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      field.errorText!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
              ],
            );
          },
        );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
