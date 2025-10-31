import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthState();
}

class _AuthState extends State<AuthScreen> {
  bool isLogin = true;
  final _email = TextEditingController(), _pass = TextEditingController(), _name = TextEditingController(), _phone = TextEditingController();
  String _role = 'client';
  String? _err;

  Future<void> _submit() async {
    setState(() => _err = null);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text, password: _pass.text);
      } else {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text, password: _pass.text);
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'name': _name.text,
          'email': _email.text,
          'phone': _phone.text,
          'role': _role,
          'createdAt': FieldValue.serverTimestamp()
        });
      }
    } catch (e) {
      setState(() => _err = '$e');
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
        appBar: AppBar(title: Text(isLogin ? 'Iniciar sesión' : 'Crear cuenta')),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(children: [
              if (!isLogin) TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
              if (!isLogin) TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Teléfono')),
              if (!isLogin)
                DropdownButtonFormField<String>(
                    value: _role,
                    items: const [
                      DropdownMenuItem(value: 'client', child: Text('Cliente')),
                      DropdownMenuItem(value: 'provider', child: Text('Prestador')),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? 'client'),
                    decoration: const InputDecoration(labelText: 'Rol')),
              const SizedBox(height: 12),
              if (_err != null) Text(_err!, style: const TextStyle(color: Colors.red)),
              FilledButton(onPressed: _submit, child: Text(isLogin ? 'Entrar' : 'Registrarme')),
              TextButton(onPressed: () => setState(() => isLogin = !isLogin), child: Text(isLogin ? 'Crear una cuenta' : 'Ya tengo cuenta')),
            ])));
  }
}
