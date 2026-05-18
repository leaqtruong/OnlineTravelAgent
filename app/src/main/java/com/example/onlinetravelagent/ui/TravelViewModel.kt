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
            Destination("Đà Lạt", "Lâm Đồng, VN", "4.1", "4N/5D", R.drawable.dalat_image),
            Destination("Đảo Phú Quốc", "Kiên Giang, VN", "4.5", "2N/3D", R.drawable.phuquoc_image),
            Destination("Hội An", "Quảng Nam, VN", "4.8", "2N/1Đ", R.drawable.hoian_image)
        )
    )
    val destinations: StateFlow<List<Destination>> = _destinations.asStateFlow()

    private val _recommended = MutableStateFlow(
        listOf(
            Destination("Hội An", "Quảng Nam, VN", "4.8", "2N/1Đ", R.drawable.hoian_image),
            Destination("Đà Lạt", "Lâm Đồng, VN", "4.9", "2N/1Đ", R.drawable.dalat_image),
            Destination("Đảo Phú Quốc", "Kiên Giang, VN", "4.5", "2N/3D", R.drawable.phuquoc_image)
        )
    )
    val recommended: StateFlow<List<Destination>> = _recommended.asStateFlow()

    fun toggleFavorite(name: String) {
        _destinations.update { list ->
            list.map { if (it.name == name) it.copy(isFavorite = !it.isFavorite) else it }
        }
        _recommended.update { list ->
            list.map { if (it.name == name) it.copy(isFavorite = !it.isFavorite) else it }
        }
    }
}
