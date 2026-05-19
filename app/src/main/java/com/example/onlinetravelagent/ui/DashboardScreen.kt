package com.example.onlinetravelagent.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.onlinetravelagent.R
import com.example.onlinetravelagent.ui.theme.OnlineTravelAgentTheme

@Composable
fun DashboardScreen(viewModel: TravelViewModel? = null, onDestinationClick: (Destination) -> Unit = {}) {
    var selectedCategory by remember { mutableStateOf("Địa điểm") }
    val categories = listOf("Địa điểm", "Khách sạn", "Máy bay", "Ẩm thực")

    val destinations by viewModel?.destinations?.collectAsState() ?: remember { mutableStateOf(emptyList()) }
    val recommended by viewModel?.recommended?.collectAsState() ?: remember { mutableStateOf(emptyList()) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp),
    ) {
            Spacer(modifier = Modifier.height(24.dp))
            
            // Header: Greeting & Notification
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Xin chào, User!",
                        fontSize = 14.sp,
                        color = Color.Black,
                        fontWeight = FontWeight.Normal
                    )
                    Text(
                        text = "Bạn muốn đi đâu?",
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.Black
                    )
                }
                IconButton(onClick = { /* Handle notification */ }) {
                    Icon(
                        Icons.Outlined.Notifications,
                        contentDescription = "Notifications",
                        modifier = Modifier.size(28.dp),
                        tint = Color.Gray
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Search Bar
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                color = Color(0xFFF3F8FE)
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.Search, contentDescription = null, tint = Color.Gray, modifier = Modifier.size(20.dp))
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = "Tìm kiếm hoạt động",
                        color = Color.Gray.copy(alpha = 0.6f),
                        fontSize = 14.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Categories
            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                items(categories) { category ->
                    val isSelected = selectedCategory == category
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(16.dp))
                            .background(if (isSelected) Color(0xFFF3F8FE) else Color.Transparent)
                            .clickable { selectedCategory = category }
                            .padding(horizontal = 20.dp, vertical = 12.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = category,
                            color = if (isSelected) Color(0xFF176FF2) else Color.Gray,
                            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                            fontSize = 14.sp
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Popular Section Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Phổ biến",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black
                )
                Text(
                    text = "Xem tất cả",
                    fontSize = 14.sp,
                    color = Color(0xFF176FF2),
                    fontWeight = FontWeight.Medium
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                items(destinations) { destination ->
                    PopularDestinationCard(
                        destination,
                        onFavoriteClick = { viewModel?.toggleFavorite(it.name) },
                        onClick = { onDestinationClick(destination) }
                    )
                }
            }

            Spacer(modifier = Modifier.height(32.dp))

            // Recommended Section Header
            Text(
                text = "Đề xuất",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Black
            )

            Spacer(modifier = Modifier.height(16.dp))

            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(20.dp)
            ) {
                items(recommended) { destination ->
                    RecommendedDestinationCard(
                        destination,
                        onClick = { onDestinationClick(destination) }
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
        }
}

@Composable
fun PopularDestinationCard(destination: Destination, onFavoriteClick: (Destination) -> Unit, onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .width(188.dp)
            .height(240.dp)
            .clip(RoundedCornerShape(24.dp))
            .clickable { onClick() }
    ) {
        Image(
            painter = painterResource(id = destination.imageRes),
            contentDescription = null,
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
        )
        
        // Gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.4f)),
                        startY = 300f
                    )
                )
        )

        // Favorite Button
        Surface(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(12.dp)
                .size(32.dp)
                .clickable { onFavoriteClick(destination) },
            shape = CircleShape,
            color = Color.White,
            shadowElevation = 4.dp
        ) {
            Icon(
                if (destination.isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                contentDescription = null,
                modifier = Modifier
                    .padding(8.dp)
                    .size(16.dp),
                tint = if (destination.isFavorite) Color.Red else Color.Gray
            )
        }

        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(12.dp)
        ) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0xFF4D5652).copy(alpha = 0.8f))
                    .padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
                Text(
                    text = destination.name,
                    color = Color.White,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(Color(0xFF4D5652).copy(alpha = 0.8f))
                    .padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Star, contentDescription = null, modifier = Modifier.size(12.dp), tint = Color(0xFFFFB300))
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(text = destination.rating, color = Color.White, fontSize = 10.sp, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

@Composable
fun RecommendedDestinationCard(destination: Destination, onClick: () -> Unit) {
    Column(
        modifier = Modifier
            .width(174.dp)
            .shadow(2.dp, RoundedCornerShape(16.dp))
            .background(Color.White, RoundedCornerShape(16.dp))
            .clickable { onClick() }
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(4.dp)
        ) {
            Image(
                painter = painterResource(id = destination.imageRes),
                contentDescription = null,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(96.dp)
                    .clip(RoundedCornerShape(12.dp)),
                contentScale = ContentScale.Crop
            )
            
            // Duration Badge
            Box(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .offset(x = (-8).dp, y = 8.dp)
                    .background(Color(0xFF4D5652), CircleShape)
                    .border(2.dp, Color.White, CircleShape)
                    .padding(horizontal = 8.dp, vertical = 2.dp)
            ) {
                Text(
                    text = destination.duration,
                    color = Color.White,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
        
        Spacer(modifier = Modifier.height(14.dp))
        
        Text(
            text = destination.name,
            fontSize = 14.sp,
            fontWeight = FontWeight.Medium,
            color = Color(0xFF212121),
            modifier = Modifier.padding(horizontal = 12.dp)
        )
        
        Spacer(modifier = Modifier.height(4.dp))
        
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(start = 12.dp, end = 12.dp, bottom = 12.dp)
        ) {
            Icon(
                Icons.Default.TrendingUp,
                contentDescription = null,
                tint = Color(0xFF64B5F6),
                modifier = Modifier.size(16.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
                text = "Ưu đãi đặc biệt",
                fontSize = 12.sp,
                color = Color(0xFF607D8B)
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun DashboardPreview() {
    OnlineTravelAgentTheme(dynamicColor = false) {
        Surface(color = Color.White) {
            DashboardScreen()
        }
    }
}
