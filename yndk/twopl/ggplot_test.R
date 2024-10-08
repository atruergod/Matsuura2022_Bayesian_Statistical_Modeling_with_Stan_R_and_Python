library(ggplot2)

# Sample data frame with row names
data <- data.frame(x = 1:5, y = 1:5)
rownames(data) <- c("A", "B", "C", "D", "E")

# Convert row names to a column
data$label <- rownames(data)

# Generate a set of random colors
set.seed(123)  # For reproducibility
random_colors <- sample(colors(), nrow(data))

# Create ggplot with random colors
ggplot(data, aes(x = x, y = y)) +
  geom_point(aes(color = label), size = 5) +
  geom_text(aes(label = label), vjust = -1) +
  scale_color_manual(values = random_colors)