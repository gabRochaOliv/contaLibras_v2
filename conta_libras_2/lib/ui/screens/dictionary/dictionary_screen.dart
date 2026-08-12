import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/mock/mock_dictionary_repository.dart';
import '../../../data/models/term_model.dart';
import '../../widgets/term_card.dart';
import 'term_detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  final void Function(TermModel)? onTermSelected;
  final Set<String> recentlyViewedTermIds;
  const DictionaryScreen({
    super.key,
    this.onTermSelected,
    this.recentlyViewedTermIds = const {},
  });

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TermModel> _filteredTerms = MockDictionaryRepository.terms;

  void _onSearchChanged(String query) {
    setState(() {
      _filteredTerms = MockDictionaryRepository.searchTerms(query);
    });
  }

  void _openTerm(BuildContext context, TermModel term) {
    if (widget.onTermSelected != null) {
      widget.onTermSelected!(term);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TermDetailScreen(term: term)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        return Scaffold(
          appBar: isDesktop ? null : AppBar(
            toolbarHeight: 80,
            title: Image.asset('assets/images/logoContaLibras.png', height: 60),
            centerTitle: true,
            elevation: 0,
          ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar termo ou categoria...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _filteredTerms.length,
              itemBuilder: (context, index) {
                final term = _filteredTerms[index];
                return TermCard(
                  term: term,
                  onTap: () => _openTerm(context, term),
                  isRecentlyViewed: widget.recentlyViewedTermIds.contains(term.id),
                );
              },
            ),
          ),
        ],
      ),
    ),
    ),
        );
      },
    );
  }
}
