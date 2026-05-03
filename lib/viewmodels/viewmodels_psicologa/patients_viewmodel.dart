import 'package:flutter/material.dart';
import '../../models/model_psicologa/patient_model.dart';
import '../../services/services_psicologa/psychologist_repository.dart';

class PatientsViewModel extends ChangeNotifier {
  final PsychologistRepository _repository;

  PatientsViewModel({PsychologistRepository? repository})
    : _repository = repository ?? PsychologistRepository();

  List<PatientModel> _allPatients = [];
  List<PatientModel> _filteredPatients = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Filtro de estado: 'all', 'completed', 'pending'
  String _statusFilter = 'all';

  // Getters
  List<PatientModel> get patients => _filteredPatients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  Future<void> loadPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allPatients = await _repository.getPatients();
      _applyFilters();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredPatients = _allPatients.where((patient) {
      // Filtro por búsqueda (nombre) - a partir de 2 letras como pediste
      final matchesSearch =
          _searchQuery.length < 2 ||
          patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filtro por estado
      bool matchesStatus = true;
      if (_statusFilter == 'completed') {
        matchesStatus = patient.progress >= 1.0 && patient.totalAssigned > 0;
      } else if (_statusFilter == 'pending') {
        matchesStatus = patient.progress < 1.0;
      }

      return matchesSearch && matchesStatus;
    }).toList();

    notifyListeners();
  }

  // Método para refrescar los datos
  Future<void> refresh() => loadPatients();
}
