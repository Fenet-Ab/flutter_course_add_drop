import 'package:flutter/material.dart';

class AddCard extends StatelessWidget {
  final VoidCallback onAddClick;
  final String header;
  final String text1;
  final String text2;
  final Widget Function() actions;

  const AddCard({
    Key? key,
    required this.onAddClick,
    required this.header,
    required this.text1,
    required this.text2,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32),
      alignment: Alignment.topCenter,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        text1,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        text2,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ButtonAddAndDrop(
                  value: 'Add now',
                  onClick: onAddClick,
                ),
              ],
            ),
            const SizedBox(height: 8),
            actions(),
          ],
        ),
      ),
    );
  }
}

class DropCard extends StatelessWidget {
  final Widget Function() onClick;
  final String header;
  final String text1;
  final String text2;
  final Widget Function() actions;

  const DropCard({
    Key? key,
    required this.onClick,
    required this.header,
    required this.text1,
    required this.text2,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32),
      alignment: Alignment.topCenter,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        header,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        text1,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        text2,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ButtonAddAndDrop(
                  value: 'Drop now',
                  onClick: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            actions(),
          ],
        ),
      ),
    );
  }
}

class ButtonAddAndDrop extends StatelessWidget {
  final String value;
  final VoidCallback onClick;

  const ButtonAddAndDrop({
    Key? key,
    required this.value,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onClick,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(90, 36),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blue, // Assuming colorPrimary is blue
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.blue, width: 1),
        ),
        padding: EdgeInsets.zero,
        elevation: 0,
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.blue, // Assuming colorPrimary is blue
        ),
      ),
    );
  }
}