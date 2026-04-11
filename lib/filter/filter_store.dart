import 'package:flutter/material.dart';
import 'package:open_mask/data/model/scale.dart';
import 'package:open_mask/data/services/auth_service.dart';
import 'package:open_mask/data/services/storage_service.dart';
import 'package:open_mask/filter/filter_factory.dart';
import 'package:open_mask/filter/filter_image.dart';
import 'package:open_mask/filter/filter_type.dart';
import 'package:open_mask/filter/i_filter.dart';
import 'package:open_mask/filter/templates/composite_filter.dart';
import 'package:open_mask/filter/templates/filter.dart';
import 'package:open_mask/filter/templates/hat_filter.dart';
import 'package:open_mask/filter/templates/image_filter.dart';
import 'package:open_mask/filter/templates/left_eye_color_filter.dart';
import 'package:open_mask/filter/templates/left_eye_filter.dart';
import 'package:open_mask/filter/templates/mask_filter.dart' as om_mf;
import 'package:open_mask/filter/templates/mouth_filter.dart';
import 'package:open_mask/filter/templates/mustache_filter.dart';
import 'package:open_mask/filter/templates/right_eye_color_filter.dart';
import 'package:open_mask/filter/templates/right_eye_filter.dart';

/// Datenhalter-Klasse, welche globale Filterdaten speichert.
class FilterStore extends ChangeNotifier {
  /// Privater Konstruktor für das Singleton-Pattern.
  FilterStore._internal();

  /// Singleton-Instanz.
  static final FilterStore instance = FilterStore._internal();

  /// Der aktuell ausgewählte Filter.
  IFilter? _selectedFilter;

  /// Der Filter, der aktuell im Filter-Editor bearbeitet wird.
  IFilter? _currentlyEditedFilter;

  /// Der Filter, welcher aktuell im Editor ausgewählt ist.
  /// Kann sowohl [currentlyEditedFilter] als auch ein Teil eines [CompositeFilter] sein.
  IFilter? _selectedEditedFilter;

  /// Alle lokalen Filter.
  final List<IFilter> _localFilters = [];

  /// Alle geladenen Community-Filter.
  final List<IFilter> _communityFilters = [];

  /// Der aktuell ausgewählte Filter.
  IFilter? get selectedFilter => _selectedFilter;

  /// Der Filter, der aktuell im Filter-Editor bearbeitet wird.
  IFilter? get currentlyEditedFilter => _currentlyEditedFilter;

  /// Der Filter, welcher aktuell im Editor ausgewählt ist.
  /// Kann sowohl [currentlyEditedFilter] als auch ein Teile eines [CompositeFilter] sein.
  IFilter? get selectedEditedFilter => _selectedEditedFilter;

  /// Alle lokalen Filter.
  List<IFilter> get localFilters => List.unmodifiable(_localFilters);

  /// Alle geladenen Community-Filter.
  List<IFilter> get communityFilters => List.unmodifiable(_communityFilters);

  set selectedFilter(final IFilter? newSelectedFilter) {
    if (newSelectedFilter != _selectedFilter) {
      _selectedFilter?.dispose();
      newSelectedFilter?.load(); // neuen Filter asynchron laden
    }
    _selectedFilter = newSelectedFilter;
    notifyListeners();
  }

  set currentlyEditedFilter(final IFilter? newSelectedEditorFilter) {
    if (newSelectedEditorFilter != _currentlyEditedFilter) {
      _currentlyEditedFilter?.dispose();
      newSelectedEditorFilter?.load().then((final value) =>
          notifyListeners()); // Filter für die Bearbeitung asynchron laden
    }
    _currentlyEditedFilter = newSelectedEditorFilter;
    if (newSelectedEditorFilter == null) {
      _selectedEditedFilter = null;
    }
    notifyListeners();
  }

  /// Setzt den Namen des [currentlyEditedFilter] und benachrichtigt Listener.
  void setCurrentlyEditedFilterName(final String name) {
    (_currentlyEditedFilter as Filter).meta.name = name;
    notifyListeners();
  }

  set selectedEditedFilter(final IFilter? selectedEditedFilter) {
    _selectedEditedFilter = selectedEditedFilter;
    notifyListeners();
  }

