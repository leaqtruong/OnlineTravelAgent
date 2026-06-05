import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';

class ContactSpecialScreen extends ConsumerStatefulWidget {
  const ContactSpecialScreen({super.key});

  @override
  ConsumerState<ContactSpecialScreen> createState() => _ContactSpecialScreenState();
}

class _ContactSpecialScreenState extends ConsumerState<ContactSpecialScreen> {
  final _formKey = GlobalKey<FormState>();

  // State Fields
  String _selectedCategory = 'Đoàn lớn (100+ khách)';
  double _guests = 120;
  double _budget = 8000;

  // Controllers
  final _nameController = TextEditingController();
  final _orgController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Đoàn lớn (100+ khách)', 'icon': Icons.business_outlined},
    {'name': 'Team-building', 'icon': Icons.groups_outlined},
    {'name': 'Nghỉ dưỡng VIP', 'icon': Icons.diamond_outlined},
    {'name': 'Yêu cầu khác', 'icon': Icons.contact_support_outlined},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-fill profile info if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(profileProvider);
      setState(() {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: const Text(
          'Yêu Cầu Đặc Biệt',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textBlack, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderIntro(),
                const SizedBox(height: 20),
                _buildCategorySelector(),
                const SizedBox(height: 20),
                _buildGuestsSlider(),
                const SizedBox(height: 20),
                _buildBudgetSlider(),
                const SizedBox(height: 20),
                _buildContactFormFields(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIntro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: AppTheme.primaryBlue, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đội ngũ chăm sóc VIP',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hãy gửi yêu cầu của bạn, nhân viên CSKH đặc biệt của chúng tôi sẽ gọi điện tư vấn chi tiết trong 2 giờ.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Category Selector ---
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loại hình dịch vụ đặc biệt',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat['name'];
            final icon = cat['icon'] as IconData;
            final name = cat['name'] as String;

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppTheme.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Guest Count Slider ---
  Widget _buildGuestsSlider() {
    final guestLabel = _guests.toInt() == 500 ? '500+ người' : '${_guests.toInt()} người';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Số lượng thành viên',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  guestLabel,
                  style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _guests,
            min: 50,
            max: 500,
            divisions: 45, // increments of 10
            activeColor: AppTheme.primaryBlue,
            inactiveColor: Colors.grey.shade200,
            onChanged: (val) => setState(() => _guests = val),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đoàn từ 50 người', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              Text('Đoàn 500+ người', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // --- Budget Slider ---
  Widget _buildBudgetSlider() {
    final budgetLabel = '\$${_budget.toInt().toString()}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ngân sách dự kiến',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  budgetLabel,
                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _budget,
            min: 1000,
            max: 50000,
            divisions: 49, // increments of $1000
            activeColor: Colors.green.shade600,
            inactiveColor: Colors.grey.shade200,
            onChanged: (val) => setState(() => _budget = val),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$1,000 (Tối thiểu)', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              Text('\$50,000+', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // --- Contact & Form fields ---
  Widget _buildContactFormFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin người liên hệ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
          ),
          const SizedBox(height: 16),
          // Name Field
          _buildTextField(
            controller: _nameController,
            label: 'Họ và tên người liên hệ *',
            icon: Icons.person_outline,
            validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập họ tên' : null,
          ),
          const SizedBox(height: 14),
          // Company Field
          _buildTextField(
            controller: _orgController,
            label: 'Tên công ty / Tổ chức',
            icon: Icons.business,
          ),
          const SizedBox(height: 14),
          // Phone Field
          _buildTextField(
            controller: _phoneController,
            label: 'Số điện thoại liên lạc *',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Vui lòng nhập số điện thoại';
              if (val.length < 8) return 'Số điện thoại không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 14),
          // Email Field
          _buildTextField(
            controller: _emailController,
            label: 'Email nhận phản hồi *',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Vui lòng nhập email';
              if (!val.contains('@')) return 'Email không đúng định dạng';
              return null;
            },
          ),
          const SizedBox(height: 14),
          // Notes Field
          _buildTextField(
            controller: _notesController,
            label: 'Mô tả chi tiết các yêu cầu đặc biệt của bạn...',
            icon: Icons.chat_bubble_outline,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 13, color: AppTheme.textBlack),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }

  // --- Submit action and API simulation ---
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSubmitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Gửi Yêu Cầu Ngay',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Display beautiful loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppTheme.primaryBlue),
                const SizedBox(height: 16),
                const Text(
                  'Đang xử lý yêu cầu VIP...',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Generate random tracking number
    final reqId = 'SR-${Random().nextInt(9000) + 1000}';

    // Call travel provider to register a new tracker document
    final docTitle = 'Đoàn: ${_nameController.text} (${_guests.toInt()} khách)';
    final docDesc = 'Dịch vụ: $_selectedCategory. Ngân sách: \$${_budget.toInt()}. Mã số: #$reqId. Trạng thái: Đang xử lý.';

    final success = await ref.read(documentsProvider.notifier).addDocument(
          title: docTitle,
          description: docDesc,
          icon: 'business',
          color: _selectedCategory == 'Nghỉ dưỡng VIP' ? '#FF9800' : '#176FF2',
        );

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Display beautiful wow-factor Success Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_user, color: Colors.green.shade600, size: 48),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Đăng Ký Thành Công!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textBlack),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mã số theo dõi: #$reqId',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Bộ phận tư vấn khách hàng đặc biệt của chúng tôi đã tiếp nhận và sẽ liên hệ lại với bạn trong vòng 2 giờ làm việc qua điện thoại hoặc email.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // Close success dialog
                        Navigator.pop(context); // Pop current contact page back to profile
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Đồng ý', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Có lỗi xảy ra khi xử lý yêu cầu. Vui lòng liên hệ hotline.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
