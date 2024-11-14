import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pdAddress;
NetAddress myRemoteLocation;

int currentIndex = 0;  // Índice para iterar por las filas de la tabla
float lerpAmount = 0;  // Valor de interpolación para animación
float angle = 0;

// Variables para valores actuales y anteriores
float prevSuicidesRate, prevPopulation, prevLifeExpectancy, prevAlcohol, prevSchooling;
float suicidesRate, population, lifeExpectancy, alcohol, schooling;

Table table; // Tabla para cargar el dataset

void setup() {
    size(1920, 1080);
    oscP5 = new OscP5(this, 10000); // Puerto de Processing
    myRemoteLocation = new NetAddress("192.168.1.5", 8000); // Dirección y puerto de Pure Data

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
    text("Visualización Compleja de Datos con Figuras Reflejadas", 20, 20);

    if (lerpAmount < 1) {
        // Interpolación entre los valores anteriores y los actuales
        float currentSuicidesRate = lerp(prevSuicidesRate, suicidesRate, lerpAmount);
        float currentPopulation = lerp(prevPopulation, population, lerpAmount);
        float currentLifeExpectancy = lerp(prevLifeExpectancy, lifeExpectancy, lerpAmount);
        float currentAlcohol = lerp(prevAlcohol, alcohol, lerpAmount);

        // Movimiento dinámico en X e Y con ángulos
        float x = width / 2 + sin(angle) * map(currentPopulation, 1000, 10000000, 50, width / 3); // Movimiento en espiral en X
        float y = height / 2 + cos(angle) * map(currentSuicidesRate, 0, 100, 50, height / 3);     // Movimiento en espiral en Y

        // Variar color y tamaño según los datos y el ángulo
        int v_color = color(map(currentAlcohol, 0, 15, 50, 255), map(currentLifeExpectancy, 40, 90, 0, 255), 150 + (int)(50 * sin(angle)));
        float size = map(currentPopulation, 1000, 10000000, 5, 50) * (1 + 0.5 * sin(angle * 2)); // Tamaño que varía con el ángulo

        // Dibujar elipse principal
        fill(v_color, 150);
        noStroke();
        ellipse(x, y, size, size);

        // Dibujar elipses reflejadas alrededor de la principal
        for (int i = 1; i <= 5; i++) {
            float offsetAngle = angle + i * PI / 3;
            float offsetX = x + cos(offsetAngle) * size * 1.2 * i;
            float offsetY = y + sin(offsetAngle) * size * 1.2 * i;
            float offsetSize = size * (1.0 - 0.1 * i);

            fill(v_color, 100 - i * 15); // Reducción gradual en transparencia
            ellipse(offsetX, offsetY, offsetSize, offsetSize);
        }

        // Dibujar múltiples rectángulos que representan el consumo de alcohol
        for (int i = 1; i <= 3; i++) {
            float rectWidth = map(currentAlcohol, 0, 15, 10, 100) * (1 + i * 0.2);
            float rectHeight = map(currentLifeExpectancy, 40, 90, 10, 50) * (1 + i * 0.2);
            fill(100, map(currentAlcohol, 0, 15, 50, 255), 200, 150 - i * 20);

            pushMatrix();
            translate(x, y);
            rotate(angle / (2 + i)); // Diferente velocidad de rotación para cada rectángulo
            rect(-rectWidth / 2, -rectHeight / 2, rectWidth, rectHeight);
            popMatrix();
        }

        // Añadir múltiples triángulos para representar la tasa de suicidio
        for (int i = 1; i <= 4; i++) {
            float triangleSize = map(currentSuicidesRate, 0, 100, 5, 30) * (1 + i * 0.1);
            fill(255, 50, 50, 180 - i * 30);

            pushMatrix();
            translate(x + cos(angle + i) * 50, y + sin(angle + i) * 50); // Posicionar triángulo alrededor de la elipse
            rotate(-angle / (3 + i)); // Diferente velocidad de rotación para cada triángulo
            triangle(-triangleSize / 2, triangleSize, triangleSize / 2, triangleSize, 0, -triangleSize);
            popMatrix();
        }

        // Dibujar líneas conectivas
        for (int i = 1; i <= 3; i++) {
            stroke(100, 100, 255, 50 * i);
            float lineX = width / 2 + cos(angle + i * PI / 2) * width / 4;
            float lineY = height / 2 + sin(angle + i * PI / 2) * height / 4;
            line(lineX, lineY, x, y);
        }

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
        prevSchooling = schooling;

        // Extraer los nuevos valores
        suicidesRate = (row.getFloat("Suicides number") / row.getFloat("Population")) * 100000;
        population = row.getFloat("Population");
        lifeExpectancy = int(row.getFloat("Life expectancy"));
        alcohol = row.getFloat("Alcohol");
        schooling = int(row.getFloat("Schooling"));

        // Enviar los nuevos datos a Pure Data
        enviarDatosAPureData(suicidesRate, population, lifeExpectancy, alcohol, schooling);
    }
}

void avanzarAlSiguienteRegistro() {
    currentIndex++; // Avanzar al siguiente registro
    if (currentIndex >= table.getRowCount()) {
        currentIndex = 0; // Reiniciar al inicio para crear un bucle
    }
    cargarValores(currentIndex); // Cargar los nuevos valores
}

void enviarDatosAPureData(float suicides_rate, float population, float life_expectancy, float alcohol, float schooling) {
    OscMessage myPianoNote = new OscMessage("/note");
    OscMessage myPdOut = new OscMessage("/pdout");
    OscMessage myVolume = new OscMessage("/volume");
    OscMessage mySecondPianoNote = new OscMessage("/note2");
    myPianoNote.add(life_expectancy);    // Tasa de suicidio
    myPdOut.add(suicides_rate);       // Población
    myVolume.add(alcohol);
    mySecondPianoNote.add(schooling);
    //myMessage.add(life_expectancy);  // Esperanza de vida
    //myMessage.add(alcohol);          // Consumo de alcohol
    oscP5.send(myPianoNote, myRemoteLocation);
    oscP5.send(myPdOut, myRemoteLocation);
    oscP5.send(myVolume, myRemoteLocation);
    oscP5.send(mySecondPianoNote, myRemoteLocation);
    println("Enviando datos a Pure Data: tasa de suicidio = " + suicides_rate + ", población = " + population + ", esperanza de vida = " + life_expectancy + ", alcohol = " + alcohol + ", schooling = " + schooling);
}


void sendOSCData(float x, float y, float size) {
  OscMessage message = new OscMessage("/visual");

  message.add(x);     // Posición X del círculo
  message.add(y);     // Posición Y del círculo
  // Enviar mensaje a Pure Data
  oscP5.send(message, pdAddress);
}
