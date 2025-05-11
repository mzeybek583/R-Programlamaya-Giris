library(tcltk)

tt <- tktoplevel()
tkwm.title(tt, "R Image Red Filter GUI")

input_path <- tclVar()
output_path <- tclVar()

choose_input <- function() {
  path <- tclvalue(tkgetOpenFile())
  tclvalue(input_path) <- path
}

choose_output <- function() {
  path <- tclvalue(tkgetSaveFile())
  tclvalue(output_path) <- path
}

run_script <- function() {
  in_path <- tclvalue(input_path)
  out_path <- tclvalue(output_path)
  
  if (in_path == "" || out_path == "") {
    tkmessageBox(message = "Please select input and output files.", icon = "error")
    return()
  }
  
  cmd <- sprintf('"%s" "%s" "%s"', "image_red_filter.R", in_path, out_path)
  system2("Rscript", args = cmd, wait = TRUE)
  tkmessageBox(message = "Image successfully processed.", icon = "info")
}

tkgrid(tklabel(tt, text = "Input Image"), pady = 5)
tkgrid(tkentry(tt, textvariable = input_path, width = 50), tkbutton(tt, text = "Browse", command = choose_input))

tkgrid(tklabel(tt, text = "Output Image"), pady = 5)
tkgrid(tkentry(tt, textvariable = output_path, width = 50), tkbutton(tt, text = "Save As", command = choose_output))

tkgrid(tkbutton(tt, text = "Run Filter", command = run_script), pady = 10)


# Pencerenin kapanmaması için
tkwait.window(tt)

