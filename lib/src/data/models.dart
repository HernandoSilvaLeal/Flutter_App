class AppUser {
  String uid;
  String name;
  String email;
  String role;
  String phone;
  AppUser({required this.uid, required this.name, required this.email, required this.role, required this.phone});
}

class Appointment {
  String id;
  String clientId;
  String providerId;
  String serviceId;
  String serviceName;
  String status;
  DateTime scheduledFor;
  Appointment({required this.id, required this.clientId, required this.providerId, required this.serviceId, required this.serviceName, required this.status, required this.scheduledFor});
}
