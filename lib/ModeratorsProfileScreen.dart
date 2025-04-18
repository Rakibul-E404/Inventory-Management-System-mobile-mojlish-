
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DashBoard.dart';

class ModeratorsProfilePage extends StatefulWidget {
  @override
  _ModeratorsProfilePageState createState() => _ModeratorsProfilePageState();
}

class _ModeratorsProfilePageState extends State<ModeratorsProfilePage> {
  Map<String, String>? _selectedModerator;
  bool _showDetail = false;

  Future<Map<String, String>> _getPendingProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? profileData = prefs.getString('pendingModeratorProfile');
    if (profileData != null) {
      return Map<String, String>.from(jsonDecode(profileData));
    }
    return {};
  }

  Future<void> _approveProfile(Map<String, String> profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? profilesData =
        prefs.getStringList('approvedModerators') ?? [];
    profilesData.add(jsonEncode(profile));
    await prefs.setStringList('approvedModerators', profilesData);

    // Also save to ProfilePage data
    await prefs.setString('nidNumber', profile['nid']!);
    await prefs.setString('userName', profile['name']!);
    await prefs.setString('profileImage', profile['profileImage']!);
    await prefs.setString('nidFrontImage', profile['nidFrontImage']!);
    await prefs.setString('nidBackImage', profile['nidBackImage']!);

    await prefs.remove('pendingModeratorProfile');
    setState(() {
      _showDetail = false;
      _selectedModerator = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile approved successfully')),
    );
  }

  Future<List<Map<String, String>>> _getApprovedProfiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? profilesData = prefs.getStringList('approvedModerators');
    if (profilesData != null) {
      return profilesData
          .map((data) => Map<String, String>.from(jsonDecode(data)))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderators Profile'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const Dashboard(role: 'admin', stockItems: [],)));
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _showDetail
          ? _buildDetailView()
          : FutureBuilder<Map<String, String>>(
              future: _getPendingProfile(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading profile'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return FutureBuilder<List<Map<String, String>>>(
                    future: _getApprovedProfiles(),
                    builder: (context, approvedSnapshot) {
                      if (approvedSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (approvedSnapshot.hasError) {
                        return const Center(
                            child: Text('Error loading approved profiles'));
                      } else if (!approvedSnapshot.hasData ||
                          approvedSnapshot.data!.isEmpty) {
                        return const Center(child: Text('No profiles found'));
                      } else {
                        List<Map<String, String>> approvedProfiles =
                            approvedSnapshot.data!;
                        return ListView.builder(
                          itemCount: approvedProfiles.length,
                          itemBuilder: (context, index) {
                            Map<String, String> profile =
                                approvedProfiles[index];
                            return ListTile(
                              title: Text(profile['name']!),
                              subtitle: Text('NID: ${profile['nid']}'),
                              onTap: () {
                                setState(() {
                                  _selectedModerator = profile;
                                  _showDetail = true;
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                } else {
                  Map<String, String> pendingProfile = snapshot.data!;
                  return Column(
                    children: [
                      ListTile(
                        title: Text(pendingProfile['name']!),
                        subtitle: Text('NID: ${pendingProfile['nid']}'),
                        onTap: () {
                          setState(() {
                            _selectedModerator = pendingProfile;
                            _showDetail = true;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _approveProfile(pendingProfile);
                        },
                        child: const Text('Approve'),
                      ),
                    ],
                  );
                }
              },
            ),
    );
  }

  Widget _buildDetailView() {
    if (_selectedModerator == null)
      return const Center(child: Text('No moderator selected'));

    final moderator = _selectedModerator!;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: moderator['profileImage'] != null &&
                      moderator['profileImage']!.isNotEmpty
                  ? FileImage(File(moderator['profileImage']!))
                  : const AssetImage('assets/placeholder.png') as ImageProvider,
            ),
            const SizedBox(height: 20.0),
            ListTile(
              title: const Text('Name'),
              subtitle: Text(moderator['name']!),
            ),
            ListTile(
              title: const Text('NID Card Number'),
              subtitle: Text(moderator['nid']!),
            ),
            const SizedBox(height: 20.0),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: moderator['nidFrontImage'] != null &&
                      moderator['nidFrontImage']!.isNotEmpty
                  ? Image.file(File(moderator['nidFrontImage']!),
                      fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.camera_alt, size: 50)),
            ),
            const SizedBox(height: 20.0),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: moderator['nidBackImage'] != null &&
                      moderator['nidBackImage']!.isNotEmpty
                  ? Image.file(File(moderator['nidBackImage']!),
                      fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.camera_alt, size: 50)),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showDetail = false;
                  _selectedModerator = null;
                });
              },
              child: const Text('Back to List'),
            ),
          ],
        ),
      ),
    );
  }
}

///
///
///
///
/// ----------- removing the quantity
///

