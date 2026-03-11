// lib/add_project_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddProjectScreen extends StatefulWidget {
  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _progressController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // REEMPLAZA con tus datos
  final String mockApiUrl = 'https://69ab0c54e051e9456fa32ffc.mockapi.io/tracker/projects';
  final String cloudName = 'dgrgazgsq'; 
  final String uploadPreset = 'app_proyectos'; 

  // Función para abrir la cámara
  Future<void> _tomarFoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      print("Error al abrir la cámara: $e");
    }
  }

  // Función para subir a Cloudinary
  // Función con rastreo para Cloudinary
  Future<String?> _uploadToCloudinary(File image) async {
    print("1. Iniciando subida a Cloudinary...");
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;

    print("1.5 Leyendo los bytes de la imagen...");
    // AQUÍ ESTÁ LA MAGIA: Leemos la imagen a memoria primero
    final bytes = await image.readAsBytes(); 
    
    // Y la enviamos como bytes puros, no como ruta de archivo
    request.files.add(http.MultipartFile.fromBytes(
      'file', 
      bytes, 
      filename: 'proyecto_foto.jpg'
    ));

    print("2. Enviando petición a Cloudinary...");
    // Le ponemos un límite de 20 segundos para que no se congele
    final response = await request.send().timeout(const Duration(seconds: 20));
    
    print("3. Respuesta de Cloudinary recibida: ${response.statusCode}");
    
    final responseData = await response.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    
    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(responseString);
      print("4. Imagen subida con éxito: ${jsonRes['secure_url']}");
      return jsonRes['secure_url'];
    } else {
      print("ERROR EN CLOUDINARY: $responseString");
      return null;
    }
  }

  // Función con rastreo para Guardar
  Future<void> _guardarProyecto() async {
    print("--- INICIANDO GUARDADO ---");
    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      
      if (_imageFile != null) {
        print("A. Hay imagen, intentando subir...");
        imageUrl = await _uploadToCloudinary(_imageFile!);
      } else {
        print("A. No se seleccionó imagen, guardando solo texto.");
      }

      print("B. Preparando datos para MockAPI...");
      final newProject = {
        'name': _nameController.text,
        'description': _descController.text,
        'progress': _progressController.text.isEmpty ? 0 : int.parse(_progressController.text),
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      print("C. Enviando a MockAPI ($mockApiUrl)...");
      final response = await http.post(
        Uri.parse(mockApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newProject),
      );

      print("D. Respuesta de MockAPI: ${response.statusCode}");
      if (response.statusCode == 201) {
        print("E. Guardado exitoso. Regresando...");
        Navigator.pop(context, true);
      } else {
        print("F. Error del servidor MockAPI: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("!!! EXCEPCIÓN DETECTADA !!! : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error (revisa la consola)')),
      );
    } finally {
      print("--- FIN DEL PROCESO ---");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuevo Proyecto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nombre')),
            TextField(controller: _descController, decoration: InputDecoration(labelText: 'Descripción')),
            TextField(controller: _progressController, decoration: InputDecoration(labelText: 'Progreso (0-100)'), keyboardType: TextInputType.number),
            SizedBox(height: 20),
            
            // Vista previa de la imagen
            _imageFile != null 
                ? Image.file(_imageFile!, height: 150) 
                : Container(height: 150, color: Colors.grey[200], child: Icon(Icons.image, size: 50)),
            
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Tomar Foto'),
              onPressed: _tomarFoto,
            ),
            SizedBox(height: 20),
            
            _isLoading 
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _guardarProyecto,
                    child: Text('Guardar'),
                  ),
          ],
        ),
      ),
    );
  }
}