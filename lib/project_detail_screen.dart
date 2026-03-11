// lib/project_detail_screen.dart
import 'package:flutter/material.dart';
import 'project_model.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  ProjectDetailScreen({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.imageUrl != null)
              Center(
                child: Image.network(project.imageUrl!, height: 200, fit: BoxFit.cover),
              ),
            SizedBox(height: 20),
            Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(project.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Progreso: ${project.progress}%', style: TextStyle(fontSize: 16)),
            LinearProgressIndicator(value: project.progress / 100),
          ],
        ),
      ),
    );
  }
}