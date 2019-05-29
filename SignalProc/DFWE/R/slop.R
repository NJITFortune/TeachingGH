slop = function(wav_file, syllable_data, Fs, ...) {

  #check if sample rate is given, if not extract from .wav file
  if(missing(Fs)) {
    Fs = wav_file@samp.rate
  } else {
    Fs = Fs
  }

  #check to see if input file is .wav.
  #if .wav, extract freq data, else directly use the data provided
  if(isS4(wav_file) == TRUE) {
    wav_file = wav_file@left
  } else {
    wav_file = wave_file
  }

  #check to see if syllable start and end data is provided
  if missing(syllable_data){
    specplot(wav_file, ...)

  } else {
    starts = syllable_data@syllable_start/Fs
    ends = syllable_data@syllable_end/Fs
    specplot(wav_file, ...)
    abline(v = starts, col = "Green", lwd = 2)
    abline(v = ends, col = "Red", lwd = 2)
  }
}
