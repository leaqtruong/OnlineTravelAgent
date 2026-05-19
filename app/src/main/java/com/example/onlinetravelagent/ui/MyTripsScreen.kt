package com.example.onlinetravelagent.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material3.*
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.onlinetravelagent.R
import com.example.onlinetravelagent.ui.theme.OnlineTravelAgentTheme

data class Trip(
    val destination: String,
    val date: String,
    val status: String,
    val imageRes: Int,
    val isUpcoming: Boolean
)

@Composable
fun MyTripsScreen() {
    val trips = listOf(
        Trip("Đảo Phú Quốc", "20/05/2026 - 23/05/2026", "Sắp tới", R.drawable.phuquoc_image, true),
        Trip("Hội An", "15/04/2026 - 17/04/2026", "Đã đi", R.drawable.hoian_image, false),
        Trip("Đà Lạt", "10/03/2026 - 14/03/2026", "Đã đi", R.drawable.dalat_image, false)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .padding(horizontal = 20.dp)
    ) {
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = "Chuyến đi của tôi",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = Color.Black
        )
        Spacer(modifier = Modifier.height(16.dp))

        var selectedTab by remember { mutableIntStateOf(0) }
        val tabs = listOf("Sắp tới", "Lịch sử")

        TabRow(
            selectedTabIndex = selectedTab,
            containerColor = Color.Transparent,
            contentColor = Color(0xFF176FF2),
            divider = {},
            indicator = { tabPositions ->
                TabRowDefaults.SecondaryIndicator(
                    modifier = Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                    color = Color(0xFF176FF2)
                )
            }
        ) {
            tabs.forEachIndexed { index, title ->
                Tab(
                    selected = selectedTab == index,
                    onClick = { selectedTab = index },
                    text = {
                        Text(
                            text = title,
                            fontWeight = if (selectedTab == index) FontWeight.Bold else FontWeight.Medium
                        )
                    }
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        val filteredTrips = if (selectedTab == 0) {
            trips.filter { it.isUpcoming }
        } else {
            trips.filter { !it.isUpcoming }
        }

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(16.dp),
            contentPadding = PaddingValues(bottom = 24.dp)
        ) {
            items(filteredTrips) { trip ->
                TripCard(trip)
            }
        }
    }
}

@Composable
fun TripCard(trip: Trip) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .height(140.dp)
            .shadow(2.dp, RoundedCornerShape(24.dp)),
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Row(modifier = Modifier.fillMaxSize()) {
            Image(
                painter = painterResource(id = trip.imageRes),
                contentDescription = null,
                modifier = Modifier
                    .width(140.dp)
                    .fillMaxHeight()
                    .clip(RoundedCornerShape(24.dp)),
                contentScale = ContentScale.Crop
            )
            Column(
                modifier = Modifier
                    .padding(12.dp)
                    .fillMaxSize(),
                verticalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = trip.destination,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black
                )
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Default.CalendarToday,
                        contentDescription = null,
                        modifier = Modifier.size(14.dp),
                        tint = Color.Gray
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(text = trip.date, fontSize = 12.sp, color = Color.Gray)
                }
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            Icons.Default.LocationOn,
                            contentDescription = null,
                            modifier = Modifier.size(14.dp),
                            tint = Color(0xFF176FF2)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(text = "Vietnam", fontSize = 12.sp, color = Color(0xFF176FF2))
                    }
                    Surface(
                        color = if (trip.isUpcoming) Color(0xFFE3F2FD) else Color(0xFFF5F5F5),
                        shape = RoundedCornerShape(8.dp)
                    ) {
                        Text(
                            text = trip.status,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (trip.isUpcoming) Color(0xFF176FF2) else Color.Gray
                        )
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun MyTripsPreview() {
    OnlineTravelAgentTheme {
        MyTripsScreen()
    }
}
