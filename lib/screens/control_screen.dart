import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/clothes_provider.dart';
import '../services/notification_service.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Load initial status when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClothesProvider>(context, listen: false).updateStatus();
      _setupNotificationListeners();
    });
  }

  void _setupNotificationListeners() {
    // Listen for rain detected
    NotificationService.onRainDetected = (data) {
      _showNotificationSnackBar(
        'Rain Detected! 🌧️',
        'Moving clothes inside automatically',
        Colors.blue,
      );
    };

    // Listen for rain stopped
    NotificationService.onRainStopped = (data) {
      _showNotificationSnackBar(
        'Rain Stopped! ☀️',
        'Clothes will move outside in 1 second',
        Colors.green,
      );
    };

    // Listen for clothes moved inside
    NotificationService.onClothesMovedInside = (data) {
      _showNotificationSnackBar(
        'Clothes Moved Inside 🏠',
        'Your clothes are now protected',
        Colors.orange,
      );
    };

    // Listen for clothes moved outside
    NotificationService.onClothesMovedOutside = (data) {
      _showNotificationSnackBar(
        'Clothes Moved Outside ☀️',
        'Your clothes are now drying',
        Colors.green,
      );
    };

    // Listen for auto mode toggled
    NotificationService.onAutoModeToggled = (data) {
      final isEnabled = data['enabled'] == 'true';
      _showNotificationSnackBar(
        isEnabled ? 'Auto Mode Enabled 🤖' : 'Auto Mode Disabled 🖱️',
        isEnabled
            ? 'Auto rain detection is now active'
            : 'Manual control only',
        isEnabled ? Colors.blue : Colors.grey,
      );
    };
  }

  void _showNotificationSnackBar(String title, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothes Remote'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.rotateCw),
            onPressed: () {
              Provider.of<ClothesProvider>(context, listen: false).updateStatus();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ClothesProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main Status Display
                  _buildMainStatusCard(provider),
                  const SizedBox(height: 24),

                  // Quick Control Buttons
                  _buildQuickControlButtons(provider),
                  const SizedBox(height: 24),

                  // Auto Mode Card
                  _buildAutoModeCard(provider),
                  const SizedBox(height: 24),

                  // Sensor Details
                  _buildSensorDetailsCard(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainStatusCard(ClothesProvider provider) {
    final isClothesOutside = provider.currentState.clothesOutside;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6366F1).withValues(alpha: 0.1),
              const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Large Status Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    isClothesOutside
                        ? LucideIcons.sun
                        : LucideIcons.home,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Text
              Text(
                isClothesOutside ? 'Clothes Outside' : 'Clothes Inside',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),

              // Status Description
              Text(
                provider.currentState.status,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Connection Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: provider.isConnected
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: provider.isConnected
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.isConnected
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.isConnected ? 'Connected' : 'Mock Mode',
                      style: TextStyle(
                        color: provider.isConnected
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickControlButtons(ClothesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Control',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: LucideIcons.home,
                label: 'Move Inside',
                color: const Color(0xFFF97316),
                onPressed: provider.isLoading
                    ? null
                    : () => provider.moveClothesInside(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: LucideIcons.sun,
                label: 'Move Outside',
                color: const Color(0xFF22C55E),
                onPressed: provider.isLoading
                    ? null
                    : () => provider.moveClothesOutside(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
            color: color.withValues(alpha: 0.05),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAutoModeCard(ClothesProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto Rain Detection',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.currentState.autoMode
                        ? 'Automatically hides clothes when raining'
                        : 'Manual control only',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch.adaptive(
              value: provider.currentState.autoMode,
              onChanged: provider.isLoading
                  ? null
                  : (value) => provider.toggleAutoMode(),
              activeThumbColor: const Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorDetailsCard(ClothesProvider provider) {
    final rainValue = provider.currentState.rainValue;
    final isRaining = provider.currentState.isRaining;
    final rainPercentage = (rainValue / 1023 * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensor Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),

            // Rain Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isRaining ? LucideIcons.cloudRain : LucideIcons.cloud,
                      color: isRaining ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rain Status',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isRaining
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isRaining ? 'Raining' : 'No Rain',
                    style: TextStyle(
                      color: isRaining ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rain Sensor Value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sensor Reading',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '$rainValue / 1023',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: rainValue / 1023,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  rainValue < 500 ? Colors.red : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$rainPercentage% moisture detected',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
