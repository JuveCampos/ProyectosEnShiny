
my_colours <- c("#F6F5F5", "#F4F3F0", "#EDF2F0", "#E1E2E3", "#C2D3DD", "#F6F1E5",
                "#404965", "#E4CCD0", "#DFC575", "#D14845", "#E8B426", "#DF7B6D",
                "#8DBAD3", "#C44334", "#DE7E31", "#BCBFCD", "#9E4049", "#97372F",
                "#BC9AB0", "#4E3427", "#132021", "#0273AD", "#1D3F59", "#F9E892",
                "#E2A4AF", "#F6E8D3", "#A5B774", "#A38074", "#6B847E", "#61ABCC",
                "#6F86AC", "#B2BC3D", "#718E43", "#077A85", "#28A8C4", "#1D7B51",
                "#A57D35", "#3483B0", "#F7CA0E", "#F9CE73", "#FDE35C", "#FAE214",
                "#F4DDD2", "#F4C8BE", "#F5BD87", "#F3B61E", "#F2A581", "#F38387",
                "#F3A72F", "#F3952F")

# original colors
ggplot2::qplot(x = 1:50, y = 1, fill = I(my_colours), geom = 'col', width = 1) + ggplot2::theme_void()

library(TSP)
rgb <- col2rgb(my_colours)
tsp <- as.TSP(dist(t(rgb)))
sol <- solve_TSP(tsp, control = list(repetitions = 1e3))
ordered_cols <- my_colours[sol]

orden_color = function(my_colours){
  rgb <- col2rgb(my_colours)
  tsp <- as.TSP(dist(t(rgb)))
  sol <- solve_TSP(tsp, control = list(repetitions = 1e3))
  ordered_cols <- my_colours[sol]
  return(ordered_cols)
}

ordered_cols = orden_color(c("red", "green", "blue", "navy"))

ggplot2::qplot(x = 1:4, y = 1, fill = I(ordered_cols), geom = 'col', width = 1) + ggplot2::theme_void()