  /// Evaluiert, welcher Filter im Editor ausgewählt sein soll.
  void _evaluateSelectedEditedFilter() {
    if (currentlyEditedFilter != null) {
      if (currentlyEditedFilter is CompositeFilter &&
          (currentlyEditedFilter as CompositeFilter).filterList.isNotEmpty) {
        _selectedEditedFilter =
            (currentlyEditedFilter as CompositeFilter).filterList.last;
      } else {
        _selectedEditedFilter = currentlyEditedFilter;
      }
    }
  }

  /// Evaluiert, welcher Filter im Editor ausgewählt sein soll und ruft [notifyListeners] auf.
  void evaluateSelectedEditedFilter() {
    _evaluateSelectedEditedFilter();
    notifyListeners();
  }

  /// Fügt den angegebenen [filter] zu den [localFilters] hinzu.
  void addLocalFilter(final IFilter filter) {
    _localFilters.add(filter);
    notifyListeners();
  }

  /// Entfernt den angegebenen [filter] aus den [localFilters], falls dieser vorhanden ist.
  Future<bool> removeLocalFilter(final IFilter filter) async {
    bool success = _localFilters.remove(filter);
    success =
        success && await StorageService.instance.deleteFilter(filter as Filter);
    notifyListeners();
    return success;
  }

  /// Fügt den angegebenen [filter] zu den [communityFilters] hinzu.
  void addCommunityFilter(final IFilter filter) {
    _communityFilters.add(filter);
    notifyListeners();
  }

  /// Entfernt den angegebenen [filter] aus den [communityFilters], falls dieser vorhanden ist.
  Future<bool> removeCommunityFilter(final IFilter filter) async {
    bool success = _communityFilters.remove(filter);
    success =
        success && await StorageService.instance.deleteFilter(filter as Filter);
    notifyListeners();
    return success;
  }

  /// Importiert den [filter] und speichert ihn. Falls dieser vom aktuellen Nutzer erstellt wurde,
  /// wird dieser in den [localFilters] gespeichert. Falls nicht, wird er zu den [communityFilters]
  /// hinzugefügt. Filter mit bereits existierender UUID werden geforkt.
  Future<void> importFilter(final IFilter filter) async {
    final Filter filterToAdd =
        await StorageService.instance.filterExists(filter as Filter)
            ? filter.fork(createdByUser: false)
            : filter;

    if (filter.meta.createdBy?.id == AuthService.instance.user?.id) {
      addLocalFilter(filterToAdd);
    } else {
      addCommunityFilter(filterToAdd);
    }
    await StorageService.instance.saveFilter(filterToAdd);
  }

  /// Liefert alle eigenen [localFilters] zurück.
  List<IFilter> getOwnFilters() {
    return _localFilters
        .where(
            (final IFilter filter) => (filter as Filter).meta.createdBy != null)
        .toList();
  }

  /// Liefert alle vordefinierten Filter aus den [localFilters] zurück.
  List<IFilter> getPredefinedFilters() {
    return _localFilters
        .where(
            (final IFilter filter) => (filter as Filter).meta.createdBy == null)
        .toList();
  }

  set communityFilters(final List<IFilter> filters) {
    _communityFilters
      ..clear()
      ..addAll(filters);
    notifyListeners();
  }

  /// Fügt den angegebenen Filter zu [currentlyEditedFilter] hinzu.
  /// Falls bereits ein Filter existiert, welcher nicht zusammengesetzt ist,
  /// wird der [currentlyEditedFilter] in einen [CompositeFilter] umgewandelt und der [filter] hinzugefügt.
  void addFilterToEdit(final IFilter filter) {
    if (_currentlyEditedFilter == null &&
        (filter is! CompositeFilter || filter.filterList.isEmpty)) {
      currentlyEditedFilter = filter;
    } else if (_currentlyEditedFilter is! CompositeFilter) {
      CompositeFilter composite =
          FilterFactory.create(FilterType.composite, isCreatedByUser: true)
              as CompositeFilter;
      if (_currentlyEditedFilter != null) {
        composite.addFilter(_currentlyEditedFilter!);
      }
      composite.addFilter(filter);
      currentlyEditedFilter = composite;
    } else {
      (_currentlyEditedFilter as CompositeFilter).addFilter(filter);
      filter.load().then((final value) => notifyListeners());
    }
    _evaluateSelectedEditedFilter();
    notifyListeners();
  }

  /// Erstellt einen neuen Filter zur Bearbeitung und fügt ihn zu [currentlyEditedFilter] hinzu.
  void createFilterToEdit(final FilterType type) {
    IFilter filter = FilterFactory.create(type, isCreatedByUser: true);
    addFilterToEdit(filter);
  }

