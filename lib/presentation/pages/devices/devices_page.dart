import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../state/dryer_provider.dart';
import '../../../data/models/dryer_device.dart';
import 'device_details_page.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  String _activeFilter = 'All'; // 'All', 'Online', 'Offline'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DryerProvider>(context);
    final devices = provider.devices;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter devices
    List<DryerDevice> filtered = [];
    if (_activeFilter == 'All') {
      filtered = devices;
    } else if (_activeFilter == 'Online') {
      filtered = devices.where((d) => d.isOnline).toList();
    } else if (_activeFilter == 'Offline') {
      filtered = devices.where((d) => !d.isOnline).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Devices',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Bar
            _buildFiltersBar(isDark),

            // Devices List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      itemCount: filtered.length,
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      itemBuilder: (context, index) {
                        final device = filtered[index];
                        return _buildDeviceTile(context, device, provider, isDark);
                      },
                    ),
            ),

            // Add Device CTA at bottom of page
            if (provider.currentUserRole != 'Viewer')
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showAddDeviceModal(context, provider, isDark),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New Device'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersBar(bool isDark) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildFilterButton('All', isDark),
          const SizedBox(width: 8),
          _buildFilterButton('Online', isDark),
          const SizedBox(width: 8),
          _buildFilterButton('Offline', isDark),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isDark) {
    final isSelected = _activeFilter == label;
    final activeBg = isDark ? AppColors.primaryLight : AppColors.primary;
    final activeFg = isDark ? Colors.black : Colors.white;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          _activeFilter = label;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? activeBg : Colors.transparent,
        foregroundColor: isSelected 
            ? activeFg 
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        side: BorderSide(
          color: isSelected 
              ? activeBg 
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(60, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildDeviceTile(BuildContext context, DryerDevice device, DryerProvider provider, bool isDark) {
    final statusColor = device.isOnline ? AppColors.normal : AppColors.offline;
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        
        // Left Column: Custom dryer chassis graphic
        leading: Container(
          width: 42,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Dryer circular viewing window graphic
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: device.isOnline 
                      ? (device.currentCycleId != null ? Colors.amber.shade200 : Colors.blue.shade100) 
                      : Colors.grey.shade400,
                  border: Border.all(color: Colors.grey.shade500, width: 1.5),
                ),
                alignment: Alignment.center,
                child: device.currentCycleId != null 
                    ? const Icon(Icons.rotate_right_outlined, size: 10, color: Colors.orange) 
                    : null,
              ),
              // Vents/slots at bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 3,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    color: Colors.grey.shade600,
                  ),
                ),
              )
            ],
          ),
        ),

        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(
                device.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
        
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.currentUserRole != 'Viewer')
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.critical),
                onPressed: () => _confirmRemoveDevice(context, device, provider),
              )
            else
              const Icon(Icons.chevron_right, size: 20),
          ],
        ),
        
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailsPage(deviceId: device.id),
            ),
          );
        },
      ),
    );
  }

  void _confirmRemoveDevice(BuildContext context, DryerDevice device, DryerProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Connected Device?'),
        content: Text('Are you sure you want to disconnect "${device.name}" (${device.id})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.disconnectDevice(device.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Device "${device.name}" disconnected.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.critical),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.device_hub_outlined,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Devices Registered',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDeviceModal(BuildContext context, DryerProvider provider, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Device',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select Connection Method',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 20),
              
              _buildAddMethodTile(
                icon: Icons.qr_code_scanner, 
                title: 'QR Scanner', 
                subtitle: 'Scan device QR code',
                onTap: () {
                  Navigator.pop(ctx);
                  _runSimulatedScanner(context, provider, isDark);
                },
                isDark: isDark,
              ),
              _buildAddMethodTile(
                icon: Icons.wifi, 
                title: 'WiFi Setup', 
                subtitle: 'Connect device via WiFi',
                onTap: () {
                  Navigator.pop(ctx);
                  _showWifiPairDialog(context, provider, isDark);
                },
                isDark: isDark,
              ),
              _buildAddMethodTile(
                icon: Icons.bluetooth, 
                title: 'Bluetooth', 
                subtitle: 'Connect via Bluetooth',
                onTap: () {
                  Navigator.pop(ctx);
                  _runSimulatedBluetooth(context, provider, isDark);
                },
                isDark: isDark,
              ),
              _buildAddMethodTile(
                icon: Icons.edit_note, 
                title: 'Device ID', 
                subtitle: 'Enter device ID manually',
                onTap: () {
                  Navigator.pop(ctx);
                  _showManualPairDialog(context, provider, isDark);
                },
                isDark: isDark,
              ),
              _buildAddMethodTile(
                icon: Icons.password, 
                title: 'ID & Password', 
                subtitle: 'Enter ID and password',
                onTap: () {
                  Navigator.pop(ctx);
                  _showManualPairDialog(context, provider, isDark);
                },
                isDark: isDark,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDark ? AppColors.primaryLight : AppColors.primary, size: 24),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      ),
    );
  }

  // MOCK: QR Code scanner mockup UI
  void _runSimulatedScanner(BuildContext context, DryerProvider provider, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Scanning QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Aim scanner at sticker', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const LinearProgressIndicator(color: Colors.green),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmRegisterDevice(context, provider, 'Smart Dryer Delta', 'DRY-DLTA-04', 'QR Scanner');
              },
              child: const Text('Simulate Scan'),
            )
          ],
        );
      },
    );
  }

  // MOCK: Bluetooth scanning list mockup UI
  void _runSimulatedBluetooth(BuildContext context, DryerProvider provider, bool isDark) {
    bool scanning = true;
    List<Map<String, String>> discovered = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (scanning) {
              Timer(const Duration(seconds: 1), () {
                if (ctx.mounted) {
                  setState(() {
                    scanning = false;
                    discovered = [
                      {'name': 'Smart Dryer Epsilon', 'id': 'DRY-EPSN-05'},
                    ];
                  });
                }
              });
            }

            return AlertDialog(
              title: const Text('Bluetooth Search'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (scanning) ...[
                    const SizedBox(height: 12),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    const Text('Scanning for dryers...', style: TextStyle(fontSize: 13)),
                  ] else ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Dryer found:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(height: 8),
                    ...discovered.map((d) => Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: const Icon(Icons.bluetooth, color: Colors.blue),
                        title: Text(d['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(d['id']!),
                        onTap: () {
                          Navigator.pop(ctx);
                          _confirmRegisterDevice(context, provider, d['name']!, d['id']!, 'Bluetooth');
                        },
                      ),
                    )),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // MOCK: WiFi Pairing SSID form
  void _showWifiPairDialog(BuildContext context, DryerProvider provider, bool isDark) {
    final formKey = GlobalKey<FormState>();
    String ssid = '';
    String name = 'Smart Dryer Theta';
    String id = 'DRY-THTA-07';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('WiFi Pairing'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dryer Name'),
                initialValue: name,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'SSID Name'),
                validator: (v) => v!.isEmpty ? 'SSID required' : null,
                onSaved: (v) => ssid = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'WiFi Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.pop(ctx);
                _confirmRegisterDevice(context, provider, name, id, 'WiFi');
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  // MOCK: Manual device serial login form
  void _showManualPairDialog(BuildContext context, DryerProvider provider, bool isDark) {
    final formKey = GlobalKey<FormState>();
    String name = 'Smart Dryer Iota';
    String id = '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual Pairing'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dryer Name'),
                initialValue: name,
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Device ID', hintText: 'e.g. DRY-IOTA-08'),
                validator: (v) => v!.isEmpty ? 'Device ID required' : null,
                onSaved: (v) => id = v!.trim().toUpperCase(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.pop(ctx);
                _confirmRegisterDevice(context, provider, name, id, 'Serial Key');
              }
            },
            child: const Text('Pair'),
          ),
        ],
      ),
    );
  }

  // Confirmation Dialogue: "Register device?" and "Ready"
  void _confirmRegisterDevice(
    BuildContext context, 
    DryerProvider provider,
    String name, 
    String id, 
    String method
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register device?'),
        content: Text('Would you like to pair and register "$name" ($id)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.connectNewDevice(name: name, id: id, method: method);
              if (success) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.normal),
                          SizedBox(width: 8),
                          Text('Ready'),
                        ],
                      ),
                      content: Text('"$name" has been paired and registered successfully.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
