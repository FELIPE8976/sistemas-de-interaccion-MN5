import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pdAddress;
NetAddress myRemoteLocation;

int currentIndex = 0;  // Índice para iterar por las filas de la tabla
float lerpAmount = 0;  // Valor de interpolación para animación
float angle = 0;

// Variables para valores actuales y anteriores
float prevSuicidesRate, prevPopulation, prevLifeExpectancy, prevAlcohol;
float suicidesRate, population, lifeExpectancy, alcohol;

Table table; // Tabla para cargar el dataset

void setup() {
    size(1000, 600);
    oscP5 = new OscP5(this, 10000); // Puerto de Processing
    myRemoteLocation = new NetAddress("192.168.10.18", 8000); // Dirección y puerto de Pure Data

    // Cargar el archivo CSV (asegúrate de que esté en la carpeta "data")
    table = loadTable("30_merged_dataset_v00_final.csv", "header");

    if (table != null) {
        println("Datos cargados correctamente. Número de filas: " + table.getRowCount());
    } else {
        println("Error al cargar el archivo CSV.");
    }
}

void draw() {
    // Fondo semi-transparente para crear el efecto de desvanecimiento gradual
    fill(255, 30);
    rect(0, 0, width, height);

    textSize(12);
    fill(0);
    text("Visualización Dinámica de Datos de Suicidio y Otros Factores", 20, 20);

    if (lerpAmount < 1) {
        // Interpolación entre los valores anteriores y los actuales
        float currentSuicidesRate = lerp(prevSuicidesRate, suicidesRate, lerpAmount);
        float currentPopulation = lerp(prevPopulation, population, lerpAmount);
        float currentLifeExpectancy = lerp(prevLifeExpectancy, lifeExpectancy, lerpAmount);
        float currentAlcohol = lerp(prevAlcohol, alcohol, lerpAmount);

        // Añadir movimiento dinámico en X e Y con ángulos
        float x = width / 2 + sin(angle) * map(currentPopulation, 1000, 10000000, 50, width / 3); // Movimiento en espiral en X
        float y = height / 2 + cos(angle) * map(currentSuicidesRate, 0, 100, 50, height / 3);     // Movimiento en espiral en Y

        // Variar color y tamaño según los datos y el ángulo
        int v_color = color(map(currentAlcohol, 0, 15, 50, 255), map(currentLifeExpectancy, 40, 90, 0, 255), 150 + (int)(50 * sin(angle)));
        float size = map(currentPopulation, 1000, 10000000, 5, 50) * (1 + 0.5 * sin(angle * 2)); // Tamaño que varía con el ángulo

        fill(v_color, 150);
        noStroke();
        ellipse(x, y, size, size); // Dibuja el punto animado

        // Avanzar la animación del ángulo para el movimiento circular
        angle += 0.05;
        lerpAmount += 0.02; // Incremento del valor de interpolación para hacer la transición
    } else {
        // Resetear lerpAmount y cargar el próximo registro
        lerpAmount = 0;
        avanzarAlSiguienteRegistro();
    }
}

void cargarValores(int index) {
    if (index < table.getRowCount()) {
        TableRow row = table.getRow(index);
        
        // Almacenar los valores anteriores para la interpolación
        prevSuicidesRate = suicidesRate;
        prevPopulation = population;
        prevLifeExpectancy = lifeExpectancy;
        prevAlcohol = alcohol;

        // Extraer los nuevos valores
        suicidesRate = (row.getFloat("Suicides number") / row.getFloat("Population")) * 100000;
        population = row.getFloat("Population");
        lifeExpectancy = row.getFloat("Life expectancy");
        alcohol = row.getFloat("Alcohol");

        // Enviar los nuevos datos a Pure Data
        enviarDatosAPureData(suicidesRate, population, lifeExpectancy, alcohol);
    }
}

void avanzarAlSiguienteRegistro() {
    currentIndex++; // Avanzar al siguiente registro
    if (currentIndex >= table.getRowCount()) {
        currentIndex = 0; // Reiniciar al inicio para crear un bucle
    }
    cargarValores(currentIndex); // Cargar los nuevos valores
}

void enviarDatosAPureData(float suicides_rate, float population, float life_expectancy, float alcohol) {
    OscMessage myMessage = new OscMessage("/visual");
    myMessage.add(suicides_rate);    // Tasa de suicidio
    myMessage.add(population);       // Población
    myMessage.add(life_expectancy);  // Esperanza de vida
    myMessage.add(alcohol);          // Consumo de alcohol
    oscP5.send(myMessage, myRemoteLocation);
    println("Enviando datos a Pure Data: tasa de suicidio = " + suicides_rate + ", población = " + population + ", esperanza de vida = " + life_expectancy + ", alcohol = " + alcohol);
}


void sendOSCData(float x, float y, float size) {
  OscMessage message = new OscMessage("/visual");

  message.add(x);     // Posición X del círculo
  message.add(y);     // Posición Y del círculo
  // Enviar mensaje a Pure Data
  oscP5.send(message, pdAddress);
}
