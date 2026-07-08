import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../state/library_provider.dart';
import '../../state/dryer_provider.dart';
import '../../../data/models/drying_profile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Returns matching crop emoji for visualization
  String _getCropEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('mango')) return '🥭';
    if (lower.contains('rose') || lower.contains('petal')) return '🌹';
    if (lower.contains('leaf') || lower.contains('leaves')) return '🍃';
    if (lower.contains('herb')) return '🌿';
    if (lower.contains('vegetable')) return '🥦';
    return '🌾'; // Default crop emoji
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LibraryProvider>(context);
    final role = Provider.of<DryerProvider>(context, listen: false).currentUserRole;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Library',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.primaryLight : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          indicatorColor: isDark ? AppColors.primaryLight : AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Default Library'),
            Tab(text: 'My Library'),
          ],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLibraryTabContent(provider, provider.defaultProfiles, isDark, false, role),
                _buildLibraryTabContent(provider, provider.customProfiles, isDark, true, role),
              ],
            ),
    );
  }

  Widget _buildLibraryTabContent(
    LibraryProvider provider, 
    List<DryingProfile> profiles, 
    bool isDark, 
    bool isCustomList,
    String role,
  ) {
    return Column(
      children: [
        Expanded(
          child: profiles.isEmpty
              ? _buildEmptyState(isDark, isCustomList)
              : ListView.builder(
                  itemCount: profiles.length,
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return _buildRecipeCard(context, profile, provider, isDark);
                  },
                ),
        ),
        if (isCustomList && role != 'Viewer')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showAddProfileDialog(context, provider, isDark),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Product'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, DryingProfile profile, LibraryProvider provider, bool isDark) {
    final borderCol = isDark ? AppColors.borderDark : AppColors.borderLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final String emoji = _getCropEmoji(profile.name);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
        title: Text(
          profile.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${profile.tempRangeMin.toStringAsFixed(0)}–${profile.tempRangeMax.toStringAsFixed(0)}°C  |  ${profile.humidityRangeMin.toStringAsFixed(0)}–${profile.humidityRangeMax.toStringAsFixed(0)}%  |  ${profile.expectedDryingTimeHours.toStringAsFixed(0)}–${(profile.expectedDryingTimeHours + 2).toStringAsFixed(0)} Hours',
            style: TextStyle(
              fontSize: 12, 
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: profile.isCustom 
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.critical),
                onPressed: () => _confirmDeleteProfile(context, profile, provider),
              )
            : const Icon(Icons.chevron_right, size: 18),
        onTap: () => _showProfileDetailDialog(context, profile, isDark),
      ),
    );
  }

  void _showProfileDetailDialog(BuildContext context, DryingProfile profile, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(profile.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Temperature range', '${profile.tempRangeMin.toStringAsFixed(0)}°C to ${profile.tempRangeMax.toStringAsFixed(0)}°C', Icons.thermostat),
            _buildDetailRow('Humidity range', '${profile.humidityRangeMin.toStringAsFixed(0)}% to ${profile.humidityRangeMax.toStringAsFixed(0)}%', Icons.water_drop),
            _buildDetailRow('Air Flow level', 'Optimal range: ${profile.airFlowRangeMin.toStringAsFixed(1)} to ${profile.airFlowRangeMax.toStringAsFixed(1)} m/s', Icons.air),
            _buildDetailRow('Drying Time expected', '${profile.expectedDryingTimeHours.toStringAsFixed(0)} to ${(profile.expectedDryingTimeHours + 2).toStringAsFixed(0)} Hours', Icons.schedule),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  void _confirmDeleteProfile(BuildContext context, DryingProfile profile, LibraryProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe?'),
        content: Text('Are you sure you want to permanently delete "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteProfile(profile.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recipe "${profile.name}" deleted.')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.critical),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Dialog showing add custom profile form
  void _showAddProfileDialog(BuildContext context, LibraryProvider provider, bool isDark) {
    final formKey = GlobalKey<FormState>();
    
    String name = '';
    double tempMin = 55.0;
    double tempMax = 60.0;
    double humidityMin = 15.0;
    double humidityMax = 20.0;
    double airflowMin = 1.5;
    double airflowMax = 2.0;
    double expectedHours = 8.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Custom Product',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Recipe Name
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Product Designation',
                          hintText: 'e.g. Cardamom Slices',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a recipe name';
                          }
                          return null;
                        },
                        onSaved: (val) => name = val!.trim(),
                      ),
                      const SizedBox(height: 16),

                      // Temp range slider
                      Text(
                        'Temperature range: ${tempMin.toStringAsFixed(0)}°C to ${tempMax.toStringAsFixed(0)}°C',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      RangeSlider(
                        values: RangeValues(tempMin, tempMax),
                        min: 30.0,
                        max: 90.0,
                        divisions: 60,
                        activeColor: AppColors.primary,
                        labels: RangeLabels('${tempMin.round()}°C', '${tempMax.round()}°C'),
                        onChanged: (values) {
                          setState(() {
                            tempMin = values.start;
                            tempMax = values.end;
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // Humidity bounds
                      Text(
                        'Humidity limit range: ${humidityMin.toStringAsFixed(0)}% to ${humidityMax.toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      RangeSlider(
                        values: RangeValues(humidityMin, humidityMax),
                        min: 2.0,
                        max: 40.0,
                        divisions: 38,
                        activeColor: AppColors.primary,
                        labels: RangeLabels('${humidityMin.round()}%', '${humidityMax.round()}%'),
                        onChanged: (values) {
                          setState(() {
                            humidityMin = values.start;
                            humidityMax = values.end;
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      // Airflow speed
                      Text(
                        'Airflow Velocity Range: ${airflowMin.toStringAsFixed(1)} to ${airflowMax.toStringAsFixed(1)} m/s',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      RangeSlider(
                        values: RangeValues(airflowMin, airflowMax),
                        min: 0.5,
                        max: 4.0,
                        divisions: 35,
                        activeColor: AppColors.primary,
                        labels: RangeLabels('${airflowMin.toStringAsFixed(1)} m/s', '${airflowMax.toStringAsFixed(1)} m/s'),
                        onChanged: (values) {
                          setState(() {
                            airflowMin = values.start;
                            airflowMax = values.end;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Duration input
                      Text(
                        'Expected Drying Duration: ${expectedHours.toStringAsFixed(0)} to ${(expectedHours + 2).toStringAsFixed(0)} Hours',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Slider(
                        value: expectedHours,
                        min: 1.0,
                        max: 36.0,
                        divisions: 35,
                        activeColor: AppColors.primary,
                        label: '${expectedHours.toStringAsFixed(0)}h',
                        onChanged: (val) {
                          setState(() {
                            expectedHours = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            Navigator.pop(ctx);
                            _confirmSaveProfile(context, provider, name, tempMin, tempMax, humidityMin, humidityMax, airflowMin, airflowMax, expectedHours);
                          }
                        },
                        child: const Text('SAVE PRODUCT'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmSaveProfile(
    BuildContext context, 
    LibraryProvider provider,
    String name, 
    double tMin, 
    double tMax, 
    double hMin, 
    double hMax, 
    double aMin, 
    double aMax, 
    double hrs
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save this drying profile?'),
        content: Text('Are you sure you want to register "$name" to your library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.addCustomProfile(
                name: name,
                tempMin: tMin,
                tempMax: tMax,
                humidityMin: hMin,
                humidityMax: hMax,
                airflowMin: aMin,
                airflowMax: aMax,
                expectedHours: hrs,
              );
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recipe "$name" saved successfully.')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isCustomList) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Recipes Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
