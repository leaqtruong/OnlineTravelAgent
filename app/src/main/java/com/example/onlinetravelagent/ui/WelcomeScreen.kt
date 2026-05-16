package com.example.onlinetravelagent.ui

import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.onlinetravelagent.R
import kotlinx.coroutines.delay

@Composable
fun WelcomeScreen(onExploreClicked: () -> Unit) {
    val images = listOf(R.drawable.dalat_image, R.drawable.phuquoc_image, R.drawable.hoian_image)
    var currentImageIndex by remember { mutableIntStateOf(0) }

    // Start a coroutine to cycle through the images
    LaunchedEffect(Unit) {
        while (true) {
            delay(4000) // Change image every 4 seconds
            currentImageIndex = (currentImageIndex + 1) % images.size
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        // Background Image with Crossfade Animation
        Crossfade(
            targetState = images[currentImageIndex],
            animationSpec = tween(durationMillis = 1000), // 1 second fade duration
            label = "Background Image Crossfade"
        ) { imageRes ->
            Image(
                painter = painterResource(id = imageRes),
                contentDescription = "Background Image",
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
        }

        // Gradient Overlay for text visibility
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.7f)),
                        startY = 800f
                    )
                )
        )

        // Title at the top
        Text(
            text = "Vietnam",
            fontSize = 80.sp,
            fontWeight = FontWeight.Bold,
            fontFamily = FontFamily.Cursive,
            color = Color.White,
            modifier = Modifier
                .align(Alignment.TopCenter)
                .padding(top = 80.dp)
        )

        // Bottom content
        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .fillMaxWidth()
                .navigationBarsPadding()
                .padding(32.dp)
        ) {
            Text(
                text = "Tận hưởng",
                fontSize = 24.sp,
                fontWeight = FontWeight.Normal,
                color = Color.White
            )
            Text(
                text = "Kỳ nghỉ",
                fontSize = 40.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            Text(
                text = "Trong mơ",
                fontSize = 40.sp,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            
            Spacer(modifier = Modifier.height(32.dp))

            Button(
                onClick = onExploreClicked,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF176FF2) // Primary blue color
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                Text(
                    text = "Khám phá",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White
                )
            }
        }
    }
}
