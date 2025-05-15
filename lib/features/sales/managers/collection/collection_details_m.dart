import 'package:flutter/material.dart';
import 'package:impal_desktop/features/sales/managers/collection/model/collection_details_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:impal_desktop/features/global/theme/widgets/search.dart';
import 'package:impal_desktop/features/sales/managers/collection/controllers/collection_details_controller.dart';

class CollectionDetailsPage extends StatefulWidget {
  static const String routeName = '/collection';

  const CollectionDetailsPage({super.key});

  @override
  _CollectionDetailsPageState createState() => _CollectionDetailsPageState();
}

class _CollectionDetailsPageState extends State<CollectionDetailsPage> {
  final CollectiondetailsManagerController coldetman =
      Get.put(CollectiondetailsManagerController());
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    coldetman.fetchCollectionDetialsManagerData();
  }

  List<CollectionDetailsManager> _filterData() {
    if (searchQuery.isEmpty) {
      return coldetman.collectionDetails;
    } else {
      return coldetman.collectionDetails.where((detail) {
        return detail.salesRepName!
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text('Collection Details',
            style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ), ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161717),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GlobalSearchField(
              hintText: 'Search Sales Executive...'.tr,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Obx(() {
                if (coldetman.isLoading.value) {
                  return _buildShimmerTable();
                } else {
                  return _filterData().isEmpty
                      ? _buildNoResults()
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.all(Colors.blueAccent),
                              columns:  [
                                DataColumn(
                                    label: Text('S.No',
                                        style:theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),)),
                                DataColumn(
                                    label: Text('Sales Executive Name',
                                        style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),)),
                                DataColumn(
                                    label: Text('Total Outstanding',
                                        style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),)),
                                DataColumn(
                                    label: Text('Day Collection',
                                        style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),)),
                                DataColumn(
                                    label: Text('Cumulative Collections',
                                        style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),)),
                                DataColumn(
                                    label: Text('Balance To Do',
                                        style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),)),
                                DataColumn(
                                    label: Text('Actual Sales',
                                        style: theme.textTheme.bodyLarge?.copyWith(      
                  color: Colors.white,
                ),)),
                              ],
                              rows: List.generate(
                                _filterData().length,
                                (index) {
                                  final data = _filterData()[index];
                                  return DataRow(cells: [
                                    DataCell(Text('${index + 1}')),
                                    DataCell(Text(data.salesRepName!)),
                                    DataCell(Text(data.TotalOutstading!
                                        .toStringAsFixed(2))),
                                    DataCell(Text(data.DayCollection!
                                        .toStringAsFixed(2))),
                                    DataCell(Text(data.cumulativeSales!
                                        .toStringAsFixed(2))),
                                    DataCell(Text(
                                        data.balanceToDo!.toStringAsFixed(2))),
                                    DataCell(Text(
                                        data.AchSales!.toStringAsFixed(2))),
                                  ]);
                                },
                              ),
                            ),
                          ),
                        );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTable() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[700]!,
            highlightColor: Colors.white,
            child: Container(height: 20, color: Colors.grey[700]!),
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[700]!,
            highlightColor: Colors.white,
            child: const Icon(Icons.search_off, size: 100, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: Colors.grey[700]!,
            highlightColor: Colors.white,
            child:  Text('No results found.',
                style: theme.textTheme.bodyLarge?.copyWith(      
                fontSize: 20
                ),),
          ),
        ],
      ),
    );
  }
}
