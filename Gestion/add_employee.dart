import 'package:flutter/material.dart';
import 'package:mini_project/Model/Employee.dart';
import 'package:mini_project/Service/ApiService.dart';

class AddEmployeeDialog extends StatefulWidget {
  final Function(Employee) onEmployeeAdded;

  AddEmployeeDialog({required this.onEmployeeAdded});

  @override
  _AddEmployeeDialogState createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Employee',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
            fontSize: 25,
          )),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Name', Icons.person, nameController),
              _buildTextField('Email', Icons.email, emailController,
                  validator: (value) {
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value ?? '')) {
                      return 'Enter a valid email.';
                    }
                    return null;
                  }),
              _buildTextField(
                'Password',
                Icons.lock,
                passwordController,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              _buildTextField('Phone', Icons.phone, phoneController),
              _buildTextField('Department', Icons.business, departmentController),
              _buildTextField('Status', Icons.info, statusController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final employee = Employee(
                id: 0,
                name: nameController.text,
                email: emailController.text,
                password: passwordController.text,
                phone: phoneController.text,
                department: departmentController.text,
                status: statusController.text,
              );

              await apiService.addEmployee(employee);
              widget.onEmployeeAdded(employee);

              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller,
      {bool obscureText = false, Widget? suffixIcon, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[900]),
        suffixIcon: suffixIcon,
      ),
      validator: validator ?? (value) => value == null || value.isEmpty ? 'This field is required.' : null,
    );
  }
}
