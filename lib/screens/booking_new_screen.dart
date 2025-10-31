import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingNewScreen extends StatefulWidget {
  final String serviceId;
  final String serviceTitle;
  const BookingNewScreen({super.key, required this.serviceId, required this.serviceTitle});
  @override
  State<BookingNewScreen> createState() => _BookingNewScreenState();
}

class _BookingNewScreenState extends State<BookingNewScreen> {
  DateTime _selected = DateTime.now();
  String _start = '09:00';
  String _end = '10:00';
  final _times = [for (int h = 7; h <= 18; h++) '${h.toString().padLeft(2, '0')}:00'];
  bool _isSaving = false;

  Future<void> _create() async {
    // kept for compatibility; delegate to _createBooking
    await _createBooking();
  }

  Future<void> _createBooking() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No hay usuario autenticado';

      final selectedDay = DateTime(_selected.year, _selected.month, _selected.day);
      final startTime = _start;
      final endTime = _end;

      if (selectedDay == null) throw 'Seleccione una fecha';
      if (startTime.isEmpty || endTime.isEmpty) throw 'Seleccione horas';

      final Map<String, dynamic> booking = {
        'userId': user.uid,
        'serviceId': widget.serviceId,
        'serviceTitle': widget.serviceTitle,
        'date': Timestamp.fromDate(selectedDay),
        'startTime': startTime,
        'endTime': endTime,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Trace payload before write
      debugPrint('📦 booking payload => $booking');

      await FirebaseFirestore.instance.collection('bookings').add(booking);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva creada exitosamente')));
        Navigator.pop(context);
      }
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException code=${e.code} msg=${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Firestore: ${e.code}')));
      }
    } catch (e) {
      debugPrint('❌ Error creando booking: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> createBooking({
    required String serviceId,
    required String serviceTitle,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final booking = {
      'userId': user.uid,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // debug
    debugPrint('Creating booking: $booking');

    await FirebaseFirestore.instance.collection('bookings').add(booking);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reservar — ${widget.serviceTitle}')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          TableCalendar(firstDay: DateTime.now(), lastDay: DateTime.now().add(const Duration(days: 365)), focusedDay: _selected, selectedDayPredicate: (d) => isSameDay(d, _selected), onDaySelected: (d, _) => setState(() => _selected = d)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: DropdownButtonFormField<String>(value: _start, items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _start = v!))),
            const SizedBox(width: 8),
            Expanded(child: DropdownButtonFormField<String>(value: _end, items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) => setState(() => _end = v!))),
          ]),
          const Spacer(),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    setState(() => _isSaving = true);
                    await _createBooking();
                    if (mounted) setState(() => _isSaving = false);
                  },
            child: _isSaving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Crear agenda'),
          )
        ]),
      ),
    );
  }
}
