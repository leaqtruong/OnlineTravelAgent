package com.example.onlinetravelagent

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.onlinetravelagent.ui.DashboardScreen
import com.example.onlinetravelagent.ui.MainScreen
import com.example.onlinetravelagent.ui.WelcomeScreen
import com.example.onlinetravelagent.ui.theme.OnlineTravelAgentTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            OnlineTravelAgentTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val navController = rememberNavController()
                    NavHost(navController = navController, startDestination = "welcome") {
                        composable("welcome") {
                            WelcomeScreen(onExploreClicked = {
                                navController.navigate("main") {
                                    popUpTo("welcome") { inclusive = true }
                                }
                            })
                        }
                        composable("main") {
                            MainScreen()
                        }
                    }
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun DashboardPreview() {
    OnlineTravelAgentTheme {
        DashboardScreen()
    }
}
