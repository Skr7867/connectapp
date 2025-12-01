import 'package:connectapp/models/UserProfile/user_profile_model.dart';
import 'package:flutter/material.dart';

enum StickerCategory {
  animals,
  vehicle,
  emojis,
  clothes,
  objects,
  nature,
  food,
}

class StickerSelectorWidget extends StatefulWidget {
  final Function(String stickerUrl) onStickerSelected;
  final UserProfileModel? userProfile; // Made optional
  final String? currentUserId;
  final String? currentUserName;

  const StickerSelectorWidget({
    super.key,
    required this.onStickerSelected,
    this.userProfile, // Made optional
    this.currentUserId,
    this.currentUserName,
  });

  @override
  State<StickerSelectorWidget> createState() => _StickerSelectorWidgetState();
}

class _StickerSelectorWidgetState extends State<StickerSelectorWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Your sticker categories data
  final Map<StickerCategory, List<String>> stickerCategories = {
    StickerCategory.animals: [
      "https://cdn-icons-png.flaticon.com/128/1998/1998610.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998620.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998630.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998716.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998740.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998745.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998769.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998795.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998811.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998812.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998813.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998617.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998622.png",
      "https://cdn-icons-png.flaticon.com/512/616/616408.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998767.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998765.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998763.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998761.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998759.png",
      "https://cdn-icons-png.flaticon.com/128/1998/1998755.png"
    ],
    StickerCategory.vehicle: [
      "https://cdn-icons-png.flaticon.com/128/741/741407.png",
      "https://cdn-icons-png.flaticon.com/128/741/741409.png",
      "https://cdn-icons-png.flaticon.com/128/741/741410.png",
      "https://cdn-icons-png.flaticon.com/128/741/741411.png",
      "https://cdn-icons-png.flaticon.com/128/741/741412.png",
      "https://cdn-icons-png.flaticon.com/128/741/741413.png",
      "https://cdn-icons-png.flaticon.com/128/741/741414.png",
      "https://cdn-icons-png.flaticon.com/128/741/741415.png",
      "https://cdn-icons-png.flaticon.com/128/741/741416.png",
      "https://cdn-icons-png.flaticon.com/128/741/741417.png",
      "https://cdn-icons-png.flaticon.com/128/741/741418.png",
      "https://cdn-icons-png.flaticon.com/128/741/741420.png",
      "https://cdn-icons-png.flaticon.com/128/741/741421.png",
      "https://cdn-icons-png.flaticon.com/128/741/741422.png",
      "https://cdn-icons-png.flaticon.com/128/741/741423.png",
      "https://cdn-icons-png.flaticon.com/128/741/741424.png",
      "https://cdn-icons-png.flaticon.com/128/741/741425.png",
      "https://cdn-icons-png.flaticon.com/128/741/741426.png",
      "https://cdn-icons-png.flaticon.com/128/741/741427.png",
      "https://cdn-icons-png.flaticon.com/128/741/741428.png"
    ],
    StickerCategory.emojis: [
      "https://cdn-icons-png.flaticon.com/128/742/742751.png",
      "https://cdn-icons-png.flaticon.com/128/742/742752.png",
      "https://cdn-icons-png.flaticon.com/128/742/742920.png",
      "https://cdn-icons-png.flaticon.com/128/742/742764.png",
      "https://cdn-icons-png.flaticon.com/128/742/742926.png",
      "https://cdn-icons-png.flaticon.com/128/742/742757.png",
      "https://cdn-icons-png.flaticon.com/128/742/742766.png",
      "https://cdn-icons-png.flaticon.com/128/742/742919.png",
      "https://cdn-icons-png.flaticon.com/128/742/742922.png",
      "https://cdn-icons-png.flaticon.com/128/742/742929.png",
      "https://cdn-icons-png.flaticon.com/128/742/742763.png",
      "https://cdn-icons-png.flaticon.com/128/742/742927.png",
      "https://cdn-icons-png.flaticon.com/128/742/742924.png",
      "https://cdn-icons-png.flaticon.com/128/742/742769.png",
      "https://cdn-icons-png.flaticon.com/128/742/742770.png",
      "https://cdn-icons-png.flaticon.com/128/742/742758.png",
      "https://cdn-icons-png.flaticon.com/128/742/742760.png",
      "https://cdn-icons-png.flaticon.com/128/742/742765.png",
      "https://cdn-icons-png.flaticon.com/128/742/742768.png",
      "https://cdn-icons-png.flaticon.com/128/742/742928.png"
    ],
    StickerCategory.clothes: [
      "https://cdn-icons-png.flaticon.com/128/1112/1112680.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112684.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112691.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112697.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112701.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112706.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112710.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112714.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112719.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112723.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112727.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112732.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112736.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112740.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112744.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112748.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112752.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112756.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112760.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112764.png"
    ],
    StickerCategory.objects: [
      "https://cdn-icons-png.flaticon.com/128/1483/1483336.png",
      "https://cdn-icons-png.flaticon.com/128/2989/2989989.png",
      "https://cdn-icons-png.flaticon.com/128/1041/1041916.png",
      "https://cdn-icons-png.flaticon.com/128/616/616408.png",
      "https://cdn-icons-png.flaticon.com/128/861/861060.png",
      "https://cdn-icons-png.flaticon.com/128/744/744465.png",
      "https://cdn-icons-png.flaticon.com/128/3063/3063825.png",
      "https://cdn-icons-png.flaticon.com/128/953/953810.png",
      "https://cdn-icons-png.flaticon.com/128/2702/2702602.png",
      "https://cdn-icons-png.flaticon.com/128/3082/3082035.png",
      "https://cdn-icons-png.flaticon.com/128/3595/3595455.png",
      "https://cdn-icons-png.flaticon.com/128/690/690787.png",
      "https://cdn-icons-png.flaticon.com/128/184/184562.png",
      "https://cdn-icons-png.flaticon.com/128/2659/2659360.png",
      "https://cdn-icons-png.flaticon.com/128/2863/2863190.png",
      "https://cdn-icons-png.flaticon.com/128/628/628283.png",
      "https://cdn-icons-png.flaticon.com/128/181/181549.png",
      "https://cdn-icons-png.flaticon.com/128/3064/3064197.png",
      "https://cdn-icons-png.flaticon.com/128/808/808424.png",
      "https://cdn-icons-png.flaticon.com/128/254/254638.png"
    ],
    StickerCategory.nature: [
      "https://cdn-icons-png.flaticon.com/128/427/427735.png",
      "https://cdn-icons-png.flaticon.com/128/616/616630.png",
      "https://cdn-icons-png.flaticon.com/128/728/728093.png",
      "https://cdn-icons-png.flaticon.com/128/414/414974.png",
      "https://cdn-icons-png.flaticon.com/128/1112/1112672.png",
      "https://cdn-icons-png.flaticon.com/128/861/861059.png",
      "https://cdn-icons-png.flaticon.com/128/4005/4005750.png",
      "https://cdn-icons-png.flaticon.com/128/4151/4151074.png",
      "https://cdn-icons-png.flaticon.com/128/1684/1684375.png",
      "https://cdn-icons-png.flaticon.com/128/869/869869.png",
      "https://cdn-icons-png.flaticon.com/128/2726/2726995.png",
      "https://cdn-icons-png.flaticon.com/128/3157/3157594.png",
      "https://cdn-icons-png.flaticon.com/128/2514/2514476.png",
      "https://cdn-icons-png.flaticon.com/128/4150/4150897.png",
      "https://cdn-icons-png.flaticon.com/128/4286/4286820.png",
      "https://cdn-icons-png.flaticon.com/128/1792/1792959.png",
      "https://cdn-icons-png.flaticon.com/128/2947/2947998.png",
      "https://cdn-icons-png.flaticon.com/128/2894/2894790.png",
      "https://cdn-icons-png.flaticon.com/128/2563/2563992.png",
      "https://cdn-icons-png.flaticon.com/128/4241/4241664.png"
    ],
    StickerCategory.food: [
      "https://cdn-icons-png.flaticon.com/128/1046/1046784.png",
      "https://cdn-icons-png.flaticon.com/128/135/135620.png",
      "https://cdn-icons-png.flaticon.com/128/135/135761.png",
      "https://cdn-icons-png.flaticon.com/128/590/590685.png",
      "https://cdn-icons-png.flaticon.com/128/1046/1046753.png",
      "https://cdn-icons-png.flaticon.com/128/590/590682.png",
      "https://cdn-icons-png.flaticon.com/128/3075/3075977.png",
      "https://cdn-icons-png.flaticon.com/128/1404/1404945.png",
      "https://cdn-icons-png.flaticon.com/128/1046/1046792.png",
      "https://cdn-icons-png.flaticon.com/128/877/877951.png",
      "https://cdn-icons-png.flaticon.com/128/883/883407.png",
      "https://cdn-icons-png.flaticon.com/128/883/883408.png",
      "https://cdn-icons-png.flaticon.com/128/883/883399.png",
      "https://cdn-icons-png.flaticon.com/128/135/135687.png",
      "https://cdn-icons-png.flaticon.com/128/135/135661.png",
      "https://cdn-icons-png.flaticon.com/128/590/590667.png",
      "https://cdn-icons-png.flaticon.com/128/590/590668.png",
      "https://cdn-icons-png.flaticon.com/128/135/135655.png",
      "https://cdn-icons-png.flaticon.com/128/1404/1404941.png",
      "https://cdn-icons-png.flaticon.com/128/135/135699.png"
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _getAvailableCategories().length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get available categories based on subscription
  List<StickerCategory> _getAvailableCategories() {
    // If userProfile is null, provide default access (first 2 categories for free users)
    final stickerPack =
        widget.userProfile?.subscriptionFeatures?.stickerPack ?? 2;
    final categories = StickerCategory.values;

    // Return categories based on subscription level
    if (stickerPack >= categories.length) {
      return categories; // All categories available
    } else {
      return categories.take(stickerPack).toList();
    }
  }

  // Check if category is locked
  bool _isCategoryLocked(StickerCategory category) {
    final availableCategories = _getAvailableCategories();
    return !availableCategories.contains(category);
  }

  String _getCategoryName(StickerCategory category) {
    switch (category) {
      case StickerCategory.animals:
        return 'Animals';
      case StickerCategory.vehicle:
        return 'Vehicle';
      case StickerCategory.emojis:
        return 'Emojis';
      case StickerCategory.clothes:
        return 'Clothes';
      case StickerCategory.objects:
        return 'Objects';
      case StickerCategory.nature:
        return 'Nature';
      case StickerCategory.food:
        return 'Food';
    }
  }

  IconData _getCategoryIcon(StickerCategory category) {
    switch (category) {
      case StickerCategory.animals:
        return Icons.pets;
      case StickerCategory.vehicle:
        return Icons.directions_car;
      case StickerCategory.emojis:
        return Icons.emoji_emotions;
      case StickerCategory.clothes:
        return Icons.checkroom;
      case StickerCategory.objects:
        return Icons.category;
      case StickerCategory.nature:
        return Icons.nature;
      case StickerCategory.food:
        return Icons.restaurant;
    }
  }

  Widget _buildStickerGrid(StickerCategory category) {
    final stickers = stickerCategories[category] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: stickers.length,
        itemBuilder: (context, index) {
          final stickerUrl = stickers[index];
          return GestureDetector(
            onTap: () => widget.onStickerSelected(stickerUrl),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[700]!,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.network(
                stickerUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    color: Colors.grey,
                    size: 32,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLockedView(StickerCategory category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '${_getCategoryName(category)} Stickers',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upgrade your subscription to unlock this sticker pack',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle upgrade subscription
              Navigator.pop(context);
              // Navigate to subscription page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Loading Profile...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait while we load your sticker packs',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading view if profile is not available
    if (widget.userProfile == null) {
      return Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2D3A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select a Sticker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildProfileLoadingView()),
          ],
        ),
      );
    }

    final availableCategories = _getAvailableCategories();

    return Container(
      height: 500,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select a Sticker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          // Tab Bar
          SizedBox(
            height: 50,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.blue,
              dividerColor: Colors.transparent,
              tabs: availableCategories.map((category) {
                return Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 16,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCategoryName(category),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Show locked categories info
          if (availableCategories.length < StickerCategory.values.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${StickerCategory.values.length - availableCategories.length} more sticker packs available with premium subscription',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: availableCategories.map((category) {
                return _buildStickerGrid(category);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
