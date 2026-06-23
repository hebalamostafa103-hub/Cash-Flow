import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});



  Widget developerCard(
  String name,
  IconData icon, {
  bool isCenter = false,
}) {
  return SizedBox(
    width: 90,
    height: 150,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: isCenter
              ? const Color(0xFF00C8FF)
              : Colors.white10,
          width: isCenter ? 2 : 1,
        ),

        boxShadow: isCenter
            ? [
                BoxShadow(
                  color: const Color(
                    0xFF00C8FF,
                  ).withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(
                0xFF00C8FF,
              ).withOpacity(.15),
            ),
            child: Icon(
              icon,
              color: const Color(
                0xFF00C8FF,
              ),
              size: 30,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 6),

          if (isCenter)
            const Text(
              "Lead Developer",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00C8FF),
                fontSize: 8,
              ),
            ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        title: const Text(
          "About",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C8FF)
                    .withOpacity(.15),
                border: Border.all(
                  color: const Color(0xFF00C8FF),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 60,
                color: Color(0xFF00C8FF),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Cash Flow",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Smart Business Management System",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Color(0xFF00C8FF),
                fontWeight: FontWeight.bold,
              ),
            ),

            

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text(
                    "About Cash Flow",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Cash Flow is a smart business management application designed to help store owners manage clients, transactions, payments, notifications and AI-powered assistance in one powerful and modern platform.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
  color: Colors.white12,
  height: 40,
),

            const SizedBox(height: 35),

            const Text(
              "Developed By",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
  mainAxisAlignment:
      MainAxisAlignment.center,
  children: [

    developerCard(
      "Jhon",
      Icons.code,
    ),

    const SizedBox(width: 8),

    developerCard(
      "Slovini",
      Icons.workspace_premium,
      isCenter: true,
    ),

    const SizedBox(width: 8),

    developerCard(
      "Loki",
      Icons.bolt,
    ),
  ],
),

            const SizedBox(height: 20),

            const Text(
              "With Dr.Abeer Amer",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}