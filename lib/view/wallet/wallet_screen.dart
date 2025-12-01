import 'package:connectapp/res/custom_widgets/custome_appbar.dart';
import 'package:connectapp/res/fonts/app_fonts.dart';
import 'package:connectapp/res/routes/routes_name.dart';
import 'package:connectapp/view_models/controller/profile/user_profile_controller.dart';

import 'package:connectapp/view_models/controller/transaction/transaction_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/response/status.dart';
import '../../res/color/app_colors.dart';
import '../../view_models/controller/transaction/user_coins_transaction_controller.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userCoins = Get.put(UserProfileController());
    final coinsTransactionController =
        Get.put(UserCoinsTransactionController());
    final stripeTransactionController = Get.put(UserTransactionController());
    final selectedTransactionType = 'All Transactions'.obs;
    void fetchTransactions(String type) {
      if (type == 'All Transactions') {
        coinsTransactionController.userCoinsTransactionApi();
        stripeTransactionController.userTransactionApi();
      } else if (type == 'Coins Transactions') {
        coinsTransactionController.userCoinsTransactionApi();
      } else if (type == 'Stripe Transactions') {
        stripeTransactionController.userTransactionApi();
      }
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Wallet Management',
        automaticallyImplyLeading: true,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.greyColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Coins',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: AppFonts.opensansRegular,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          switch (userCoins.rxRequestStatus.value) {
                            case Status.LOADING:
                              return Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: AppFonts.opensansRegular,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              );
                            case Status.ERROR:
                              return Text(
                                'No Coins',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontFamily: AppFonts.opensansRegular,
                                ),
                              );
                            case Status.COMPLETED:
                              return Text(
                                '${userCoins.userList.value.wallet!.coins.toString()} 🪙',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              );
                          }
                        }),
                      ],
                    ),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: TextButton.icon(
                        onPressed: () {
                          Get.toNamed(RouteName.buyCoinsScreen);
                        },
                        icon: Icon(
                          Icons.add,
                          color: AppColors.whiteColor,
                        ),
                        label: Text(
                          'Add Coins',
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontFamily: AppFonts.opensansRegular,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.opensansRegular,
                    ),
                  ),
                  Obx(() => DropdownButton<String>(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.greenColor,
                        ),
                        dropdownColor: AppColors.textfieldColor,
                        value: selectedTransactionType.value,
                        items: [
                          'All Transactions',
                          'Coins Transactions',
                          'Stripe Transactions',
                        ].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.greenColor,
                                fontFamily: AppFonts.opensansRegular,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            selectedTransactionType.value = newValue;
                            fetchTransactions(newValue);
                          }
                        },
                      )),
                ],
              ),
              Expanded(
                child: Obx(() {
                  // Determine loading state
                  bool isLoading = selectedTransactionType.value ==
                          'All Transactions'
                      ? coinsTransactionController.rxRequestStatus.value ==
                              Status.LOADING ||
                          stripeTransactionController.rxRequestStatus.value ==
                              Status.LOADING
                      : selectedTransactionType.value == 'Coins Transactions'
                          ? coinsTransactionController.rxRequestStatus.value ==
                              Status.LOADING
                          : stripeTransactionController.rxRequestStatus.value ==
                              Status.LOADING;

                  // Determine error state
                  String errorMessage = '';
                  if (selectedTransactionType.value == 'All Transactions') {
                    if (coinsTransactionController.rxRequestStatus.value ==
                        Status.ERROR) {
                      errorMessage = coinsTransactionController.error.value;
                    } else if (stripeTransactionController
                            .rxRequestStatus.value ==
                        Status.ERROR) {
                      errorMessage = stripeTransactionController.error.value;
                    }
                  } else if (selectedTransactionType.value ==
                      'Coins Transactions') {
                    if (coinsTransactionController.rxRequestStatus.value ==
                        Status.ERROR) {
                      errorMessage = coinsTransactionController.error.value;
                    }
                  } else {
                    if (stripeTransactionController.rxRequestStatus.value ==
                        Status.ERROR) {
                      errorMessage = stripeTransactionController.error.value;
                    }
                  }

                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: AppFonts.opensansRegular,
                        ),
                      ),
                    );
                  }

                  // Combine transactions based on selection
                  List<dynamic> transactions = [];
                  if (selectedTransactionType.value == 'All Transactions') {
                    transactions = [
                      ...(coinsTransactionController
                              .usercoinsTransaction.value.transactions ??
                          []),
                      ...(stripeTransactionController
                              .userTransaction.value.transactions ??
                          []),
                    ];

                    transactions.sort((a, b) {
                      final dateA = a.timestamp != null
                          ? DateTime.parse(a.timestamp)
                          : DateTime.parse(a.createdAt ?? '');
                      final dateB = b.timestamp != null
                          ? DateTime.parse(b.timestamp)
                          : DateTime.parse(b.createdAt ?? '');
                      return dateB.compareTo(dateA); // Descending order
                    });
                  } else if (selectedTransactionType.value ==
                      'Coins Transactions') {
                    transactions = coinsTransactionController
                            .usercoinsTransaction.value.transactions ??
                        [];
                  } else {
                    transactions = stripeTransactionController
                            .userTransaction.value.transactions ??
                        [];
                  }

                  if (transactions.isEmpty) {
                    return Center(
                      child: Text(
                        'No transactions available',
                        style: TextStyle(
                          fontFamily: AppFonts.opensansRegular,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final isCoinTransaction = transaction.timestamp != null;

                      final date = isCoinTransaction
                          ? DateTime.parse(transaction.timestamp ?? '')
                          : DateTime.parse(transaction.createdAt ?? '');
                      final formattedDate = DateFormat('d/M/yyyy').format(date);

                      final amount = isCoinTransaction
                          ? (transaction.type == 'CREDIT'
                              ? '+${transaction.amount} 🪙'
                              : '-${transaction.amount} 🪙')
                          : (transaction.type == 'CREDIT'
                              ? '+${transaction.coins} 🪙'
                              : '-${transaction.coins} 🪙');

                      final title = isCoinTransaction
                          ? transaction.description ?? 'Coin Transaction'
                          : transaction.meta?.description ??
                              'Stripe Transaction';

                      final status = isCoinTransaction
                          ? 'completed'
                          : (transaction.status == 'success'
                              ? 'completed'
                              : 'failed');

                      return TransactionItem(
                        title: title,
                        amount: amount,
                        date: formattedDate,
                        status: status,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final String status;

  const TransactionItem({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount.startsWith('+');
    // final isCompleted = status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontFamily: AppFonts.opensansRegular,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: isPositive ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: isCompleted ? Colors.green : Colors.redAccent.shade100,
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Text(
              //     status,
              //     style: TextStyle(
              //       color: isCompleted ? Colors.black : Colors.red,
              //       fontSize: 10,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
