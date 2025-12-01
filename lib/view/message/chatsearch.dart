import 'package:flutter/material.dart';

class ChatSearchWidget extends StatefulWidget {
  final String selectedTab;
  final Function(String) onTabChanged;
  final Function(String) onSearchChanged;

  const ChatSearchWidget({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onSearchChanged,
  });

  @override
  State<ChatSearchWidget> createState() => _ChatSearchWidgetState();
}

class _ChatSearchWidgetState extends State<ChatSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearchChanged(_searchController.text.toLowerCase().trim());
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        widget.onSearchChanged(''); // Clear search
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          if (_isSearching)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: _getSearchHint(),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: _toggleSearch,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          
          // Tab Row with Search Button
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildTab('All', 'all'),
                    _buildTab('Direct', 'direct'),
                    _buildTab('Groups', 'groups'),
                  ],
                ),
              ),
              if (!_isSearching)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _toggleSearch,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSearchHint() {
    switch (widget.selectedTab) {
      case 'groups':
        return 'Search groups...';
      case 'direct':
        return 'Search contacts...';
      default:
        return 'Search chats...';
    }
  }

  Widget _buildTab(String title, String value) {
    final bool isSelected = widget.selectedTab == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onTabChanged(value);
          if (_isSearching) {
            _searchController.clear();
            widget.onSearchChanged(''); // Clear search when switching tabs
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
