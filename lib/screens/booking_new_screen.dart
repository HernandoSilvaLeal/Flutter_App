import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingNewScreen extends StatefulWidget {
  final String serviceId;
  final String serviceTitle;
  final String serviceImage;
  const BookingNewScreen({super.key, required this.serviceId, required this.serviceTitle, required this.serviceImage});
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
    // Validate incoming service args
    if (widget.serviceId.trim().isEmpty || widget.serviceTitle.trim().isEmpty) {
      debugPrint('🔥 Booking missing service args: id="${widget.serviceId}" title="${widget.serviceTitle}"');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: datos del servicio incompletos')));
      }
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No hay usuario autenticado';

      final selectedDay = DateTime(_selected.year, _selected.month, _selected.day);
      final startTime = _start;
      final endTime = _end;

      if (startTime.isEmpty || endTime.isEmpty) throw 'Seleccione horas';

      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final Map<String, dynamic> booking = {
        'id': id,
        'userId': user.uid,
        'serviceId': widget.serviceId,
        'serviceTitle': widget.serviceTitle,
        'serviceImage': widget.serviceImage,
        'date': selectedDay.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Trace payload before write
      debugPrint('📦 booking payload => $booking');

      await FirebaseFirestore.instance.collection('bookings').doc(id).set(booking);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text('Reserva creada correctamente')));
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    } on FirebaseException catch (e) {
      debugPrint('❌ FirebaseException code=${e.code} msg=${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Firestore: ${e.code}')));
      }
    } catch (e, st) {
      debugPrint('❌ Error creando booking: $e\n$st');
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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _selected,
                selectedDayPredicate: (d) => isSameDay(d, _selected),
                onDaySelected: (d, _) => setState(() => _selected = d),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _start,
                  items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _start = v!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _end,
                  items: _times.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _end = v!),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setState(() => _isSaving = true);
                          try {
                            await _createBooking();
                          } finally {
                            if (mounted) setState(() => _isSaving = false);
                          }
                        },
                  child: _isSaving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Crear agenda'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
