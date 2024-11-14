# Data Sonification and Visualization Project

## Project Overview

This project focuses on the sonification and visualization of a global suicide dataset using Processing and Pure Data (PD). By mapping data from various countries and years onto visual and audio elements, this project provides an immersive experience that represents the data in a meaningful and dynamic way. The visualization includes multiple shapes and patterns that move, change colors, and sizes based on specific data attributes, while the sonification adds an audio dimension to the experience.

## Authors

- Luis Martinez
- Carlos Camacho

## Description

This project uses a dataset with global suicide statistics, including factors like:
- *Country*: The country for which the data is reported.
- *Year*: The year the data was collected.
- *Suicides Number*: The total number of suicides reported.
- *Population*: The total population for the country in that year.
- *Suicides/100k pop*: The suicide rate, calculated as suicides per 100,000 population.
- *Life Expectancy*: The average life expectancy in the country.
- *Alcohol Consumption*: Average alcohol consumption per person.

### Visual Components in Processing

The visualization created in Processing consists of several key elements:

1. *Main Ellipse*: 
   - Represents the country’s population.
   - Size and position change dynamically based on the suicide rate and population.
   - Positioned in a circular pattern for a flowing, dynamic effect.

2. *Reflected Ellipses*: 
   - Additional ellipses orbit the main ellipse to create a "halo" effect, enhancing the sense of motion and adding depth.
   - The size, transparency, and distance from the main ellipse vary to give the visual a "reflected" look.

3. *Rotating Rectangles*:
   - Represent alcohol consumption levels.
   - Size is based on the level of alcohol consumption.
   - Each rectangle rotates at a unique speed and angle for visual dynamism, simulating the impact of consumption on the population.

4. *Triangles*:
   - Represent the suicide rate in each country.
   - The size of each triangle reflects the suicide rate, with higher rates producing larger triangles.
   - Triangles are positioned around the main ellipse and rotate for a constant motion effect.

5. *Connecting Lines*:
   - Create pathways from the center to the ellipses, rectangles, and triangles.
   - These lines provide a sense of interconnection between different data points, making the relationships between the factors more visually apparent.

### Audio Components in Pure Data

Pure Data handles the sonification of the data, using the following mappings:

1. *Frequency*:
   - The suicide rate controls the frequency, translating higher rates into higher pitches.
   - This emphasizes the severity of higher suicide rates through an increase in tone.

2. *Amplitude*:
   - The population affects the volume, so more populous countries will produce louder sounds.
   - This creates a distinction in scale, with larger populations having a more dominant presence.

3. *Filters and Modulation*:
   - Life expectancy and alcohol consumption influence filters and modulation in Pure Data.
   - Lower life expectancy can lead to a “darker” sound, while higher alcohol consumption can add distortion or modulation, representing the societal impact of these factors.

4. *Noise Elements*:
   - White or pink noise may be added for certain ranges of suicide rates, giving a sense of instability to extreme values.

### Communication between Processing and Pure Data

- Processing sends real-time data to Pure Data using OSC (Open Sound Control), allowing the sonification to stay in sync with the visual components.
- This connection means that as each new data point is visualized in Processing, it also triggers a corresponding audio change in Pure Data, creating an interactive and dynamic experience.