import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/Employee.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8080/Employee';
  String jwtToken = '';

  void setToken(String token) {
    jwtToken = token;
  }

  Future<List<Employee>> fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/allEmployees'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );
      print('Fetch Employees Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Employee.fromMap(item)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching employees: $e');
      throw Exception('Failed to load employees: $e');
    }
  }

  Future<Employee> fetchEmployeeDetails(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );
      print('Fetch Employee Details Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        return Employee.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to load employee details: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching employee details: $e');
      throw Exception('Failed to load employee details: $e');
    }
  }

  Future<String> addEmployee(Employee employee) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addEmployee'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode(employee.toMap()),
      );
      print('Add Employee Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to add employee: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error adding employee: $e');
      throw Exception('Failed to add employee: $e');
    }
  }

  Future<String> updateEmployee(int id, Employee employee) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateEmployee/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: json.encode(employee.toMap()),
      );
      print('Update Employee Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to update employee: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating employee: $e');
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<String> deleteEmployee(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteEmployee/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );
      print('Delete Employee Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 403) {
        throw Exception('Failed to delete employee: Forbidden (403)');
      } else {
        throw Exception('Failed to delete employee: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting employee: $e');
      throw Exception('Failed to delete employee: $e');
    }
  }
}