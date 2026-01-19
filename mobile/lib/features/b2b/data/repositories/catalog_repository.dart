import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../datasources/catalog_remote_datasource.dart';

class CatalogRepository {
  final CatalogRemoteDatasource _remoteDatasource;

  CatalogRepository(this._remoteDatasource);

  Future<Either<Failure, List<Category>>> getCategories(String wholesalerId) async {
    try {
      final categories = await _remoteDatasource.getCategories(wholesalerId);
      return Right(categories.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Product>>> getProducts(
    String wholesalerId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final products = await _remoteDatasource.getProducts(
        wholesalerId,
        page: page,
        size: size,
      );
      return Right(products.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Product>>> getProductsByCategory(
    String wholesalerId,
    String categoryId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final products = await _remoteDatasource.getProductsByCategory(
        wholesalerId,
        categoryId,
        page: page,
        size: size,
      );
      return Right(products.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Product>>> getFeaturedProducts(String wholesalerId) async {
    try {
      final products = await _remoteDatasource.getFeaturedProducts(wholesalerId);
      return Right(products.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Product>>> searchProducts(
    String wholesalerId,
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final products = await _remoteDatasource.searchProducts(
        wholesalerId,
        query,
        page: page,
        size: size,
      );
      return Right(products.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Product>> getProduct(String productId) async {
    try {
      final product = await _remoteDatasource.getProduct(productId);
      return Right(product.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
