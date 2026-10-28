// lib/state/app_state.dart

import 'package:flutter/widgets.dart';

class AppState extends ChangeNotifier {
  int _stars = 0;
  final Set<String> _ownedOutfitIds = {'default'};
  String _equippedOutfitId = 'default';
  final Set<int> _completedGameIndices = {};

  int get stars => _stars;
  String get equippedOutfitId => _equippedOutfitId;
  int get completedGamesCount => _completedGameIndices.length;

  bool isOwned(String id) => _ownedOutfitIds.contains(id);
  bool isGameCompleted(int index) => _completedGameIndices.contains(index);

  void addStars(int amount) {
    _stars += amount;
    notifyListeners();
  }

  void markGameCompleted(int index) {
    if (_completedGameIndices.add(index)) {
      notifyListeners();
    }
  }

  bool purchase(String id, int price) {
    if (_ownedOutfitIds.contains(id)) return true;
    if (_stars < price) return false;
    _stars -= price;
    _ownedOutfitIds.add(id);
    notifyListeners();
    return true;
  }

  void equip(String id) {
    if (!_ownedOutfitIds.contains(id)) return;
    if (_equippedOutfitId == id) return;
    _equippedOutfitId = id;
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}
