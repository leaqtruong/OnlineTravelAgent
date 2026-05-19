package com.example.onlinetravelagent.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.onlinetravelagent.ui.theme.OnlineTravelAgentTheme

@Composable
fun MainScreen(viewModel: TravelViewModel = viewModel()) {
    var selectedItem by remember { mutableIntStateOf(0) }
    val items = listOf("Khám phá", "Chuyến đi", "Yêu thích", "Cá nhân")
    val icons = listOf(
        Icons.Default.Home,
        Icons.Default.ConfirmationNumber,
        Icons.Default.FavoriteBorder,
        Icons.Default.PersonOutline
    )

    val selectedDestination by viewModel.selectedDestination.collectAsState()

    Scaffold(
        bottomBar = {
            if (selectedDestination == null) {
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(topStart = 32.dp, topEnd = 32.dp),
                    color = Color.White,
                    shadowElevation = 16.dp
                ) {
                    NavigationBar(
                        containerColor = Color.Transparent,
                        tonalElevation = 0.dp,
                        modifier = Modifier
                            .navigationBarsPadding()
                            .height(80.dp)
                    ) {
                        items.forEachIndexed { index, item ->
                            NavigationBarItem(
                                icon = {
                                    Icon(
                                        icons[index],
                                        contentDescription = item,
                                        modifier = Modifier.size(24.dp),
                                        tint = if (selectedItem == index) Color(0xFF176FF2) else Color.Gray.copy(alpha = 0.5f)
                                    )
                                },
                                label = {
                                    Text(
                                        text = item,
                                        color = if (selectedItem == index) Color(0xFF176FF2) else Color.Gray.copy(alpha = 0.5f),
                                        style = MaterialTheme.typography.labelSmall
                                    )
                                },
                                selected = selectedItem == index,
                                onClick = { selectedItem = index },
                                colors = NavigationBarItemDefaults.colors(
                                    indicatorColor = Color.Transparent
                                )
                            )
                        }
                    }
                }
            }
        }
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding)) {
            if (selectedDestination != null) {
                DestinationDetailScreen(
                    destination = selectedDestination!!,
                    onBackClick = { viewModel.selectDestination(null) },
                    onFavoriteClick = { viewModel.toggleFavorite(selectedDestination!!.name) }
                )
            } else {
                when (selectedItem) {
                    0 -> DashboardScreen(viewModel, onDestinationClick = { viewModel.selectDestination(it) })
                    1 -> MyTripsScreen()
                    2 -> FavoritesScreen(viewModel, onDestinationClick = { viewModel.selectDestination(it) })
                    3 -> ProfileScreen()
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun MainScreenPreview() {
    OnlineTravelAgentTheme {
        MainScreen()
    }
}