  /// Setzt das Filterbild des aktuell im Editor ausgewählten Filters auf [filterImage]
  /// Liefert true zurück, wenn das Asset erfolgreich gesetzt und geladen wurde.
  void setSelectedEditedFilterImage(final FilterImage? filterImage) {
    if (selectedEditedFilter is! ImageFilter) {
      return;
    }
    final imageFilter = selectedEditedFilter as ImageFilter;
    imageFilter.filterImage.dispose();
    imageFilter.filterImage = filterImage ?? FilterImage(filename: '');
    notifyListeners();
  }

  /// Lädt alle vordefinierten sowie lokal gespeicherten Filter für den aktuellen Benutzer.
  Future<void> initialize() async {
    // TODO: Vordefinierte Filter als Assets speichern
    // Augen:
    LeftEyeFilter leftEye =
        FilterFactory.create(FilterType.leftEye) as LeftEyeFilter;
    leftEye.meta.name = 'Linkes rotes Auge';
    leftEye.meta.iconAsWidget = Image.asset(leftEye.defaultAssetPath);
    RightEyeFilter rightEye =
        FilterFactory.create(FilterType.rightEye) as RightEyeFilter;
    rightEye.meta.name = 'Rechtes rotes Auge';
    rightEye.meta.iconAsWidget = Image.asset(rightEye.defaultAssetPath);
    CompositeFilter eyes =
        FilterFactory.create(FilterType.composite) as CompositeFilter;
    eyes.addFilter(leftEye);
    eyes.addFilter(rightEye);
    eyes.meta.name = 'Rote Augen';
    eyes.meta.description = 'Leuchtende rote Augen';
    eyes.meta.iconAsWidget = Row(children: [
      Image.asset(leftEye.defaultAssetPath),
      Image.asset(rightEye.defaultAssetPath)
    ]);
    addLocalFilter(eyes);

    // Mund
    addLocalFilter(FilterFactory.create(FilterType.mouth));
    MouthFilter creepyMouth = (FilterFactory.create(FilterType.mouth)
        as MouthFilter)
      ..filterImage = FilterImage(
          filename: 'creepy_mouth',
          assetPath: 'assets/images/filter/creepy_mouth.png')
      ..meta.iconAsWidget = Image.asset('assets/images/filter/creepy_mouth.png')
      ..meta.name = 'Unheimliches Lächeln'
      ..config.offset = const Offset(0.0, 4.0)
      ..config.scale = const Scale(2.0, 2.0);
    addLocalFilter(creepyMouth);

    // Mund und Augen
    CompositeFilter creepyFace =
        (FilterFactory.create(FilterType.composite) as CompositeFilter)
          ..meta.name = 'Unheimliches Gesicht'
          ..meta.description =
              'Unheimlicher Zusammengesetzter Filter aus Augen und Mund'
          ..meta.iconAsWidget = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [eyes.meta.iconAsWidget, creepyMouth.meta.iconAsWidget],
          );
    creepyFace.addFilter(creepyMouth);
    creepyFace.addFilter(eyes);
    addLocalFilter(creepyFace);

    selectedFilter = creepyFace;

    // Composite-Filter
    MustacheFilter mustache1 = (FilterFactory.create(FilterType.mustache)
        as MustacheFilter)
      ..meta.description = 'Standardschnurrbart';
    MustacheFilter mustache2 = (FilterFactory.create(FilterType.mustache)
        as MustacheFilter)
      ..config.offset = const Offset(0, -11.5)
      ..config.scale = const Scale(0.5, 0.5)
      ..config.opacity = 0.5
      ..filterImage = FilterImage(
          filename: 'online_mustache',
          imageUrl: 'https://pngimg.com/uploads/moustache/moustache_PNG43.png');
    HatFilter hatFilter = (FilterFactory.create(FilterType.hat) as HatFilter)
      ..meta.name = 'Hut-Filter'
      ..meta.description = 'Filter mit dem Standardhut';
    om_mf.MaskFilter maskFilter = ((FilterFactory.create(FilterType.mask)
      ..config?.opacity = 0.5) as om_mf.MaskFilter);
    maskFilter.meta.name = 'Transparente Maske';
    maskFilter.meta.iconAsWidget =
        Opacity(opacity: 0.5, child: Image.asset(maskFilter.defaultAssetPath));
    CompositeFilter compositeFilter =
        (FilterFactory.create(FilterType.composite) as CompositeFilter)
          ..meta.name = 'Hut-Schnurrbart-Filter'
          ..meta.description = 'Schnurrbart und Hut';
    compositeFilter.addFilter(mustache1);
    compositeFilter.addFilter(mustache2);
    compositeFilter.addFilter(hatFilter);
    compositeFilter.addFilter(maskFilter);

