// --------------------------------------------------------------------------
// Widget to display the current synchronisation status
// --------------------------------------------------------------------------

// Imports
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../services/sync_services.dart';

class SyncStatusBanner extends StatefulWidget {
  const SyncStatusBanner({super.key});

  @override
  State<SyncStatusBanner> createState() =>
      _SyncStatusBannerState();
}

class _SyncStatusBannerState extends State<SyncStatusBanner> {
  final _databaseHelper = DatabaseHelper.instance;
  final _syncService = SyncService.instance;

  StreamSubscription<List<ConnectivityResult>>?
  _connectivitySubscription;

  bool _isOnline = true;
  int _pendingCount = 0;
  bool _isSynchronising = false;

  @override
  void initState() {
    super.initState();

    _loadStatus();

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(
              (results) {
            final online = results.any(
                  (result) => result != ConnectivityResult.none,
            );

            if (!mounted) {
              return;
            }

            setState(() {
              _isOnline = online;
            });

            _loadStatus();
          },
        );
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Load current synchronisation status
  // ---------------------------------------------------------------------------

  Future<void> _loadStatus() async {
    try {
      final connectivity =
      await Connectivity().checkConnectivity();

      final pendingCount =
      await _databaseHelper.getPendingSyncCount();

      if (!mounted) {
        return;
      }

      setState(() {
        _isOnline = connectivity.any(
              (result) => result != ConnectivityResult.none,
        );

        _pendingCount = pendingCount;
        _isSynchronising =
            _syncService.isSynchronising;
      });
    } catch (_) {
      // The banner is only a status indicator.
    }
  }

  // ---------------------------------------------------------------------------
  // Manually synchronise
  // ---------------------------------------------------------------------------

  Future<void> _syncNow() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSynchronising = true;
    });

    await _syncService.syncNow();

    await _loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      return MaterialBanner(
        content: const Text(
          'You are offline. Changes will be synchronised '
              'when an internet connection is available.',
        ),
        leading: const Icon(Icons.cloud_off),
        actions: [
          TextButton(
            onPressed: _loadStatus,
            child: const Text('RETRY'),
          ),
        ],
      );
    }

    if (_pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return MaterialBanner(
      content: Text(
        _isSynchronising
            ? 'Synchronising changes...'
            : '$_pendingCount change(s) waiting to synchronise.',
      ),
      leading: const Icon(Icons.sync),
      actions: [
        TextButton(
          onPressed: _isSynchronising ? null : _syncNow,
          child: const Text('SYNC NOW'),
        ),
      ],
    );
  }
}