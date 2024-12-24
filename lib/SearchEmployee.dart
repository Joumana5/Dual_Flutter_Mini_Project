import 'package:flutter/material.dart';
import '../Model/Employee.dart';
import 'Service/ApiService.dart';

class SearchEmployee extends StatefulWidget {
  @override
  _SearchEmployeeState createState() => _SearchEmployeeState();
}

class _SearchEmployeeState extends State<SearchEmployee> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Employee> allEmployees = [];
  List<Employee> filteredEmployees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      List<Employee> employees = await _apiService.fetchEmployees();
      setState(() {
        allEmployees = employees;
        filteredEmployees = employees;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching employees: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load employees')),
      );
    }
  }

  void filterEmployees(String query) {
    setState(() {
      filteredEmployees = allEmployees
          .where((employee) =>
      employee.name.toLowerCase().contains(query.toLowerCase()) ||
          employee.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Employee',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            )),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter employee name or email',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    filterEmployees(_searchController.text);
                  },
                ),
              ),
              onChanged: (value) {
                filterEmployees(value);
              },
            ),
            const SizedBox(height: 16.0),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: filteredEmployees.isEmpty
                  ? Center(child: Text('No employees found'))
                  : ListView.builder(
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = filteredEmployees[index];
                  return ListTile(
                    title: Text(employee.name),
                    subtitle: Text(
                        '${employee.department} - ${employee.email}'),
                    onTap: () {

                      print('Selected Employee: ${employee.name}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
