import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DashBoard.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  File? _nidFrontImage;
  File? _nidBackImage;
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (imageType == 'profile') {
          _profileImage = File(pickedFile.path);
        } else if (imageType == 'nidFront') {
          _nidFrontImage = File(pickedFile.path);
        } else if (imageType == 'nidBack') {
          _nidBackImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _submitProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final profileData = {
      'name': _nameController.text,
      'nid': _nidController.text,
      'profileImage': _profileImage?.path ?? '',
      'nidFrontImage': _nidFrontImage?.path ?? '',
      'nidBackImage': _nidBackImage?.path ?? '',
    };
    await prefs.setString('pendingModeratorProfile', jsonEncode(profileData));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile submitted for approval')),
    );
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nidController.text = prefs.getString('nidNumber') ?? '';
      _nameController.text = prefs.getString('userName') ?? '';
      String? profileImagePath = prefs.getString('profileImage');
      String? nidFrontImagePath = prefs.getString('nidFrontImage');
      String? nidBackImagePath = prefs.getString('nidBackImage');
      if (profileImagePath != null) {
        _profileImage = File(profileImagePath);
      }
      if (nidFrontImagePath != null) {
        _nidFrontImage = File(nidFrontImagePath);
      }
      if (nidBackImagePath != null) {
        _nidBackImage = File(nidBackImagePath);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const Dashboard(role: 'moderator', stockItems: []),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        title: const Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _pickImage(ImageSource.gallery, 'profile');
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : const AssetImage('assets/placeholder.png') as ImageProvider,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Moderator\'s Name',
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _nidController,
                decoration: const InputDecoration(
                  labelText: 'NID Card Number',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  _pickImage(ImageSource.gallery, 'nidFront');
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _nidFrontImage != null
                      ? Image.file(_nidFrontImage!, fit: BoxFit.cover)
                      : const Center(child: Icon(Icons.camera_alt, size: 50)),
                ),
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: () {
                  _pickImage(ImageSource.gallery, 'nidBack');
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _nidBackImage != null
                      ? Image.file(_nidBackImage!, fit: BoxFit.cover)
                      : const Center(child: Icon(Icons.camera_alt, size: 50)),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _submitProfile,
                child: const Text('Submit for Approval'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
///
///
///
///
///
///
/// =======-------removing the quantity,,
///


