#' Read the feature dataset presence matrix.
#'
#' @param census The census object, usually returned by `cellxgene.census::open_soma()`.
#' @param organism The organism to query, usually one of `Homo sapiens` or `Mus musculus`
#' @param measurement_name The measurement object to query. Defaults to `RNA`.
#'
#' @return A `tiledbsoma::matrixZeroBasedView` object with dataset join id & feature
#'         join id dimensions, filled with 1s indicating presence. The sparse matrix
#'         is accessed with zero-based indexes since the join id's may be zero.
#' @export
#'
#' @examples
get_presence_matrix <- function(census, organism, measurement_name = "RNA") {
  exp <- get_experiment(census, organism)
  presence <- exp$ms$get(measurement_name)$get("feature_dataset_presence_matrix")
  return(presence$read()$sparse_matrix(zero_based = TRUE)$concat())
}

#' Convenience wrapper around `SOMAExperimentAxisQuery`, to build and execute a
#' query, and return it as a `Seurat` object.
#'
#' @param census The census object, usually returned by `cellxgene.census::open_soma()`.
#' @param organism The organism to query, usually one of `Homo sapiens` or `Mus musculus`
#' @param measurement_name The measurement object to query. Defaults to `RNA`.
#' @param X_layers A named character of `X` layers to add to the Seurat assay, where the names are
#'        the names of Seurat slots (`counts` or `data`) and the values are the names of layers
#'        within `X`.
#' @param obs_value_filter A SOMA `value_filter` across columns in the `obs` dataframe, expressed as string.
#' @param obs_coords A set of coordinates on the obs dataframe index, expressed in any type or format supported by SOMADataFrame's read() method.
#' @param obs_column_names Columns to fetch for the `obs` data frame.
#' @param var_value_filter Same as `obs_value_filter` but for `var`.
#' @param var_coords Same as `obs_coords` but for `var`.
#' @param var_column_names Columns to fetch for the `var` data frame.
#'
#' @return A `Seurat` object containing the sensus slice.
#' @importFrom tiledbsoma SOMAExperimentAxisQuery
#' @export
#'
#' @examples
get_seurat <- function(
    census,
    organism,
    measurement_name = "RNA",
    X_layers = c(counts = "raw", data = NULL),
    obs_value_filter = NULL,
    obs_coords = NULL,
    obs_column_names = NULL,
    var_value_filter = NULL,
    var_coords = NULL,
    var_column_names = NULL) {
  expt_query <- tiledbsoma::SOMAExperimentAxisQuery$new(
    get_experiment(census, organism),
    measurement_name,
    obs_query = tiledbsoma::SOMAAxisQuery$new(value_filter = obs_value_filter, coords = obs_coords),
    var_query = tiledbsoma::SOMAAxisQuery$new(value_filter = var_value_filter, coords = var_coords)
  )
  return(expt_query$to_seurat(
    X_layers = X_layers,
    obs_column_names = obs_column_names,
    var_column_names = var_column_names
  ))
}

#' Get the SOMAExperiment for a named organism
#'
#' @param census The census SOMACollection.
#' @param organism The organism name, e.g. `Homo sapiens`
#'
#' @return a [tiledbsoma::SOMAExperiment] with the requested experiment.
#'
#' @importFrom methods is
#' @importFrom stats setNames
#'
#' @noRd
get_experiment <- function(census, organism) {
  # lower/snake case the organism name to find the experiment name
  exp_name <- tolower(gsub("\\s+", "_", organism))
  census_data <- census$get("census_data")

  stopifnot(setNames(
    exp_name %in% census_data$names(),
    paste("Unknown organism", organism, "- does not exist")
  ))

  exp <- census_data$get(exp_name)

  stopifnot(setNames(
    is(exp, "SOMAExperiment"),
    paste("Unknown organism", organism, "- not a SOMA Experiment")
  ))

  return(exp)
}
