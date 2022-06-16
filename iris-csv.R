################################################################################
# Simple R script to read a CSV file and plot the data.
# The CSV file is assumed to have the following columns:
#   1. Petal length in cm
#   2. Petal width in cm
#   3. Species of the Iris flower
#
# The user is asked if he wants to add a new row ( a flower he found ) to the
# data. If yes, the program asks for the data and adds it to the data and ask
# for how much neighbors does the script want to determine the species of the
# new flower. Then the script plots a circle around the new flower and the
# neighbors of the new flower.#
#
# @author: Tom Planche (github.com/tomplanche - tomplanche@icloud.com)
# @date:   11th of June 2022
#
################################################################################


# SETUP ========================================================================
# install.packages("plotrix") # If plotrix package is not installed, install it.
library(dplyr)
library(ggplot2)
library(glue)
library(concaveman)

if(!require('ggforce')) {
  install.packages('ggforce')
  library('ggforce')
}

setwd("~/Desktop/Prog/depotsGit/irisCsv") # set working directory to the current directory.
# END SETUP ====================================================================

# FUNCTIONS ====================================================================

# Function to read the CSV file and return the data.
fetch_data <- function() {
  return <- read.csv("src/iris_2D.csv", TRUE, ",")
}

#' Dertermine the species of the found/mystery iris.
#'
#' @param length the length of the iris petal.
#' @param width the width of the iris petal.
#' @param nb_neighbors the number of neighbors to determine the species.
#' @return Array containing the species name and the distance of the nb_neighbors'th neighbor to the found iris.
#' @examples
#' iris_species_distance(5.1, 3.5, 3)
#' iris_species_distance(5.1, 3.5, 5)
determine_species <- function(length_, width_, nb_neighbors) {
  data <- fetch_data() # get the data from the CSV file.

  # if length and/or width are character or string, convert to numeric
  if (is.character(length_) || is.character(width_)) {
    length_ <- as.numeric(length_)
    width_ <- as.numeric(width_)
  }

  # Calculate the distance of all the flowers to the found iris.
  data <- data %>%
    mutate(
      distance = sqrt(
        (data$petalLength - length_)^2 + (data$petalWidth - width_)^2
      ),
      species = "mystery"
    ) %>%
    arrange(distance)

  print(data)

  # count the species of the first nb_neighbors rows
  species_count <- table(data$species[1:nb_neighbors])

  circle_radius_ <- data$distance[nb_neighbors] # get the radius of the circle to plot.
  # return the species name with the highest count and the distance of the nb_neighbors'th neighbor to the found iris.
  return(
    c(
      species_name = names(species_count)[which.max(species_count)],
      circle_radius = circle_radius_
    )
  )
}

# main function to plot the data and ask the user if he wants to add a new flower.
main_func_tom <- function() {
  data <- fetch_data() # get the data from the CSV file.
  add_data <- FALSE

  legendCols <- c("aquamarine4", "coral1", "cornflowerblue") # set the legend colors.

  # get user input
  add_mystery_iris  <- readline("Do you have an iris you want me to deduce the species from? (y/n) : ")

  # if the user missespells the answer, ask again.
  while (length(add_mystery_iris) != 1 || !is.character(add_mystery_iris) || !(add_mystery_iris %in% c("y", "Y", "n", "N"))) {
    add_mystery_iris <- readline("Do you have an iris you want me to deduce the species from? (y/n) : ")
  }

  if (add_mystery_iris %in% c("y", "Y")) {
    add_data <- TRUE
  }

  # if the user wants to add a mystery iris, ask for the data.
  if (add_data) {
    # ask for the length and width of the mystery iris.
    mystery_iris <- readline("Please enter the values (length,witdh) of the mystery iris (separated by a comma): ")

    # split mystery_iris into length and width and convert to numeric
    mystery_iris_split_as_nb <- as.vector(as.numeric(unlist(strsplit(mystery_iris, ","))))
    mystery_iris_split <- c(as.character(unlist(mystery_iris_split_as_nb)), "mystery")

    data <- rbind(data, mystery_iris_split)

    legendCols <- c("black", legendCols) # add the mystery iris to the legend.

    # ask for the number of neighbors to determine the species of the mystery iris.
    nb_neighbors <- as.numeric(readline(paste0("How many neighbors do you want to use? (1-", nrow(data) - 1, ") : ")))

    # if the user missespells the answer, ask again.
    while (!is.numeric(nb_neighbors) || nb_neighbors < 1 || nb_neighbors > nrow(data) - 1) {
      nb_neighbors <- readline(glue("How many neighbors do you want to use? (1-{nrow(data) - 1}) : "))
    }

    # determine the species of the mystery iris.
    mystery_species <- determine_species(mystery_iris_split_as_nb[1], mystery_iris_split_as_nb[2], nb_neighbors)["species_name"]

    print(
      paste0(
        "The species of the mystery iris is: ", mystery_species
      )
    )
  }

  data_to_plot <- data %>%
    mutate(
      petalLength = as.numeric(petalLength),
      petalWidth = as.numeric(petalWidth)
    )

  to_plot <- data_to_plot %>%
    ggplot(
      aes(
        x = petalLength,
        y = petalWidth,
        color = species
      )
    ) +
    geom_point() +
    geom_mark_hull(
      data = data_to_plot,
      aes(
        label = species,
        filter = species != "mystery"
      ),
      concavity = 2
    ) +
    scale_x_continuous(
      limits = as.numeric(c(
        floor(min(data_to_plot$petalLength)),
        ceiling(max(data_to_plot$petalLength))
      )),
      breaks = seq(
        floor(min(data_to_plot$petalLength)) ,
        ceiling(max(data_to_plot$petalLength)),
        by = 1,
      )
    ) +
    labs(
      title = "Iris data",
      x = "Petal length",
      y = "Petal width",
    ) +
    scale_color_manual(
      # labels = legendNames,
      values = legendCols
    ) +
    theme(
      axis.line = element_line(
        colour = "black",
        size = 1,
        linetype = "solid"
      )
    ) + coord_fixed(
    ratio = 2
  )

  if (add_data) {
    # TODO Add circle, centered on the mystery point with the radius
    # TODO of the nb_neighbors'th distance to the mystery point.
  }
  to_plot
}

# FUNCTION CALLS =================================================================
main_func_tom()
# #
# print(determine_species(4, .75, 5))