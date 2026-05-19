package com.example.onlinetravelagent.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.onlinetravelagent.ui.theme.OnlineTravelAgentTheme

data class DocumentItem(
    val title: String,
    val description: String,
    val icon: ImageVector,
    val color: Color
)

@Composable
fun ProfileScreen() {
    val documents = listOf(
        DocumentItem("Hộ chiếu", "Hết hạn: 12/2030", Icons.Default.Description, Color(0xFF176FF2)),
        DocumentItem("Visa", "Vietnam - Multiple Entry", Icons.Default.Assignment, Color(0xFF4CAF50)),
        DocumentItem("Bảo hiểm du lịch", "Bảo việt - Toàn cầu", Icons.Default.VerifiedUser, Color(0xFFFF9800)),
        DocumentItem("Vé máy bay", "Phú Quốc - Sài Gòn", Icons.Default.FlightTakeoff, Color(0xFFE91E63))
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .padding(horizontal = 20.dp)
    ) {
        Spacer(modifier = Modifier.height(24.dp))
        
        // Header
        Text(
            text = "Hồ sơ của tôi",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = Color.Black
        )
        
        Spacer(modifier = Modifier.height(24.dp))

        // Profile Card
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(4.dp, RoundedCornerShape(24.dp)),
            shape = RoundedCornerShape(24.dp),
            color = Color.White
        ) {
            Row(
                modifier = Modifier.padding(20.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(64.dp)
                        .clip(CircleShape)
                        .background(Color(0xFF176FF2)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Default.Person, contentDescription = null, tint = Color.White, modifier = Modifier.size(32.dp))
                }
                Spacer(modifier = Modifier.width(16.dp))
                Column {
                    Text(text = "Nguyễn Văn A", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                    Text(text = "vanya.traveler@email.com", fontSize = 14.sp, color = Color.Gray)
                }
                Spacer(modifier = Modifier.weight(1f))
                IconButton(onClick = { /* Edit profile */ }) {
                    Icon(Icons.Default.Edit, contentDescription = "Edit", tint = Color(0xFF176FF2))
                }
            }
        }

        Spacer(modifier = Modifier.height(32.dp))

        // Documents Section Header
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Hồ sơ & Giấy tờ",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Black
            )
            Text(
                text = "Thêm mới",
                fontSize = 14.sp,
                color = Color(0xFF176FF2),
                fontWeight = FontWeight.Medium
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(16.dp),
            contentPadding = PaddingValues(bottom = 24.dp)
        ) {
            items(documents) { doc ->
                DocumentCard(doc)
            }
        }
    }
}

@Composable
fun DocumentCard(doc: DocumentItem) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { /* View document */ },
        shape = RoundedCornerShape(16.dp),
        color = Color.White,
        border = androidx.compose.foundation.BorderStroke(1.dp, Color.LightGray.copy(alpha = 0.5f))
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(doc.color.copy(alpha = 0.1f)),
                contentAlignment = Alignment.Center
            ) {
                Icon(doc.icon, contentDescription = null, tint = doc.color)
            }
            Spacer(modifier = Modifier.width(16.dp))
            Column {
                Text(text = doc.title, fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                Text(text = doc.description, fontSize = 12.sp, color = Color.Gray)
            }
            Spacer(modifier = Modifier.weight(1f))
            Icon(Icons.Default.ChevronRight, contentDescription = null, tint = Color.LightGray)
        }
    }
}

@Preview(showBackground = true)
@Composable
fun ProfilePreview() {
    OnlineTravelAgentTheme {
        ProfileScreen()
    }
}
