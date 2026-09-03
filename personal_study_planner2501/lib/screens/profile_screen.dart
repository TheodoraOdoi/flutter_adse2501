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
// Pick and upload an avatar
// ---------------------------------------------------------------------------


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
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
