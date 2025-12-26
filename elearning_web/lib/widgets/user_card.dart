import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({super.key, required this.user, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple.shade50,
              child: Text(
                (user.firstName.isNotEmpty ? user.firstName[0] : '') + (user.lastName.isNotEmpty ? user.lastName[0] : ''),
                style: TextStyle(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Iconsax.sms, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(
                       color: user.role == 'ADMIN' ? Colors.red.shade50 : Colors.blue.shade50,
                       borderRadius: BorderRadius.circular(6),
                     ),
                     child: Text(
                       user.role,
                       style: TextStyle(
                         fontSize: 10,
                         fontWeight: FontWeight.w600,
                         color: user.role == 'ADMIN' ? Colors.red.shade700 : Colors.blue.shade700,
                       ),
                     ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Iconsax.edit, size: 20),
                  onPressed: onEdit,
                  color: Colors.grey.shade600,
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: const Icon(Iconsax.trash, size: 20),
                  onPressed: onDelete,
                  color: Colors.red.shade400,
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
