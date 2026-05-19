package com.example.onlinetravelagent.ui

import androidx.lifecycle.ViewModel
import com.example.onlinetravelagent.R
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class TravelViewModel : ViewModel() {
    private val _destinations = MutableStateFlow(
        listOf(
            Destination(
                "Đà Lạt", "Lâm Đồng, VN", "4.1", "4N/5D", R.drawable.dalat_image,
                description = "Đà Lạt là thành phố ngàn hoa với khí hậu mát mẻ quanh năm. Đây là địa điểm lý tưởng cho các cặp đôi và gia đình muốn tìm kiếm sự yên bình.",
                price = "199",
                reviewsCount = "355"
            ),
            Destination(
                "Đảo Phú Quốc", "Kiên Giang, VN", "4.5", "2N/3D", R.drawable.phuquoc_image,
                description = "Phú Quốc nổi tiếng với những bãi biển xanh ngắt và cát trắng mịn. Du khách có thể thưởng thức hải sản tươi ngon và tham gia các hoạt động lặn ngắm san hô.",
                price = "250",
                reviewsCount = "1.2k"
            ),
            Destination(
                "Hội An", "Quảng Nam, VN", "4.8", "2N/1Đ", R.drawable.hoian_image,
                description = "Phố cổ Hội An là di sản văn hóa thế giới với những con phố đèn lồng lung linh và nền ẩm thực phong phú, mang đậm dấu ấn lịch sử.",
                price = "150",
                reviewsCount = "800"
            )
        )
    )
    val destinations: StateFlow<List<Destination>> = _destinations.asStateFlow()

    private val _recommended = MutableStateFlow(
        listOf(
            Destination(
                "Hội An", "Quảng Nam, VN", "4.8", "2N/1Đ", R.drawable.hoian_image,
                description = "Phố cổ Hội An là di sản văn hóa thế giới.",
                price = "150",
                reviewsCount = "800"
            ),
            Destination(
                "Đà Lạt", "Lâm Đồng, VN", "4.9", "2N/1Đ", R.drawable.dalat_image,
                description = "Thành phố sương mù lãng mạn.",
                price = "199",
                reviewsCount = "355"
            ),
            Destination(
                "Đảo Phú Quốc", "Kiên Giang, VN", "4.5", "2N/3D", R.drawable.phuquoc_image,
                description = "Thiên đường nghỉ dưỡng.",
                price = "250",
                reviewsCount = "1.2k"
            )
        )
    )
    val recommended: StateFlow<List<Destination>> = _recommended.asStateFlow()

    private val _selectedDestination = MutableStateFlow<Destination?>(null)
    val selectedDestination = _selectedDestination.asStateFlow()

    fun selectDestination(destination: Destination?) {
        _selectedDestination.value = destination
    }

    fun toggleFavorite(name: String) {
        _destinations.update { list ->
            list.map { if (it.name == name) it.copy(isFavorite = !it.isFavorite) else it }
        }
        _recommended.update { list ->
            list.map { if (it.name == name) it.copy(isFavorite = !it.isFavorite) else it }
        }
        if (_selectedDestination.value?.name == name) {
            _selectedDestination.update { it?.copy(isFavorite = !it.isFavorite) }
        }
    }
}
