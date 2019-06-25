#' domplot
#'
#' Plots the dominate frequency of a specrogram. Two options for dominate frequency functions are provided. One from seewave, which works
#' nicely and one from   which attempts to mitagate jumps in the dominate frequency. This is useful when there are breaks in the
#' syllable.
#'
#'


domplot = function(wav_file, Fs, nfft, amp_range, df_fix = TRUE, dfcol, bat = TRUE, ...) {

  #check for and set nfft
  if(missing(nfft) && bat == FALSE ) {
    nfft = 512
  }
  if(missing(nfft) && bat == TRUE) {
    nfft = 128
  } else {
    nfft = nfft
  }

  #set defaults for amp_range when bat = TRUE
  if(missing(amp_range) && bat == TRUE) {
    ar = c(-10,0)
  }
  if(missing(amp_range) && bat == FALSE) {
    ar = c(-25,0)
  } else {
    ar = amp_range
  }


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
    wav_file = wav_file
  }

  #check for dfcol to set default dominate frequency plot color
  if(missing(dfcol)) {
    col = dfcol
  } else {
    col = "Blue"
  }

  #plot spectro and dominant frequency
  specplot(wav_file, Fs, nfft = nfft, amp_range = ar, ...)
  par(new = TRUE)
  #dfreq function from seewave
  dfreq(wav_file, f = Fs,
        type = "l",
        wl = nfft,
        ovlp = 95,
        xaxt = "none",
        yaxt = "none",
        xlab = "",
        ylab = "",
        col = col,
        lwd = 2)
}
