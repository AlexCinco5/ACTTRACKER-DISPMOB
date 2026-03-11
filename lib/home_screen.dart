// lib/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'project_model.dart';
import 'add_project_screen.dart';
import 'project_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // REEMPLAZA ESTA URL con tu endpoint real de MockAPI
  final String apiUrl = 'https://69ab0c54e051e9456fa32ffc.mockapi.io/tracker/projects'; 

  Future<List<Project>> fetchProjects() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Project.fromJson(item)).toList();
    } else {
      throw Exception('Error al conectar con la API'); // Paso 6: Resiliencia
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Project Tracker')),
      body: FutureBuilder<List<Project>>(
        future: fetchProjects(),
        builder: (context, snapshot) {
          // Estado: Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } 
          // Estado: Error
          else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Hubo un problema: ${snapshot.error}', // Mensaje amigable
                style: TextStyle(color: Colors.red),
              ),
            );
          } 
          // Estado: Completado (sin datos)
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay proyectos aún. ¡Agrega uno!'));
          }

          // Estado: Completado (con datos)
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final project = snapshot.data![index];
              return ListTile(
                leading: project.imageUrl != null 
                    ? CircleAvatar(backgroundImage: NetworkImage(project.imageUrl!))
                    : CircleAvatar(child: Icon(Icons.folder)),
                title: Text(project.name),
                subtitle: Text('Progreso: ${project.progress}%'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailScreen(project: project),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Navegamos y esperamos el resultado (Paso 5)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProjectScreen()),
          );
          
          // Si recibimos 'true', recargamos la pantalla
          if (result == true) {
            setState(() {});
          }
        },
      ),
    );
  }
}