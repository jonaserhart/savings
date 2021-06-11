
import 'classes/Saving.dart';

abstract class StorageProvider {
  Future<void> updateTotal(double value);
  Future<double> getTotal();
  Future<void> setCurrency(String currency);
  Future<String> getCurrency();
  Future<void> addSaving(Saving saving);
  Future<Iterable<Saving>> getSavings();
  Future<Iterable<Saving>> getLastWeeksSavings();
  Future<Iterable<Saving>> getLast(int number);
  Future<void> setDisplayName(String name);
  Future<String> getDisplayName();
  Future<void> initialize();
  Future<void> removeSaving(Saving saving);
}