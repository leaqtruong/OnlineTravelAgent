package com.example.onlinetravelagent.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.Wifi
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.onlinetravelagent.R
import com.example.onlinetravelagent.ui.theme.OnlineTravelAgentTheme

@Composable
fun DestinationDetailScreen(destination: Destination, onBackClick: () -> Unit, onFavoriteClick: () -> Unit) {
    Scaffold(
        bottomBar = {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(24.dp, RoundedCornerShape(topStart = 32.dp, topEnd = 32.dp)),
                color = Color.White,
                shape = RoundedCornerShape(topStart = 32.dp, topEnd = 32.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp)
                        .navigationBarsPadding(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(text = "Price", fontSize = 14.sp, color = Color.Gray)
                        Text(
                            text = "$${destination.price}",
                            fontSize = 28.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFF2DD4BF)
                        )
                    }
                    Button(
                        onClick = { /* Book now */ },
                        modifier = Modifier
                            .height(56.dp)
                            .width(200.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF176FF2))
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(text = "Book Now", fontSize = 18.sp, fontWeight = FontWeight.Bold)
                            Spacer(modifier = Modifier.width(8.dp))
                            Icon(Icons.Default.ArrowForward, contentDescription = null)
                        }
                    }
                }
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.White)
                .verticalScroll(rememberScrollState())
                .padding(bottom = innerPadding.calculateBottomPadding())
        ) {
            // Image Section
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(440.dp)
                    .padding(start = 12.dp, end = 12.dp, top = 0.dp, bottom = 0.dp)
            ) {
                Image(
                    painter = painterResource(id = destination.imageRes),
                    contentDescription = null,
                    modifier = Modifier
                        .fillMaxSize()
                        .clip(RoundedCornerShape(32.dp)),
                    contentScale = ContentScale.Crop
                )

                // Back Button
                Surface(
                    modifier = Modifier
                        .padding(20.dp)
                        .size(40.dp)
                        .clickable { onBackClick() },
                    shape = RoundedCornerShape(12.dp),
                    color = Color.White.copy(alpha = 0.9f)
                ) {
                    Icon(
                        Icons.Default.ChevronLeft,
                        contentDescription = "Back",
                        modifier = Modifier.padding(8.dp),
                        tint = Color.Gray
                    )
                }

                // Favorite Button
                Surface(
                    modifier = Modifier
                        .align(Alignment.BottomEnd)
                        .offset(y = 24.dp, x = (-24).dp)
                        .size(48.dp)
                        .clickable { onFavoriteClick() },
                    shape = CircleShape,
                    color = Color.White,
                    shadowElevation = 8.dp
                ) {
                    Icon(
                        if (destination.isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                        contentDescription = "Favorite",
                        modifier = Modifier.padding(12.dp),
                        tint = if (destination.isFavorite) Color.Red else Color.Gray
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Title and Map Link
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Bottom
            ) {
                Text(
                    text = destination.name,
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black,
                    modifier = Modifier.weight(1f)
                )
                Text(
                    text = "Show map",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF176FF2),
                    modifier = Modifier
                        .padding(bottom = 2.dp)
                        .clickable { /* Show map */ }
                )
            }

            // Rating
            Row(
                modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Default.Star, contentDescription = null, tint = Color(0xFFFFB300), modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "${destination.rating} (${destination.reviewsCount} Reviews)",
                    fontSize = 14.sp,
                    color = Color.Gray
                )
            }

            // Description
            Column(modifier = Modifier.padding(horizontal = 24.dp, vertical = 16.dp)) {
                Text(
                    text = destination.description,
                    fontSize = 14.sp,
                    color = Color.Gray,
                    lineHeight = 22.sp,
                    maxLines = 4,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = "Read more",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF176FF2),
                    modifier = Modifier.padding(top = 4.dp).clickable { /* Expand description */ }
                )
            }

            // Facilities
            Text(
                text = "Facilities",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Black,
                modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp)
            )

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                FacilityItem(Icons.Outlined.Wifi, "Wifi")
                FacilityItem(Icons.Default.Restaurant, "Dinner")
                FacilityItem(Icons.Default.Bathtub, "1 Tub")
                FacilityItem(Icons.Default.Pool, "Pool")
            }
            
            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
fun FacilityItem(icon: ImageVector, label: String) {
    Surface(
        modifier = Modifier.size(76.dp),
        shape = RoundedCornerShape(16.dp),
        color = Color(0xFFF3F8FE)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(icon, contentDescription = null, tint = Color.Gray, modifier = Modifier.size(24.dp))
            Spacer(modifier = Modifier.height(4.dp))
            Text(text = label, fontSize = 11.sp, color = Color.Gray)
        }
    }
}

@Preview(showBackground = true)
@Composable
fun DestinationDetailPreview() {
    val sample = Destination(
        "Coeurdes Alpes", "France", "4.5", "4N/5D", R.drawable.dalat_image,
        description = "Aspen is as close as one can get to a storybook alpine town in America. The choose-your-own-adventure possibilities—skiing, hiking, dining shopping and ....",
        price = "199",
        reviewsCount = "355"
    )
    OnlineTravelAgentTheme {
        DestinationDetailScreen(sample, {}, {})
    }
}
