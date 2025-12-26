import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class EditUserPage extends StatefulWidget {
  final User? user;
  const EditUserPage({super.key, this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  String _role = 'USER';

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _firstNameCtrl = TextEditingController(text: u?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: u?.lastName ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _passwordCtrl = TextEditingController();
    _role = u?.role ?? 'USER';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final user = User(
      id: widget.user?.id,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      role: _role,
    );

    try {
      if (widget.user == null) {
        await UserService.createUser(user, password: _passwordCtrl.text.trim());
      } else {
        await UserService.updateUser(widget.user!.id!, user, password: _passwordCtrl.text.trim().isEmpty ? null : _passwordCtrl.text.trim());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.user == null ? 'Créer utilisateur' : 'Modifier utilisateur'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              shadowColor: Colors.black12,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Iconsax.user_edit, size: 40, color: Colors.deepPurple),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: Icon(Iconsax.user),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: Icon(Iconsax.user),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Iconsax.sms),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _role,
                        decoration: const InputDecoration(
                          labelText: 'Rôle',
                          prefixIcon: Icon(Iconsax.shield_security),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'USER', child: Text('Utilisateur Standard')),
                          DropdownMenuItem(value: 'ADMIN', child: Text('Administrateur')),
                        ],
                        onChanged: (v) => setState(() => _role = v ?? 'USER'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Iconsax.key),
                          helperText: 'Laisser vide pour ne pas changer',
                        ),
                        validator: (v) {
                          if (widget.user == null && (v == null || v.isEmpty)) {
                            return 'Mot de passe requis pour la création';
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _saving 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Enregistrer', style: TextStyle(fontSize: 16)),
                        ),
                      )
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
