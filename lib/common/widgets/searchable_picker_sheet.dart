import 'package:flutter/material.dart';

/// A generic item for [SearchablePickerSheet].
class PickerItem {
  final int id;
  final String name;

  const PickerItem({required this.id, required this.name});
}

/// Shows a draggable, searchable bottom-sheet picker.
///
/// The currently selected item (matched by [selectedId]) displays a tick icon.
///
/// ```dart
/// showSearchablePickerSheet(
///   context: context,
///   title: 'Chọn Tỉnh / Thành phố',
///   items: provinces.map((p) => PickerItem(id: p.code, name: p.name)).toList(),
///   selectedId: _selectedProvince?.code,
///   onSelected: (item) => setState(() => _selectedProvince = item),
/// );
/// ```
Future<void> showSearchablePickerSheet({
  required BuildContext context,
  required String title,
  required List<PickerItem> items,
  required ValueChanged<PickerItem> onSelected,
  int? selectedId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SearchablePickerSheet(
      title: title,
      items: items,
      selectedId: selectedId,
      onSelected: onSelected,
    ),
  );
}

/// The bottom-sheet widget itself. Can also be instantiated directly if needed.
class SearchablePickerSheet extends StatefulWidget {
  final String title;
  final List<PickerItem> items;
  final int? selectedId;
  final ValueChanged<PickerItem> onSelected;

  const SearchablePickerSheet({
    Key? key,
    required this.title,
    required this.items,
    required this.onSelected,
    this.selectedId,
  }) : super(key: key);

  @override
  State<SearchablePickerSheet> createState() => _SearchablePickerSheetState();
}

class _SearchablePickerSheetState extends State<SearchablePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<PickerItem> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.items
          : widget.items
              .where((item) => item.name.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Handle bar ─────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Title ──────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ── Search field ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _searchController.clear,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black38),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black38),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black87),
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // ── List ───────────────────────────────────────────────────
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Không tìm thấy kết quả',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16),
                        itemBuilder: (_, i) {
                          final item = _filtered[i];
                          final isSelected = item.id == widget.selectedId;
                          return ListTile(
                            title: Text(
                              item.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : null,
                            onTap: () {
                              widget.onSelected(item);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
