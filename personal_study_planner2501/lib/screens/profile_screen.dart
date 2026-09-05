// User profile screen

//----------------------------------------------------------------------
//Import required packages
//------------------------------------------------------------------------
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/auth_error_messages.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Image picker and supabase client
  final _client = Supabase.instance.client;
  final _imagePicker = ImagePicker();

  //-------------------------------------------------
  // Controllers for profile fields
  //-----------------------------------------------------
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _programmeController = TextEditingController();
  final _yearOfStudyController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  String? _avatarPath;

  @override
  void initState() {
    super.initState();

    final user = _client.auth.currentUser;

    if (user != null) { _emailController.text = user.email ?? '';}

    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _programmeController.dispose();
    _yearOfStudyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  //-----------------------------------------
  // Method to load the authenticated user's profile
  //-------------------------------------------
  Future<void> _loadProfile() async
  {
    final user = _client.auth.currentUser;

    if (user == null)
      {
        _showMessage('Your session could not be found. Please sign in again');
        return;
      }

    setState(() {
      _isLoading = true;
    });

    try
    {
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null)
      {
        await _createEmptyProfile(user.id);
        return;
      }

      if(!mounted){return;}

      _populateProfile(profile);
    }
    catch (error)
    {
      if(!mounted){
        return;
      }

      _showMessage(getAuthErrorMessage(error));
    }
    finally
    {
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  //---------------------------------------------------------------------
  // Method to create the profile row for a newly authenticated user
  //---------------------------------------------------------------------
  Future<void> _createEmptyProfile(String userId) async
  {
    await _client.from('profiles').insert({'id': userId});

    if(!mounted){return;}

    _showMessage('Your profile has been created. You can complete it below.');
  }

  // ---------------------------------------------------------------------------
  // Populate the form with profile data
   // ---------------------------------------------------------------------------

  void _populateProfile(Map<String, dynamic> profile) {
    _fullNameController.text =
        profile['full_name'] as String? ?? '';

    _studentIdController.text =
        profile['student_id'] as String? ?? '';

    _programmeController.text =
        profile['programme'] as String? ?? '';

    _yearOfStudyController.text =
        profile['year_of_study']?.toString() ?? '';

    _bioController.text =
        profile['bio'] as String? ?? '';

    _avatarPath =
    profile['avatar_url'] as String?;
  }

// ---------------------------------------------------------------------------
// Save profile details
// ---------------------------------------------------------------------------

  Future<void> _saveProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      _showMessage('Your session could not be found. Please sign in again.');
      return;
    }

    final fullName = _fullNameController.text.trim();
    final studentId = _studentIdController.text.trim();
    final programme = _programmeController.text.trim();
    final yearOfStudyText = _yearOfStudyController.text.trim();
    final bio = _bioController.text.trim();

    if (fullName.isEmpty) {
      _showMessage('Please enter your full name.');
      return;
    }

    if (studentId.isEmpty) {
      _showMessage('Please enter your student ID.');
      return;
    }

    if (programme.isEmpty) {
      _showMessage('Please enter your programme of study.');
      return;
    }

    int? yearOfStudy;

    if (yearOfStudyText.isNotEmpty) {
      yearOfStudy = int.tryParse(yearOfStudyText);

      if (yearOfStudy == null || yearOfStudy < 1) {
        _showMessage('Please enter a valid year of study.');
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _client.from('profiles').upsert(
        {
          'id': user.id,
          'full_name': fullName,
          'student_id': studentId,
          'programme': programme,
          'year_of_study': yearOfStudy,
          'bio': bio.isEmpty ? null : bio,
          'avatar_url': _avatarPath,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );

      if (!mounted) {
        return;
      }

      _showMessage('Profile saved successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(getAuthErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Method to pick and upload an avatar
  // ---------------------------------------------------------------------------
  Future<void> _pickAndUploadAvatar() async
  {
    final user = _client.auth.currentUser;

    if (user == null)
    {
      _showMessage('Your session could not be found. Please sign in again.');
      return;
    }

    try
    {
      final image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1200,
      );

      if(image == null){return;}

      setState(() {
        _isUploadingAvatar = true;
      });

      // Image details
      final imageFile = File(image.path);
      final extension = _getImageExtension(image.path);
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storagePath = '${user.id}/$fileName';

      await _client.storage.from('avatars').upload(
          storagePath,
          imageFile,
          fileOptions: FileOptions(cacheControl: '3600', upsert: true)
      );

      await _client.from('profiles').update({
        'avatar_url': storagePath,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', user.id);

      if(!mounted){return;}

      setState(() {
        _avatarPath = storagePath;
      });

      _showMessage('Profile photo successfully updated!');
    }
    catch (error) {
      if
      (!mounted) {return;}
      _showMessage(getAuthErrorMessage(error));
    }
    finally{
      if(mounted){
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Method to determine the uploaded image extension
  // ---------------------------------------------------------------------------
  String _getImageExtension(String filePath)
  {
    final lowerCasePath = filePath.toLowerCase();
    if(lowerCasePath.endsWith('.png')) {return 'png';}
    if(lowerCasePath.endsWith('.webp')) {return 'webp';}
    return 'jpg';
  }

  // ---------------------------------------------------------------------------
  // Method to build the avatar image
  // ---------------------------------------------------------------------------
  Widget _buildAvatar()
  {
    if(_avatarPath == null || _avatarPath!.isEmpty)
      {
        return const CircleAvatar(
          radius: 60,
          child: Icon(Icons.person_rounded, size: 60.0,),
        );
      }

    final avatarUrl = _client.storage
        .from('avatars')
        .getPublicUrl(_avatarPath!);

    return CircleAvatar(radius: 60, backgroundImage: NetworkImage(avatarUrl));
  }

  //------------------------------------------
  // User feedback method
  //------------------------------------------
  void _showMessage(String message)
  {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context)
  {
    if(_isLoading)
      {
        return Scaffold(
          appBar: AppBar(title: const Text('My Profile'),),
          body: Center(child: CircularProgressIndicator(),),
        );
      }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'),),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                maxWidth: 600,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //------------------------------------------------------------
                // Avatar
                //-----------------------------------------------------------
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _buildAvatar(),

                      FloatingActionButton.small(
                        onPressed: _isUploadingAvatar
                            ? null
                            : _pickAndUploadAvatar,
                        tooltip: 'Change profile photo',
                        child: _isUploadingAvatar
                            ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2,),
                        )
                            : const Icon(Icons.camera_alt_rounded),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32.0),
                //-------------------------------------------------------------
                // Email
                //-------------------------------------------------------------
                TextField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 16.0),
                //-------------------------------------------------------------
                // Full Name
                //-------------------------------------------------------------
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                ),

                const SizedBox(height: 16.0),
                //-------------------------------------------------------------
                // Student Id
                //-------------------------------------------------------------
                TextField(
                  controller: _studentIdController,
                  decoration: InputDecoration(
                    labelText: 'Student ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_rounded)
                  ),
                  ),

                const SizedBox(height: 16.0),
                //-------------------------------------------------------------
                // Programme
                //-------------------------------------------------------------
                TextField(
                  controller: _programmeController,
                  decoration: InputDecoration(
                    labelText: 'Programme of study',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_outlined)
                  ),
                  ),

                const SizedBox(height: 16.0),
                //-------------------------------------------------------------
                // Year of study
                //-------------------------------------------------------------
                TextField(
                  controller: _yearOfStudyController,
                  decoration: InputDecoration(
                    labelText: 'Year of Study',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_rounded)
                  ),
                  ),

                const SizedBox(height: 16.0),
                //-------------------------------------------------------------
                // Short Biography
                //-------------------------------------------------------------
                TextField(
                  controller: _bioController,
                  minLines: 4,
                  maxLines: 7,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: 'Short bio',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes_outlined)
                  ),
                  ),

                const SizedBox(height: 16.0),
                //-------------------------------------------------------------
                // Save button
                //-------------------------------------------------------------
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  )
                      : const Icon(Icons.save_rounded),
                  label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
