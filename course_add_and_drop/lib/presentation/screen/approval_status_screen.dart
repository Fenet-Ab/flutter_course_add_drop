import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:course_add_and_drop/theme/app_colors.dart';
import 'package:course_add_and_drop/components/text.dart' as text;

class ApprovalStatusScreen extends StatefulWidget {
  const ApprovalStatusScreen({super.key});

  @override
  State<ApprovalStatusScreen> createState() => _ApprovalStatusScreenState();
}

class _ApprovalStatusScreenState extends State<ApprovalStatusScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _addRequests = [];
  List<Map<String, dynamic>> _dropRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredRequests = [];
  String _selectedTab = 'Add Requests';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final addRequests = await _apiService.getAdds();
      final dropRequests = await _apiService.getDropRequests();
      if (!mounted) return;
      setState(() {
        _addRequests = addRequests;
        _dropRequests = dropRequests;
        _filteredRequests = _selectedTab == 'Add Requests' ? _addRequests : _dropRequests;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAddRequestStatus(String requestId, String status) async {
    try {
      await _apiService.updateAddRequest(requestId, status);
      await _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add request ${status} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating add request: $e')),
        );
      }
    }
  }

  Future<void> _updateDropRequestStatus(String requestId, String status) async {
    try {
      await _apiService.updateDropRequest(requestId, status);
      await _loadRequests();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Drop request ${status} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating drop request: $e')),
        );
      }
    }
  }

  void _filterRequests(String query) {
    setState(() {
      final sourceList = _selectedTab == 'Add Requests' ? _addRequests : _dropRequests;
      if (query.isEmpty) {
        _filteredRequests = sourceList;
      } else {
        _filteredRequests = sourceList.where((request) {
          final studentName = request['student_name']?.toString().toLowerCase() ?? '';
          final courseTitle = request['course_title']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return studentName.contains(searchLower) || courseTitle.contains(searchLower);
        }).toList();
      }
    });
  }

  void _showApprovalDialog(String requestId, String type, String action) {
    debugPrint('Attempting to ${action.toLowerCase()} request of type $type with ID: $requestId');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action} ${type} Request'),
        content: Text('Are you sure you want to $action this ${type.toLowerCase()} request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (type == 'Add') {
                _updateAddRequestStatus(requestId, action.toLowerCase() == 'approve' ? 'approved' : 'rejected');
              } else {
                _updateDropRequestStatus(requestId, action.toLowerCase() == 'approve' ? 'approved' : 'rejected');
              }
              Navigator.pop(context);
            },
            child: Text(
              action,
              style: TextStyle(
                color: action.toLowerCase() == 'approve' ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 15.0, left: 16.0, right: 16.0, bottom: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/dashboard/user'),
                    ),
                    const Text(
                      'Approval Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedTab = 'Add Requests';
                            _filteredRequests = _addRequests;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTab == 'Add Requests' ? AppColors.colorPrimary : Colors.grey,
                        ),
                        child: const Text('Add Requests'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedTab = 'Drop Requests';
                            _filteredRequests = _dropRequests;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTab == 'Drop Requests' ? AppColors.colorPrimary : Colors.grey,
                        ),
                        child: const Text('Drop Requests'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search requests...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterRequests,
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          else if (_filteredRequests.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No requests available.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = _filteredRequests[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    text.HeadingTextComponent(
                                      text: request['student_name'] ?? 'Unknown Student',
                                      color: AppColors.colorPrimary,
                                    ),
                                    const SizedBox(height: 4),
                                    text.NormalTextComponent(
                                      text: '${request['course_title'] ?? 'Unknown Course'} (${request['course_code'] ?? 'N/A'})',
                                      color: AppColors.colorPrimary,
                                    ),
                                    const SizedBox(height: 4),
                                    text.NormalTextComponent(
                                      text: 'Credit Hours: ${request['credit_hours'] ?? 'N/A'}',
                                      color: AppColors.colorPrimary,
                                    ),
                                    const SizedBox(height: 4),
                                    text.NormalTextComponent(
                                      text: 'Request ID: ${request['id'] ?? 'N/A'}',
                                      color: AppColors.colorGray,
                                    ),
                                    const SizedBox(height: 4),
                                    text.NormalTextComponent(
                                      text: 'Student ID: ${request['student_id'] ?? 'N/A'}',
                                      color: AppColors.colorGray,
                                    ),
                                    const SizedBox(height: 4),
                                    text.NormalTextComponent(
                                      text: 'Course ID: ${request['course_id'] ?? 'N/A'}',
                                      color: AppColors.colorGray,
                                    ),
                                    const SizedBox(height: 4),
                                    text.NormalTextComponent(
                                      text: 'Requested At: ${request['added_at'] ?? 'N/A'}',
                                      color: AppColors.colorGray,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(request['approval_status']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: text.NormalTextComponent(
                                  text: request['approval_status'] ?? 'Pending',
                                  color: _getStatusColor(request['approval_status']),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (request['approval_status'] == 'pending')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _showApprovalDialog(
                                    request['id'].toString(),
                                    _selectedTab.split(' ')[0],
                                    'Reject',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Reject'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _showApprovalDialog(
                                    request['id'].toString(),
                                    _selectedTab.split(' ')[0],
                                    'Approve',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Approve'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_circle),
            label: 'Drop Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Courses',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard/user');
              break;
            case 1:
              context.go('/add-course');
              break;
            case 2:
              context.go('/drop-course');
              break;
            case 3:
              break;
          }
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 