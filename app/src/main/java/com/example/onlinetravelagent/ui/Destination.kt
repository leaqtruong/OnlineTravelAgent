package com.example.onlinetravelagent.ui

data class Destination(
    val name: String,
    val location: String,
    val rating: String,
    val duration: String,
    val imageRes: Int,
    val isFavorite: Boolean = false,
    val description: String = "",
    val price: String = "",
    val reviewsCount: String = "0"
)
