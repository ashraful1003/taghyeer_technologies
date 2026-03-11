import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../products/presentation/bloc/product_bloc.dart';
import '../../../products/presentation/screen/product_list_screen.dart';
import '../../../posts/presentation/bloc/post_bloc.dart';
import '../../../posts/presentation/screen/post_list_screen.dart';
import '../../../settings/presentation/screen/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  late final ProductBloc _productBloc;
  late final PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _productBloc = sl<ProductBloc>()..add(ProductFetchRequested());
    _postBloc = sl<PostBloc>()..add(PostFetchRequested());
    _screens = [
      BlocProvider.value(
        value: _productBloc,
        child: const ProductListScreen(),
      ),
      BlocProvider.value(
        value: _postBloc,
        child: const PostListScreen(),
      ),
      const SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    _productBloc.close();
    _postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
