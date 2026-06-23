import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState
    extends State<PaymentMethodsScreen> {

  String paymentType = "Bank Card";
  String selectedBank = "CIB";
  String cardType = "Visa";

  final accountController =
      TextEditingController();

  final instaPayController =
      TextEditingController();

  final vodafoneController =
      TextEditingController();

  final banks = [
    "CIB",
    "Banque Misr",
    "NBE",
    "Alex Bank",
    "QNB",
  ];

  final cardTypes = [
    "Visa",
    "MasterCard",
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs =
        await SharedPreferences.getInstance();

    paymentType =
        prefs.getString("payment_type") ??
            "Bank Card";

    selectedBank =
        prefs.getString("bank_name") ??
            "CIB";

    cardType =
        prefs.getString("card_type") ??
            "Visa";

    accountController.text =
        prefs.getString("account_number") ??
            "";

    instaPayController.text =
        prefs.getString("instapay") ?? "";

    vodafoneController.text =
        prefs.getString("vodafone_cash") ??
            "";

    setState(() {});
  }

  Future<void> saveData() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      "payment_type",
      paymentType,
    );

    await prefs.setString(
      "bank_name",
      selectedBank,
    );

    await prefs.setString(
      "card_type",
      cardType,
    );

    await prefs.setString(
      "account_number",
      accountController.text,
    );

    await prefs.setString(
      "instapay",
      instaPayController.text,
    );

    await prefs.setString(
      "vodafone_cash",
      vodafoneController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text("Saved Successfully"),
      ),
    );
  }

  Widget buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.all(18),
          prefixIcon: Icon(
            icon,
            color:
                const Color(0xFF00C8FF),
          ),
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white54,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          "Payment Methods",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              height: 190,
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(
                        24),
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF0A84FF),
                    Color(0xFF00C8FF),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [

                  const Text(
                    "Cash Flow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    paymentType ==
                            "Bank Card"
                        ? (accountController
                                .text
                                .isEmpty
                            ? "**** **** **** 0000"
                            : accountController
                                .text)
                        : paymentType,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2,
                    ),
                  ),

                  Text(
                    paymentType ==
                            "Bank Card"
                        ? cardType
                        : "",
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF151515),
                borderRadius:
                    BorderRadius.circular(
                        18),
              ),
              child:
                  DropdownButtonHideUnderline(
                child:
                    DropdownButton<String>(
                  value: paymentType,
                  dropdownColor:
                      const Color(
                          0xFF151515),
                  isExpanded: true,
                  style:
                      const TextStyle(
                    color: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Bank Card",
                      child: Text(
                          "🏦 Bank Card"),
                    ),
                    DropdownMenuItem(
                      value: "InstaPay",
                      child: Text(
                          "⚡ InstaPay"),
                    ),
                    DropdownMenuItem(
                      value:
                          "Vodafone Cash",
                      child: Text(
                          "📱 Vodafone Cash"),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      paymentType = v!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (paymentType ==
                "Bank Card") ...[

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration:
                    BoxDecoration(
                  color: const Color(
                      0xFF151515),
                  borderRadius:
                      BorderRadius
                          .circular(
                              18),
                ),
                child:
                    DropdownButtonHideUnderline(
                  child:
                      DropdownButton<
                          String>(
                    value: selectedBank,
                    dropdownColor:
                        const Color(
                            0xFF151515),
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                    isExpanded: true,
                    items: banks
                        .map(
                          (e) =>
                              DropdownMenuItem(
                            value: e,
                            child:
                                Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedBank =
                            v!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(
                  height: 15),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration:
                    BoxDecoration(
                  color: const Color(
                      0xFF151515),
                  borderRadius:
                      BorderRadius
                          .circular(
                              18),
                ),
                child:
                    DropdownButtonHideUnderline(
                  child:
                      DropdownButton<
                          String>(
                    value: cardType,
                    dropdownColor:
                        const Color(
                            0xFF151515),
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                    ),
                    isExpanded: true,
                    items: cardTypes
                        .map(
                          (e) =>
                              DropdownMenuItem(
                            value: e,
                            child:
                                Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        cardType =
                            v!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(
                  height: 15),

              buildField(
                label:
                    "Card Number",
                icon: Icons.credit_card,
                controller:
                    accountController,
              ),
            ],

            if (paymentType ==
                "InstaPay")
              buildField(
                label:
                    "InstaPay Address",
                icon:
                    Icons.flash_on,
                controller:
                    instaPayController,
              ),

            if (paymentType ==
                "Vodafone Cash")
              buildField(
                label:
                    "Vodafone Number",
                icon: Icons
                    .phone_android,
                controller:
                    vodafoneController,
              ),

            const SizedBox(
                height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveData,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                          0xFF00C8FF),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color:
                        Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}