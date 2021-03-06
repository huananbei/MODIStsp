#' @title gh_load_extent
#' @description Handler used to perform requirted actions if "load extent
#'  from spatial file" is clicked.
#' @noRd
#' @importFrom sf st_as_text st_crs
#' @noRd
gh_load_extent <- function(h, wids, out_proj_list, mod_proj_str,
                           modis_grid) {

  if (!all(requireNamespace(c("gWidgets", "gWidgetsRGtk2")))) {
    stop("You need to install package gWidgets to use MODIStsp GUI. Please install it with:
                install.packages(c('gWidgets', 'gWidgetsRGtk2')")
  } else {
    requireNamespace("gWidgets")
    requireNamespace("gWidgetsRGtk2")
  }
  #nocov start
  choice <- try(gWidgets::gfile(
    type = "open",
    text = "Select a vector or raster file",
    # TODO add formats to the lists!
    filter = list("Spatial files" = list(patterns = c("*.shp", "*.kml",
                                                      "*.tif", "*.dat")),
                  "Vector layers" = list(patterns = c("*.shp", "*.kml")),
                  "Raster layers" = list(patterns = c("*.tif", "*.dat")),
                  "All files"     = list(patterns = "*"))
  ), silent = TRUE)
  if (!inherits(choice, "try-error") & length(choice) != 0) {
    # Show window until the process finishes
    message("[", date(), "]", " Retrieving the Extent, please wait...")
    wait_window       <- gWidgets::gwindow(title = "Please wait",
                                 width = 400, height = 40)
    gWidgets::size(wait_window) <- c(100, 8)
    gWidgets::addHandlerUnrealize(wait_window,
                        handler = function(h, ...) return(TRUE))
    gWidgets::glabel(
      text      = paste("Retrieving Extent, please wait..."),
      editable  = FALSE,
      container = wait_window
    )
    Sys.sleep(0.05)
    # Convert bbox coordinates to output projection

    # curr_proj <-
    #   out_proj_crs <- ifelse(
    #     gWidgets::svalue(wids$proj_choice) != "User Defined",
    #     out_proj_list[[gWidgets::svalue(wids$proj_choice)]],
    #     gWidgets::svalue(wids$output_proj4))
    curr_proj <- out_proj_crs <- gWidgets::svalue(wids$output_proj4)

    print(gWidgets::svalue(wids$proj_choice))
    # Create the bounding box in the chosen projection retrieving it from
    # the specified file

    bbox_out <- try(bbox_from_file(file_path = choice,
                                   crs_out   = out_proj_crs),
                    silent = TRUE)
    if (inherits(bbox_out, "try-error")) {
      gWidgets::gmessage(bbox_out, title = "Error Detected!")
    } else {

      # proj  <- gui_get_proj(sf::st_crs(curr_proj)$proj4string)
      units <- gui_get_units(curr_proj)
      # re-set bbox in the GUI according coordinates retrieved from file
      gui_update_bboxlabels(bbox_out,
                            units,
                            wids)

      # Set tiles according with the bounding box
      gui_update_tiles(bbox_out,
                       out_proj_crs,
                       mod_proj_str,
                       modis_grid,
                       wids)
    }
    message("[", date(), "]", " Retrieving Extent, please wait... DONE!")
    gWidgets::dispose(wait_window)

  }
  #nocov end
}
