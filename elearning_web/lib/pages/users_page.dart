import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:html' as html;
import 'package:iconsax/iconsax.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'edit_user_page.dart';
import '../widgets/user_card.dart';

class UsersPage extends StatefulWidget {
	const UsersPage({super.key});

	@override
	State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
	late Future<UsersPageResult> _usersPageFuture;
	int _page = 0;
	final int _size = 5;

	@override
	void initState() {
		super.initState();
		_usersPageFuture = UserService.getUsers(page: _page, size: _size);
	}

	Future<void> _refresh() async {
		setState(() {
			_usersPageFuture = UserService.getUsers(page: _page, size: _size);
		});
	}

	Future<void> _deleteUser(String id) async {
		final confirmed = await showDialog<bool>(
			context: context,
			builder: (_) => AlertDialog(
				title: const Text('Confirmer la suppression'),
				content: const Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
				actions: [
					TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
					TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
				],
			),
		);

		if (confirmed == true) {
			try {
				await UserService.deleteUser(id);
				ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utilisateur supprimé'), backgroundColor: Colors.green));
				_refresh();
			} catch (e) {
				ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
			}
		}
	}

	Future<void> _editUser(User? user) async {
		await Navigator.push(
			context,
			MaterialPageRoute(builder: (_) => EditUserPage(user: user)),
		);
		_refresh();
	}

	Future<void> _exportCsv() async {
		try {
			final bytes = await UserService.exportCsv();
			final base64Data = convert.base64Encode(bytes);
			final url = 'data:text/csv;charset=utf-8;base64,$base64Data';
			final anchor = html.document.createElement('a') as html.AnchorElement;
			anchor.href = url;
			anchor.download = 'users.csv';
			anchor.style.display = 'none';
			html.document.body?.children.add(anchor);
			anchor.click();
			anchor.remove();
		} catch (e) {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text(
							'Administration',
							style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
						),
						Text(
							'Utilisateurs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
						),
					],
				),
				actions: [
					IconButton(
						icon: const Icon(Iconsax.document_download),
						tooltip: 'Exporter CSV',
						onPressed: _exportCsv,
					),
					IconButton(
						icon: const Icon(Iconsax.user_add),
						tooltip: 'Ajouter un utilisateur',
						onPressed: () => _editUser(null),
					)
				],
			),
			body: Container(
        color: Colors.grey.shade50,
        child: FutureBuilder<UsersPageResult>(
  				future: _usersPageFuture,
  				builder: (context, snapshot) {
  					if (snapshot.connectionState == ConnectionState.waiting) {
  						return const Center(child: CircularProgressIndicator());
  					}
  					if (snapshot.hasError) {
  						return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.warning_2, size: 50, color: Colors.orange.shade300),
                    const SizedBox(height: 16),
                    Text('Erreur: ${snapshot.error}', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              );
  					}
  					final page = snapshot.data!;
  					final users = page.content;
  					if (users.isEmpty) {
  						return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.people, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Aucun utilisateur', style: TextStyle(color: Colors.grey.shade500, fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _editUser(null),
                      icon: const Icon(Iconsax.add),
                      label: const Text('Créer un utilisateur'),
                    )
                  ],
                ),
              );
  					}
  					return Column(
  						children: [
  							Expanded(
  								child: RefreshIndicator(
  									onRefresh: _refresh,
  									child: ListView.separated(
  										padding: const EdgeInsets.all(16),
  										itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
  										itemBuilder: (context, i) => UserCard(
  											user: users[i],
  											onEdit: () => _editUser(users[i]),
  											onDelete: () => _deleteUser(users[i].id ?? ''),
  										),
  									),
  								),
  							),
  							// pagination controls
  							Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page ${page.number + 1} / ${page.totalPages}',
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Iconsax.arrow_left_2),
                            onPressed: page.number > 0 ? () {
                              setState(() { _page = page.number - 1; _usersPageFuture = UserService.getUsers(page: _page, size: _size); });
                            } : null,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Iconsax.arrow_right_3),
                            onPressed: page.number < (page.totalPages - 1) ? () {
                              setState(() { _page = page.number + 1; _usersPageFuture = UserService.getUsers(page: _page, size: _size); });
                            } : null,
                          ),
                        ],
                      ),
                    ],
                  ),
  							)
  						],
  					);
  				},
  			),
      ),
		);
	}
}

