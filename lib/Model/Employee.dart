
class Employee {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String department;
  final String status;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.department,
    required this.status,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id ?? 0,
      'name': name ?? '',
      'email': email ?? '',
      'password': password ?? '',
      'phone': phone ?? '',
      'department': department ?? '',
      'status': status ?? '',
    };
  }
}