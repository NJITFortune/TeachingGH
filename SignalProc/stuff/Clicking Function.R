
get_clicks = function(wave_file, frame_shift){
  
  #checks that package seewave is installed and loaded. If not, installs and loads 
  if("seewave" %in% rownames(installed.packages()) == FALSE) {
    print("Required package 'seewave' missing. Package will be installed.")
    install.packages("seewave")
    }
  library(seewave)
  
  #function to merge click positions nicely, internal, called later on
  #adds each element in collected lists to larger list. 
  internallistcombine = function(list1, list2){
    n = c()
    
    for(x in list1){
      n = c(n, x)
    }
    for(y in list2){
      n = c(n, y)
    }
    return(n)
  }
  
  #get the length of clip in seconds
  tmax = length(wave_file@left)/wave_file@samp.rate
  #series from 0 to the max number of frameshifts to be ploted, prevents plotting out of bounds  
  nframe = c(-1:trunc(tmax/2)+1)
  #set up collection points for click data
  internal_data_collect = c()
  #add variable frame shift with a default value of 2
  if(missing(frame_shift)) {
    fs = 2
  } else {
    fs = frame_shift
  }
  
  #plot entire spectro to get overview
  spectro(wave_file, wl = 512, 
          palette = reverse.gray.colors.2, 
          collevels = seq(-65, 0, 1), 
          scale = FALSE, 
          flim = c(0, 8),
          fastdisp = TRUE)
  
  
  #variable to continue/end click collection
  continue = 1
  
  #main function. while loop that will ask to continue when finished. allows multiple click series to be captured
  while(continue == 1) {
    #prompts user to name click series
    name_set = readline(prompt = "Enter series name: ")
    #changing variable for shifting frame
    new_plot = 1
    #multiplier for frame shift, resets each loop
    nshift = 0
    #creates new storage list. also clears list at the start of loop
    internal_list = c()
    
    #actual click capture part. 
    while(new_plot == 1) {
     #start frame
      sframe = c(0, fs)
      #amount of frame shift
      ##modify this to add overlap 
      shift = c(fs, fs)
    
      #set the frame to graph
      #test if the upper limit "b" of tlim c(a,b) is greater than the tmax of the clip. 
      #if b is greater than tmax, tmax is used as upper tlim, prevents plotting out of bounds 
      pframe = if((nshift+1)*shift[2] <= tmax) {
        sframe + shift*nshift
      } else {
        c(sframe[1] + nshift*shift[1], tmax) 
      }
    
      #plot portion of spectrogram. 2 second intervals
      #uses tlim instead of xlim to dictate x-limits 
      spectro(wave_file, wl = 512, 
              palette = reverse.gray.colors.2, 
              collevels = seq(-65, 0, 1), 
              scale = FALSE, 
              flim = c(0, 8), 
              tlim = pframe,
              fastdisp = TRUE)
    
      print("Select points on graph. Hit 'ESC' when complete")
    
      #collect set of clicks
      #plots points 
      ##locator is slow for some reason. it doesn't like to plot these points 
      clicks = locator(type = "p", col = "Red")
      #take only x values
      clicks_x = clicks[1]
      #create internal function list of click x values
      internal_list = list("a" = internallistcombine(internal_list, clicks[1]))
     
    
      #check to see if plotting complete
      continue_plot = ifelse(pframe[2] == tmax, 0, 1)
      new_plot = continue_plot
      #add 1 to nshift, advancing plot window
      nshift = nshift + 1 
    } 
  
  #rename set of clicks to user generated name
  names(internal_list) = name_set
  #add newly generated and named list to function variable for storage 
  internal_data_collect = append(internal_data_collect, internal_list)
  
  continue = as.integer(readline(prompt = "Would you like to select another series of points? 1 = Yes ; 2 = No  "))
  }
  return(internal_data_collect)
}


