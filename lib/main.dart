import 'package:flutter/material.dart';
import 'Authentication/login.dart';
import 'Model/Employee.dart';
import 'SearchEmployee.dart';
import 'Service/ApiService.dart';
import 'Service/AuthService.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiService apiService = ApiService();
  final AuthService authService = AuthService();
  late Future<List<Employee>> employees;

  @override
  void initState() {
    super.initState();
    employees = apiService.fetchEmployees();
  }

  void _addEmployee(Employee employee) {
    setState(() {
      employees = apiService.fetchEmployees();
    });
  }

  void _deleteEmployee(int id) {
    setState(() {
      employees = apiService.fetchEmployees();
    });
  }

  void _updateEmployee(int id, Employee employee) {
    setState(() {
      employees = apiService.fetchEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchEmployee()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      body: FutureBuilder<List<Employee>>(
        future: employees,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load employees: ${snapshot.error}'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final employee = snapshot.data![index];
                return ListTile(
                  title: Text(employee.name),
                  subtitle: Text(employee.department),
                  onTap: () {
                    _showEmployeeDetails(employee);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue[900]),
                        onPressed: () {
                          _showUpdateDialog(employee);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[900]),
                        onPressed: () {
                          _showDeleteConfirmation(employee);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showEmployeeDetails(Employee employee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Employee Details',
            style: TextStyle(
              color: Colors.blue[900],
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name:', employee.name),
              _buildDetailRow('Email:', employee.email),
              _buildDetailRow('Phone:', employee.phone),
              _buildDetailRow('Department:', employee.department),
              _buildDetailRow('Status:', employee.status),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          text: label + ' ',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Employee employee) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete',
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 20,
              )),
          content: Text('Are you sure you want to delete ${employee.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
              onPressed: () {
                apiService.deleteEmployee(employee.id).then((_) {
                  _deleteEmployee(employee.id);
                  Navigator.of(context).pop();
                });
              },
              child: Text('Delete', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog() {
    final _formKey = GlobalKey<FormState>();

    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController departmentController = TextEditingController();
    TextEditingController statusController = TextEditingController();

    bool _isPasswordVisible = false;
    showDialog(
      context: context,
      builder: (context) {
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
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email.';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password.';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number.';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Please enter a valid phone number.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: departmentController,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.business, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a department.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: statusController,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.info, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a status.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  apiService
                      .addEmployee(Employee(
                    id: 0,
                    name: nameController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    phone: phoneController.text,
                    department: departmentController.text,
                    status: statusController.text,
                  ))
                      .then((_) {
                    _addEmployee(Employee(
                      id: 0,
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      phone: phoneController.text,
                      department: departmentController.text,
                      status: statusController.text,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }


  void _showUpdateDialog(Employee employee) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController nameController = TextEditingController(text: employee.name);
    TextEditingController emailController = TextEditingController(text: employee.email);
    TextEditingController passwordController = TextEditingController(text: employee.password);
    TextEditingController phoneController = TextEditingController(text: employee.phone);
    TextEditingController departmentController = TextEditingController(text: employee.department);
    TextEditingController statusController = TextEditingController(text: employee.status);

    bool _isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Employee',
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
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email.';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: !_isPasswordVisible,
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password.';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number.';
                      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Please enter a valid phone number.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: departmentController,
                    decoration: InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.business, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a department.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: statusController,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.info, color: Colors.blue[900]),
                      labelStyle: TextStyle(color: Colors.blue[900]),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a status.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  apiService
                      .updateEmployee(
                    employee.id,
                    Employee(
                      id: employee.id,
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      phone: phoneController.text,
                      department: departmentController.text,
                      status: statusController.text,
                    ),
                  )
                      .then((_) {
                    _updateEmployee(employee.id, Employee(
                      id: employee.id,
                      name: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      phone: phoneController.text,
                      department: departmentController.text,
                      status: statusController.text,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}