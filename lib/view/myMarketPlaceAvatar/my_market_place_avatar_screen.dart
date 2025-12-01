import 'package:connectapp/res/assets/image_assets.dart';
import 'package:connectapp/res/custom_widgets/responsive_padding.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/view_models/controller/marketplace/market_place_avatar_controller.dart';
import 'package:connectapp/view_models/controller/purchaseAvatarCollection/purchase_avatar_collection_controller.dart';
import 'package:connectapp/view_models/controller/purchaseAvatarFromMarketPlace/purchase_avatar_from_market_place_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import '../../res/color/app_colors.dart';

class MyMarketPlaceAvatarScreen extends StatelessWidget {
  const MyMarketPlaceAvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final marketPlaceController = Get.put(MarketPlaceAvatarController());
    final purchaseAvatar = Get.put(PurchaseAvatarFromMarketPlaceController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'MarketPlace',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.opensansRegular,
                color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          automaticallyImplyLeading: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                marketPlaceController.fetchMarketPlaceAvatars();
              },
            ),
          ],
          bottom: TabBar(
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            unselectedLabelColor: AppColors.greyColor,
            indicatorColor: AppColors.blackColor,
            labelStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontFamily: AppFonts.opensansRegular,
                fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Custom Avatars'),
              Tab(text: 'Collections'),
            ],
          ),
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              // Search Field
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.greyColor.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        cursorHeight: 25,
                        cursorColor:
                            Theme.of(context).textTheme.bodyLarge?.color,
                        onChanged: (value) {
                          marketPlaceController.filterAvatars(value);
                        },
                        decoration: InputDecoration(
                          hintText:
                              "Search Avatar by avatar name & user name..",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: AppFonts.opensansRegular,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    // Custom Avatars Tab
                    _buildAvatarsGrid(
                        marketPlaceController, purchaseAvatar, context),
                    // Collections Tab
                    _buildCollectionsGrid(marketPlaceController, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarsGrid(
    MarketPlaceAvatarController controller,
    PurchaseAvatarFromMarketPlaceController purchaseAvatar,
    BuildContext context,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      if (controller.avatars.isEmpty) {
        return const Center(
          child: Text("No avatars available"),
        );
      }

      final avatars = controller.avatars;

      return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        padding: const EdgeInsets.all(8),
        itemCount: avatars.length,
        itemBuilder: (context, index) {
          final avatar = avatars[index];
          return _buildAvatarCard(avatar, purchaseAvatar, context);
        },
      );
    });
  }

  Widget _buildCollectionsGrid(
    MarketPlaceAvatarController controller,
    BuildContext context,
  ) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      if (controller.collections.isEmpty) {
        return Center(
          child: Text(
            "No collections available",
            style: TextStyle(
                fontSize: 15,
                fontFamily: AppFonts.opensansRegular,
                color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        );
      }

      final collections = controller.collections;

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return _buildCollectionCard(collection, context);
        },
      );
    });
  }

  Widget _buildAvatarCard(
    avatar,
    PurchaseAvatarFromMarketPlaceController purchaseAvatar,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              avatar.avatar2dUrl ?? "",
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  ImageAssets.profilePic,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: ResponsivePadding.symmetricPadding(context,
                horizontal: 2, vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avatar.name ?? "Unnamed",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
                const SizedBox(height: 2),
                ReadMoreText(
                  avatar.description ?? "",
                  trimLines: 1,
                  colorClickableText: Colors.blue,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Show more',
                  trimExpandedText: 'Show less',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                  moreStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                  lessStyle: const TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        avatar.userId!.fullName ?? "",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                      if (avatar.userId!.subscription!.status == 'Active')
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.yellowColor,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '@${avatar.userId?.username ?? "unknown"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: AppFonts.opensansRegular,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (avatar.userId?.subscriptionFeatures
                                          ?.premiumIconUrl !=
                                      null &&
                                  avatar.userId!.subscriptionFeatures!
                                      .premiumIconUrl!.isNotEmpty)
                                Image.network(
                                  avatar.userId!.subscriptionFeatures!
                                      .premiumIconUrl!,
                                  height: 16,
                                  width: 16,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.star,
                                    color: Colors.grey,
                                    size: 16,
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.greyColor,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '@${avatar.userId?.username}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: AppFonts.opensansRegular,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.textColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      avatar.createdAt != null
                          ? DateFormat('MMM dd, yyyy')
                              .format(DateTime.parse(avatar.createdAt!))
                          : "",
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "${avatar.coins ?? 0}",
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blackColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed:
                            purchaseAvatar.isLoading(avatar.sId.toString())
                                ? null
                                : () {
                                    purchaseAvatar
                                        .buyAvatar(avatar.sId.toString(), {});
                                  },
                        child: purchaseAvatar.isLoading(avatar.sId.toString())
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Buy',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCollectionCard(collection, BuildContext context) {
    final purchaseCollection = Get.put(PurchaseAvatarCollectionController());
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        collection.name ?? "Unnamed Collection",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                    ),
                    if (collection.isPublished ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Published',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (collection.description != null &&
                    collection.description!.isNotEmpty)
                  ReadMoreText(
                    collection.description!,
                    trimLines: 2,
                    colorClickableText: Colors.blue,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Show more',
                    trimExpandedText: 'Show less',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                const SizedBox(height: 12),
                if (collection.creator != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.greyColor.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (collection.creator!.avatar?.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              collection.creator!.avatar!.imageUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 40,
                                height: 40,
                                color: AppColors.greyColor,
                                child: const Icon(Icons.person,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                collection.creator!.fullName ?? "Unknown",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                              ),
                              Text(
                                '@${collection.creator!.username ?? "unknown"}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textColor,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (collection.creator!.subscriptionFeatures
                                    ?.premiumIconUrl !=
                                null &&
                            collection.creator!.subscriptionFeatures!
                                .premiumIconUrl!.isNotEmpty)
                          Image.network(
                            collection
                                .creator!.subscriptionFeatures!.premiumIconUrl!,
                            height: 20,
                            width: 20,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.star,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.image,
                            color: AppColors.textColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${collection.avatars?.length ?? 0} Avatars",
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textColor,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "${collection.coins ?? 0}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Obx(
                          () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blackColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                purchaseCollection.isLoading(collection.sId)
                                    ? null
                                    : () {
                                        purchaseCollection.buyCollection(
                                            collection.sId.toString(), {});
                                      },
                            child: purchaseCollection
                                    .isLoading(collection.sId.toString())
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Buy',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (collection.avatars != null && collection.avatars!.isNotEmpty)
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: collection.avatars!.length,
                itemBuilder: (context, index) {
                  final avatar = collection.avatars![index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        avatar.avatar2dUrl ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          ImageAssets.profilePic,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
