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
library("plotrix") # Import plotrix package.
setwd(getwd()) # set working directory to the current directory.

# FUNCTIONS ====================================================================

# Function to read the CSV file and return the data.
fetch_data <- function() {
  return <- read.csv("iris_2D.csv", TRUE, ",", dec = ".") # read csv file
}

# Function to dertermine the species of the found/mystery iris.
# @param: length: the length of the iris petal.
# @param: width: the width of the iris petal.
# @param: nb_neighbors: the number of neighbors to determine the species.
# @return: array containing the species name and the distance of the nb_neighbors'th neighbor to the found iris.
determine_species <- function(length, width, nb_neighbors) {
  data <- fetch_data() # get the data from the CSV file.

  # if length and/or width are character or string, convert to numeric
  if (is.character(length) || is.character(width)) {
      length <- as.numeric(length)
      width <- as.numeric(width)
  }

  # Calculate the distance of all the flowers to the found iris.
  distance_spices <- sqrt((data$petalLength - length)^2 + (data$petalWidth - width)^2)

  # sort the species column as per the distance_spices
  data <- data[order(distance_spices),]

  # count the species of the first nb_neighbors rows
  species_count <- table(data$species[1:nb_neighbors])

  # return the species name with the highest count and the distance of the nb_neighbors'th neighbor to the found iris.
  return(
    c(
      species_name = names(species_count)[which.max(species_count)],
      circle_radius = sort(distance_spices)[nb_neighbors + 3]
    )
  )
}

# main function to plot the data and ask the user if he wants to add a new flower.
main <- function() {
  data <- fetch_data() # get the data from the CSV file.
  legendNames <- c("Setosa", "Virginica", "Versicolor") # set the legend names.
  legendCols <- c("Green", "Red", "Blue") # set the legend colors.

  # get user input
  add_mystery_iris  <- readline("Do you have an iris you want me to deduce the species from? (y/n) : ")

  # if the user missespells the answer, ask again.
  while (length(add_mystery_iris) != 1 || !is.character(add_mystery_iris) || !(add_mystery_iris %in% c("y", "Y", "n", "N"))) {
    add_mystery_iris <- readline("Do you have an iris you want me to deduce the species from? (y/n) : ")
  }

  mystery_iris_split <- 0 # initialize the mystery iris split.
  circle_radius <- 0 # initialize the circle radius.

  # if the user wants to add a mystery iris, ask for the data.
  if (add_mystery_iris %in% c("y", "Y")) {
    # ask for the length and width of the mystery iris.
    mystery_iris <- readline("Please enter the values (length,witdh) of the mystery iris (separated by a comma): ")

    # split mystery_iris into length and width and convert to numeric
    mystery_iris_split <- strsplit(mystery_iris, ",")
    mystery_iris_split <- c(as.numeric(unlist(mystery_iris_split)), "mystery")

    data <- rbind(data, mystery_iris_split)

    append(legendNames, "Mystery") # add the mystery iris to the legend.
    append(legendCols, "Black") # add the mystery iris to the legend.

    # ask for the number of neighbors to determine the species of the mystery iris.
    nb_neighbors <- as.numeric(readline(paste0("How many neighbors do you want to use? (1-", nrow(data) - 1, " : ")))

    # if the user missespells the answer, ask again.
    while (!is.numeric(nb_neighbors) || nb_neighbors < 1 || nb_neighbors > nrow(data) - 1) {
      nb_neighbors <- readline(glue("How many neighbors do you want to use? (1-{nrow(data) - 1}) : "))
    }

    # determine the species of the mystery iris.
    mystery_species <- determine_species(mystery_iris_split[1], mystery_iris_split[2], nb_neighbors)["species_name"]
    # determine the circle radius of the mystery iris.
    circle_radius <- determine_species(mystery_iris_split[1], mystery_iris_split[2], nb_neighbors)["circle_radius"]

    print(
      paste0(
        "The species of the mystery iris is: ", mystery_species
      )
    )
  }

    # plot the data
  plot(
    data$petalLength,
    data$petalWidth,
    xlab = "Petal Length",
    ylab = "Petal Width",
    main = "Iris Data",
    col = ifelse(
      data$species == "virginica",
      "Red",
      ifelse(data$species == "setosa",
             "Green",
             ifelse(data$species == "versicolor",
                    "Blue",
                    "Black")
      )
    ),
    pch = 16,
  )

  # plot the mystery iris circle
  draw.circle(as.numeric(mystery_iris_split[1]), as.numeric(mystery_iris_split[2]), as.numeric(circle_radius), nv=1000, border=NULL, col=NA, lty=1, lwd=1)

  # plot the legend
  legend(
    x = "topleft",
    title = "Spices",
    legend = legendNames,
    pch = c(16, 16, 16),
    col = legendCols
  )
}

# FUNCTION CALLS =================================================================
main() # plot the data