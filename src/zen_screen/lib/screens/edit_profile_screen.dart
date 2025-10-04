import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_providers.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/zen_button.dart';
import '../widgets/zen_input_field.dart';

/// Edit Profile Screen - Feature 14 Implementation
/// 
/// **Product Learning Note:**
/// Profile editing is a sensitive area - users expect:
/// 1. Quick, easy updates
/// 2. Clear feedback on changes
/// 3. Ability to cancel without losing data
/// 4. Validation that prevents errors
/// 
/// **UX Principles:**
/// - Form validation should be helpful, not annoying
/// - Save button should be prominent and easy to tap
/// - Cancel should ask for confirmation if there are unsaved changes
/// - Show loading states during saves
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  String? _avatarUrl;
  File? _selectedImage;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Load current user profile data
  /// **Product Note**: Always prefill forms with existing data
  Future<void> _loadUserProfile() async {
    final authState = ref.read(authControllerProvider);
    if (authState is! Authenticated) return;

    final repository = ref.read(userRepositoryProvider);
    final profile = await repository.getById(authState.user.id);

    if (profile != null && mounted) {
      setState(() {
        _nameController.text = profile.displayName ?? '';
        _avatarUrl = profile.avatarUrl;
      });
    }
  }

  /// Pick and upload avatar image
  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      setState(() {
        _isUploadingAvatar = true;
      });

      // Pick image
      final imagePicker = ref.read(imagePickerServiceProvider);
      final imageFile = await imagePicker.pickImage(source: source);

      if (imageFile == null) {
        setState(() {
          _isUploadingAvatar = false;
        });
        return;
      }

      // Upload to Firebase Storage
      final authState = ref.read(authControllerProvider);
      if (authState is! Authenticated) return;

      final storageService = ref.read(storageServiceProvider);
      final downloadUrl = await storageService.uploadAvatar(
        userId: authState.user.id,
        imageFile: imageFile,
        onProgress: (progress) {
          // Could show progress here if needed
        },
      );

      // Update local state
      setState(() {
        _avatarUrl = downloadUrl;
        _selectedImage = imageFile;
        _hasUnsavedChanges = true;
        _isUploadingAvatar = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar uploaded! Don\'t forget to save changes.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingAvatar = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show avatar picker options
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) {
        if (!didPop && _hasUnsavedChanges) {
          _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.backgroundLight,
                AppTheme.backgroundGray,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                
                // Form content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.spaceLG),
                    child: Form(
                      key: _formKey,
                      onChanged: () {
                        setState(() {
                          _hasUnsavedChanges = true;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GlassCard(
                            padding: const EdgeInsets.all(AppTheme.spaceLG),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Information',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spaceLG),
                                
                                // Avatar Section
                                Center(
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 60,
                                            backgroundColor: AppTheme.primaryGreen,
                                            backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                                ? NetworkImage(_avatarUrl!)
                                                : null,
                                            child: _isUploadingAvatar
                                                ? const CircularProgressIndicator(
                                                    color: Colors.white,
                                                  )
                                                : (_avatarUrl == null || _avatarUrl!.isEmpty)
                                                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                                                    : null,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryGreen,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppTheme.backgroundLight,
                                                  width: 3,
                                                ),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                                onPressed: _isUploadingAvatar ? null : _showAvatarPicker,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppTheme.spaceMD),
                                      Text(
                                        'Tap camera to change avatar',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: AppTheme.spaceXL),
                                
                                // Name field
                                Text(
                                  'Display Name',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spaceSM),
                                ZenInputField(
                                  controller: _nameController,
                                  hint: 'Enter your name',
                                  prefix: const Icon(Icons.person_outline),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Name cannot be empty';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'Name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: AppTheme.spaceLG),
                                
                                // Email (read-only)
                                Text(
                                  'Email Address',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spaceSM),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final authState = ref.watch(authControllerProvider);
                                    final email = authState is Authenticated 
                                        ? authState.user.email 
                                        : 'Not logged in';
                                    
                                    return Container(
                                      padding: const EdgeInsets.all(AppTheme.spaceMD),
                                      decoration: BoxDecoration(
                                        color: AppTheme.borderLight.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                        border: Border.all(
                                          color: AppTheme.borderLight,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.email_outlined,
                                            color: AppTheme.textLight,
                                            size: 20,
                                          ),
                                          const SizedBox(width: AppTheme.spaceSM),
                                          Expanded(
                                            child: Text(
                                              email ?? 'No email',
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: AppTheme.textLight,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.lock_outline,
                                            color: AppTheme.textLight,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: AppTheme.spaceXS),
                                Text(
                                  'Email cannot be changed for security reasons',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: AppTheme.spaceXL),
                          
                          // Save button
                          ZenButton.primary(
                            _isLoading ? 'Saving...' : 'Save Changes',
                            onPressed: _isLoading ? null : _saveProfile,
                          ),
                          
                          const SizedBox(height: AppTheme.spaceMD),
                          
                          // Cancel button
                          ZenButton.secondary(
                            'Cancel',
                            onPressed: _isLoading ? null : () {
                              if (_hasUnsavedChanges) {
                                _showUnsavedChangesDialog();
                              } else {
                                context.pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build header
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight.withOpacity(0.92),
        border: const Border(
          bottom: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLG),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_hasUnsavedChanges) {
                  _showUnsavedChangesDialog();
                } else {
                  context.pop();
                }
              },
            ),
            const SizedBox(width: AppTheme.spaceSM),
            Text(
              'Edit Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Save profile changes
  /// **Product Note**: Always provide feedback during and after save operations
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    if (authState is! Authenticated) {
      _showErrorSnackBar('You must be logged in to update your profile');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(userRepositoryProvider);
      
      // Get current profile
      final currentProfile = await repository.getById(authState.user.id);
      
      // Create updated profile
      final updatedProfile = (currentProfile ?? UserProfile(
        id: authState.user.id,
        email: authState.user.email ?? '',
        displayName: authState.user.displayName ?? 'User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).copyWith(
        displayName: _nameController.text.trim(),
        avatarUrl: _avatarUrl, // Include avatar URL
        updatedAt: DateTime.now(),
      );
      
      // Save to database
      await repository.upsert(updatedProfile);
      
      setState(() {
        _isLoading = false;
        _hasUnsavedChanges = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: AppTheme.secondaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Wait a moment to show the success message, then navigate back
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      _showErrorSnackBar('Failed to update profile: ${e.toString()}');
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show unsaved changes dialog
  /// **Product Note**: Always warn users before discarding their work
  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (mounted) {
                context.pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}

