#'training_cut
#'
#'This function cuts up preprocessed recordings into even chunks.
#'
#'@return An dataframe of chunks containing raw audio data
#'
#'@usage training_cut(audio_data, fs, chunk_length)
#'
#'@param audio_data Audio data as either a wav file of a list of frequencies 
#'@param Fs Sample rate, does not need to be included if it is encoded in a wav file 
#'@param chunk_length Length of chunk in seconds, defaults to 1 second
#'
#'@examples
#'traning_cut(bcw_full, chunk_length = 0.5)
#'
#'@export

training_cut = function(audio_data, Fs, chunk_length) {
  
  #creates a user input for sampling frequency.
  #If no user input then the function will try to extract from .wav file
  #this must come first as the next if statement will save wav as raw audio
  if(missing(Fs)) {
    Fs = audio_data@samp.rate
  } else {
    Fs = Fs
  }
  
  #check to see if input file is .wav.
  #if .wav, extract freq data, else directly use the data provided
  if(isS4(audio_data) == TRUE) {
    audio_data = audio_data@left
  } else {
    audio_data = audio_data
  }
  
  
  if(missing(chunk_length)) {
    chunk_length = 1
  } else {
    chunk_length = chunk_length
  }
  
  #inverse of chunk length
  chunk_var = 1/chunk_length
  
  #number of chunks to be created
  ttotal = as.integer(length(audio_data)/Fs*chunk_var)
  
  #create emtpy array to store chunks
  chunks = array(dim = c(ttotal,Fs*chunk_length))
  
  for (i in seq(1,ttotal,1)){
    start = (i-1) * (Fs*chunk_length)
    if (i > 1) {
      start = start + 1 
    }
    end = i * (Fs*chunk_length)
    chunks[i,] = audio_data[start:end]
  }
  
  return(chunks)
  
}