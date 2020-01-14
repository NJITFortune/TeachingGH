#'batch_specplot
#'
#'Plot batches of spectrograms from arrays of chunks. Uses arrays output from the training_cut function.
#'Will output images of spectrograms for use in neural network. 
#'
#'@return This function outputs a multidimensional array of rgb images 
#'
#'@usage batch_specplot(spec_files, file_path = 'C://Users//eric_fortune//Desktop', name = 'birds', width = 100, height = 100)
#'
#'@param input_array 2-D array of frequency data already broken into chunks 
#'@param Fs Sample frequency of audio data 
#'@param file_path Path to save image files 
#'@param name Base name of files
#'@param width Width in pixels of output files. Defaults to 299
#'@param height Height in pixels of output files. Defaults to 299
#'@param ... Other arguments to pass to specplot function. See specplot from DFWE for arguments. NOTE: amp_range must be
#'specified here
#'
#'@examples
#'batch_specplot(spec_files, file_path = 'C://Users//eric_fortune//Desktop', name = 'birds', width = 100, height = 100)
#'
#'@export

batch_specplot = function(input_array, Fs, file_path, name, width, height, ...) {
  
  #set defaults for width and height
  if(missing(width)) {
    width = 299
  } else {
    width = width
  }
  
  if(missing(height)) {
    height = 299
  } else {
    height = width
  }
  
  #number of images to generate
  num_plots = length(input_array[,1])
  
  #create and save images 
  for (i in seq(1,num_plots, 1)) {
    
    mypath = file.path(file_path, paste(name, i, ".png", sep = ""))
    
    png(filename = mypath, width = width, height = height)
    specplot(input_array[i,],
             Fs = Fs,
             color = 1, 
             no_label = TRUE,
             ...)
    dev.off()
    
  }
  
}