    addLocalFilter(compositeFilter);

    om_mf.MaskFilter mask = (FilterFactory.create(FilterType.mask)
        as om_mf.MaskFilter)
      ..meta.name = 'Standardmaske';
    CompositeFilter hatAndMask =
        (FilterFactory.create(FilterType.composite) as CompositeFilter)
          ..meta.name = 'Hut & Maske'
          ..meta.description = 'Zusammengesetzter Filter mit Hut & Maske';
    hatAndMask.addFilter(mask);
    hatAndMask.addFilter(hatFilter);
    addLocalFilter(hatAndMask);

    // Hüte:
    addLocalFilter(FilterFactory.create(FilterType.hat));
    HatFilter cowboyHat = (FilterFactory.create(FilterType.hat) as HatFilter)
      ..filterImage = FilterImage(
          filename: 'detective_hat',
          assetPath: 'assets/images/filter/detective_hat.png')
      ..meta.name = 'Detektivhut'
      ..meta.description = 'Brauner Detektivhut'
      ..meta.iconAsWidget =
          Image.asset('assets/images/filter/detective_hat.png')
      ..config.scale = const Scale(1.65, 1.65)
      ..config.offset = const Offset(0, -14);
    addLocalFilter(cowboyHat);
    HatFilter brownHat = (FilterFactory.create(FilterType.hat) as HatFilter)
      ..filterImage = FilterImage(
          filename: 'brown_hat',
          assetPath: 'assets/images/filter/brown_hat.png')
      ..meta.name = 'Brauner Hut'
      ..meta.description = 'Brauner Standardhut'
      ..meta.iconAsWidget = Image.asset('assets/images/filter/brown_hat.png')
      ..config.scale = const Scale(1.65, 1.65)
      ..config.offset = const Offset(0, -14);
    addLocalFilter(brownHat);

    // Masken:
    addLocalFilter(FilterFactory.create(FilterType.mask));

    // Farbaugen
    IFilter leftColorEye = (FilterFactory.create(FilterType.leftColorEye)
        as LeftEyeColorFilter)
      ..color = Colors.red;
    IFilter rightColorEye = (FilterFactory.create(FilterType.rightColorEye)
        as RightEyeColorFilter)
      ..color = Colors.red;
    CompositeFilter colorEyes =
        FilterFactory.create(FilterType.composite) as CompositeFilter;
    colorEyes.meta.name = 'Farbaugen';
    Widget eyeIcon = const Icon(
      Icons.remove_red_eye_rounded,
      color: Colors.black,
    );
    colorEyes.meta.iconAsWidget = Row(spacing: 5, children: [eyeIcon, eyeIcon]);
    colorEyes.addFilter(leftColorEye);
    colorEyes.addFilter(rightColorEye);
    addLocalFilter(colorEyes);

    notifyListeners();

    List<IFilter> filters = await StorageService.instance.loadAllFilters();
    _localFilters.addAll(filters.where((final filter) =>
        (filter as Filter).meta.createdBy?.id ==
            AuthService.instance.user?.id ||
        filter.meta.createdBy == null));
    communityFilters = filters
        .where((final filter) =>
            (filter as Filter).meta.createdBy?.id !=
                AuthService.instance.user?.id &&
            filter.meta.createdBy != null)
        .toList();
  }

  /// Setzt den lokalen Filter-Speicher vollständig zurück und löscht alle enthaltenen Filter.
  /// Löscht auch alle geladenen Filterbilder.
  void clear() {
    if (_selectedFilter is ImageFilter) {
      (_selectedEditedFilter as ImageFilter).dispose();
    }
    _selectedFilter = null;
    if (_currentlyEditedFilter is ImageFilter) {
      (_currentlyEditedFilter as ImageFilter).dispose();
    }
    _currentlyEditedFilter = null;
    for (final IFilter filter in [..._localFilters, ..._communityFilters]) {
      if (filter is ImageFilter) {
        filter.dispose();
      }
    }
    _localFilters.clear();
    _communityFilters.clear();
    notifyListeners();
  }
}
