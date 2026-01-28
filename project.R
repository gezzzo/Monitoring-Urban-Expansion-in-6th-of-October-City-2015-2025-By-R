# 1. Setup Environment
# Set the working directory to your project folder
setwd("~/Desktop/r-project/exam/")

# Load the required libraries
library(terra)      # For handling spatial data
library(imageRy)    # For image classification
library(ggplot2)    # For creating plots

# 2. Import and Visualize Images
# Import the satellite images for 2015 and 2025
m2015 <- rast("oct_2015.jpg")
m2025 <- rast("oct_2025.jpg")

# Check the properties of the imported data
m2015
m2025

# Show the two original images side by side
par(mfrow=c(1,2))
plot(m2015, main="6th of October - 2015")
plot(m2025, main="6th of October - 2025")

# 3. Image Classification
# Classify the 2015 image into 2 groups (clusters)
m2015c <- im.classify(m2015, num_clusters=2)

# Classify the 2025 image into 2 groups (clusters)
m2025c <- im.classify(m2025, num_clusters=2)

# Show the classified images side by side
par(mfrow=c(1,2))
plot(m2015c, main="Classes in 2015")
plot(m2025c, main="Classes in 2025")

# 4. Calculate Statistics
# Calculate pixel frequencies and percentages for 2015
f2015 <- freq(m2015c)
tot2015 <- ncell(m2015c)
perc2015 <- f2015$count * 100 / tot2015

# Calculate pixel frequencies and percentages for 2025
f2025 <- freq(m2025c)
tot2025 <- ncell(m2025c)
perc2025 <- f2025$count * 100 / tot2025

# Print the percentage results to the console
print("Percentages in 2015:")
print(perc2015)

print("Percentages in 2025:")
print(perc2025)

# 5. Create Comparison Bar Chart
# Create a data frame for plotting (use the percentages calculated above)
data <- data.frame(
  Year = factor(c("2015", "2015", "2025", "2025")),
  Class = c("Desert", "Urban", "Desert", "Urban"),
  Percentage = c(90.6, 9.4, 85.3, 14.7) # Ensure these match your actual results
)

# Plot the growth comparison using ggplot
ggplot(data, aes(x=Year, y=Percentage, fill=Class)) +
  geom_bar(stat="identity", position="dodge") +
  scale_fill_manual(values=c("khaki", "brown")) + # Khaki for Desert, Brown for Urban
  labs(title="Urban Expansion: 2015 vs 2025", y="Land Cover %") +
  theme_minimal()

# 6. Change Detection Map
# Function to make classes consistent: 
# It ensures Class 1 is always the majority (Desert) and Class 2 is Urban
standardize_map <- function(classified_img) {
  freqs <- freq(classified_img)
  # Find which value (1 or 2) is the majority
  majority_val <- freqs[which.max(freqs$count), "value"]
  
  # If the majority is value 2, we swap 1 and 2
  if(majority_val == 2) {
    r_new <- classified_img
    r_new[classified_img == 1] <- 20 # Temporary value
    r_new[classified_img == 2] <- 10 # Switch 2 to 10
    
    r_final <- r_new
    r_final[r_new == 10] <- 1 # Set Desert to 1
    r_final[r_new == 20] <- 2 # Set Urban to 2
    return(r_final)
  } else {
    return(classified_img) # Already correct
  }
}

# Apply the standardization function to both maps
m2015_fixed <- standardize_map(m2015c)
m2025_fixed <- standardize_map(m2025c)

# Calculate the Change Map by subtracting the years
# Result 1 = Growth (Blue), 0 = No Change (Gray), -1 = Loss (Red)
change_map <- m2025_fixed - m2015_fixed

# Plot the Final Change Detection Map
par(mfrow=c(1,1))
my_colors <- c("red", "gray90", "blue")
plot(change_map, col=my_colors, legend=FALSE, main="Corrected: 6th of October Urban Growth")
legend("topright",
       legend = c("New Urban Areas", "No Change", "Loss/Change"),
       fill = c("blue", "gray90", "red"),
       bty    = "o", bg = "white", cex = 1)
