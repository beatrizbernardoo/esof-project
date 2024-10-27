package com.example.seed_you_later;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.CountDownLatch;

import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QuerySnapshot;

import java.util.Map;



public class MainActivity extends FlutterActivity {


    private static final String CHANNEL = "com.example.app/login";


    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("login") || call.method.equals("register") ) {
                                boolean isAuthenticated = doLogin();
                                result.success(isAuthenticated);
                            } else if (call.method.equals("logout")) {
                                doLogout();
                                result.success(true);
                            }
                            else if (call.method.equals("addPlantToUserCollection")) {
                                String plantName = call.argument("plantName");
                                List<String> scientificName = call.argument("plantScientificName");
                                String cycle = call.argument("plantCycle");
                                String watering = call.argument("plantWatering");
                                List<String> sunlight = call.argument("plantSunlight");
                                Map<String, Object> defaultImage = call.argument("plantDefaultImage");
                                 String wateringTime = call.argument("plantWateringTime");

                                addPlantToUserCollection(plantName,scientificName,cycle,watering,sunlight,defaultImage,wateringTime);
                                result.success(true);
                            }
                            else if (call.method.equals("getUserPlants")) {
                                System.out.println("METHOD USER PLANTS");
                                List<String> userPlants = new ArrayList<>();
                                result.success(userPlants);
                            } 
                            else if (call.method.equals("getCurrentUserId")) {
                                FirebaseUser currentUser = FirebaseAuth.getInstance().getCurrentUser();
                                String userId = currentUser.getUid();
                                result.success(userId);

                            } else {
                                result.notImplemented();
                            }
                        }
                );

    }

    private boolean doLogin() {
        return true;
    }

    private void doLogout() {
        FirebaseAuth.getInstance().signOut();
        Intent intent = new Intent(this, Login.class);
        startActivity(intent);
        finish();
    }



    private void addPlantToUserCollection(String plantName,List<String> scientificName,
                                        String cycle,String watering,List<String> sunlight, Map<String, Object> defaultImage, String wateringTime) {
        FirebaseUser currentUser = FirebaseAuth.getInstance().getCurrentUser();
        if (currentUser != null) {
            String userId = currentUser.getUid();
            FirebaseFirestore db = FirebaseFirestore.getInstance();

            db.collection("users").document(userId).collection("plants")
                    .add(new HashMap<String, Object>() {{
                        put("commonName",plantName);
                        put("scientificName", scientificName);
                        put("cycle",cycle);
                        put("watering",watering);
                        put("sunlight",sunlight);
                        put("defaultImage",defaultImage);
                        put("wateringTime", wateringTime);
                        put("status","Alive");
                        //Aqui podemos por mais coisas para guardar nas infos da planta como o status

                    }})
                    .addOnSuccessListener(documentReference -> {
                        System.out.println("Plant added to user collection with ID: " + documentReference.getId());
                    })
                    .addOnFailureListener(e -> {
                        System.out.println("Error adding plant to user collection: " + e.getMessage());
                    });
        } else {
            System.out.println("User is not logged in.");
        }
    }
}

