#'###############################################################################
#' Simple R script to read a CSV file and plot the data.
#' The CSV file is assumed to have the following columns:
#'   1. Petal length in cm
#'   2. Petal width in cm
#'   3. Species of the Iris flower
#'
#' The user is asked if he wants to add a new row ( a flower he found ) to the
#' data. If yes, the program asks for the data and adds it to the data and ask
#' for how much neighbors does the script want to determine the species of the
#' new flower. Then the script plots a circle around the new flower and the
#' neighbors of the new flower.#
#'
#' @author: Tom Planche (github.com/tomplanche - tomplanche@icloud.com)
#' @date:   11th of June 2022
#' @date-last-modified: 17th of June 2022
#'
#'###############################################################################


# SETUP ========================================================================
# If dplyr package is not installed, install it.
if(!require('dplyr')) {
  install.packages('dplyr')
  library('dplyr')
}

if(!require('ggplot2')) {
  install.packages('ggplot2')
  library('ggplot2')
}
if(!require('glue')) {
  install.packages('glue')
  library('glue')
}

if(!require('concaveman')) {
  install.packages('concaveman')
  library('concaveman')
}

if(!require('ggforce')) {
  install.packages('ggforce')
  library('ggforce')
}

# set working directory to the current directory.
setwd("~/Desktop/Prog/depotsGit/irisCsv")
# END SETUP ====================================================================

# FUNCTIONS ====================================================================
fetch_data <- function() {
  #' Fetches the data from the CSV file.
  #'
  #' @description This function fetches the data from the CSV file and returns a dataframe.
  #' @usage mypaste(x, y)
  #' @return A dataframe of the data.
  #' @details The inputs can be anything that can be input into
  #' the paste function.
  #'
  #' @examples
  #' data <- fetch_data()
  #' head(fetch_data())
  return <- read.csv("src/iris_2D.csv", TRUE, ",")
}

main_func_tom <- function() {
  #' Main function to plot the data and ask the user if he wants to add a new flower.
  #'
  #' @description This is the main function to plot the data and ask the user if he wants to add a new flower.
  #' @usage main_func_tom()
  #' @return nothing
  #' @details Can be improved... I'll do it later if I have time :)
  #'
  #' @examples
  #' main_func_tom()
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
    print("Please enter the values (length, witdh) of the mystery iris.")
    
    mystery_iris_length <- as.numeric(readline("Length: "))
    mystery_iris_width <- as.numeric(readline("Width: "))

    mystery_iris_infos <- c(mystery_iris_length, mystery_iris_width, "mystery")

    data <- rbind(data, mystery_iris_infos)

    data <- data %>%
      mutate(
        petalLength = as.numeric(petalLength),
        petalWidth = as.numeric(petalWidth)
      )

    legendCols <- c("black", legendCols) # add the mystery iris to the legend.

    # ask for the number of neighbors to determine the species of the mystery iris.
    nb_neighbors <- as.numeric(readline(paste0("How many neighbors do you want to use? (1-", nrow(data) - 1, ") : ")))

    # if the user missespells the answer, ask again.
    while (!is.numeric(nb_neighbors) || nb_neighbors < 1 || nb_neighbors > nrow(data) - 1) {
      nb_neighbors <- readline(glue("How many neighbors do you want to use? (1-{nrow(data) - 1}) : "))
    }

    # Calculate the distance between the mystery iris and the other iris and sort the data by distance.
    data <- data %>%
      mutate(
        distance = sqrt(
          (data$petalLength - mystery_iris_length)^2 + (data$petalWidth - mystery_iris_width)^2
        )
      ) %>%
      arrange(distance)


    # count the species of the first nb_neighbors rows
    species_count <- table(data$species[1:nb_neighbors])

    # get the species of the mystery iris.
    mystery_species <- names(species_count)[which.max(species_count)]

    print(
      paste0(
        "The species of the mystery iris is: ", mystery_species
      )
    )
  }

  # Plot the data (like no mystery iris was added).
  # I'm using the ggplot2 package to plot the data.
  to_plot <- data %>%
    ggplot(
      aes(
        x = petalLength, # x-axis
        y = petalWidth, # y-axis
        color = species # color of the points
      )
    ) +
    geom_point() + # plot the points
    geom_mark_hull( # plot the convex hull (polygon around the points of the same species)
      aes(
        label = species, # label of the polygon
        filter = species != "mystery" # filter the points that are not the mystery iris
      ),
      concavity = 2, # set the concavity of the polygon
      label.buffer = unit(50, 'mm'), # set the length of the label buffer (distance between the polygon and the label)
      con.cap = 0, # set the length of the cap (distance between the polygon and the edge of the plot)
      con.type = "elbow" # set the type of the connection (elbow, straight, curved) of the label to the polygon
    ) +
    scale_x_continuous( # set the x-axis grid
      limits = as.numeric(c(
        floor(min(data$petalLength)),
        ceiling(max(data$petalLength))
      )), # set the limits of the x-axis
      breaks = seq(
        floor(min(data$petalLength)) ,
        ceiling(max(data$petalLength)),
        by = 1,
      ) # set the breaks (intervals) of the x-axis
    ) +
    labs( # set the labels of the x- and y-axis and the title of the plot.
      title = "Iris data",
      x = "Petal length",
      y = "Petal width",
    ) +
    scale_color_manual( # set the legend colors.
      # labels = legendNames,
      values = legendCols
    ) +
    theme( # set the axis lines.
      axis.line = element_line(
        colour = "black",
        size = 1,
        linetype = "solid"
      )
    ) + coord_fixed( # set the y/x axis ratio.
    ratio = 2
  )

  if (add_data) { # if the user added a mystery iris, find the nth nearest neighbor of the mystery iris.
    data <- data %>% # filter the data to only include the nth nearest neighbor of the mystery iris.
      filter(species != "mystery") %>% # exclude the mystery iris.
      head(nb_neighbors)

    to_plot <- to_plot + # add the circles of the nth nearest neighbors of the mystery iris to the original plot.
      geom_mark_circle(
        data = data,
        aes(
          label = paste0("Mystery iris ", nb_neighbors, " nearest neighbors")
        ),
        expand = unit(0, "mm"), # set the space between the point and the circle.
        label.buffer = unit(10, "mm"), # set the length of the label buffer (distance between the circle and the label)
        con.cap = 0 # set the length of the cap (distance between the circle and the label)
      )

    nb_mystery_iris_in_data <- data %>% # count the number of iris that have the same length and width as the mystery iris.
      filter(
        petalLength == as.numeric(mystery_iris_length) &
          petalWidth == as.numeric(mystery_iris_width)
      ) %>%
      nrow()

  if (nb_mystery_iris_in_data > 0) { # if they exist, explain why the circle doesn't contain all the nth nearest neighbors.
      writeLines(
        paste0("The mystery iris appears ", nb_mystery_iris_in_data, " times in the data.
      That's why the circle only surrounds ", nb_neighbors - nb_mystery_iris_in_data, " neighbors.")
      )
    }
  }

to_plot # plot the data.
}

# FUNCTION CALLS =================================================================
main_func_tom()