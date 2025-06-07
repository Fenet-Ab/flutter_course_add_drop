import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:course_add_and_drop/components/add_drop_component.dart';
import 'package:flutter/foundation.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final termsList = [
      "1. Acceptance of Terms:\nBy using this app, you agree to these terms. If not, please do not use the app.",
      "2. Eligibility:\nYou must be a registered student or authorized admin.",
      "3. User Roles and Responsibilities:\nStudents can enroll/drop courses. Admins can manage course listings.",
      "4. Authentication and Security:\nUse your credentials responsibly. Report unauthorized access immediately.",
      "5. Authorization and Access:\nFeatures are role-based. Misuse may result in suspension.",
      "6. Data Accuracy:\nEnsure all provided information is correct.",
      "7. Course Enrollment Policies:\nFollow institutional policies for adding/dropping courses.",
      "8. Changes to Courses:\nAdmins may change course details. Check regularly.",
      "9. Account Suspension and Termination:\nMisuse may lead to account action.",
      "10. Privacy and Data Use:\nYour data is used only for managing course enrollments securely.",
      "11. Limitation of Liability:\nThe app is provided 'as is' without warranties.",
      "12. Modifications to Terms:\nWe may update terms. Continued use means you accept the updates.",
      "13. Support and Contact:\nReach your institution's IT support for help."
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  debugPrint('Navigating to /signup');
                  context.go('/signup');
                },
              ),
              const HeadingTextComponent(value: 'Terms and Conditions'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: termsList
                        .map((term) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                term,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}