#' domplot
#'
#' Plots the dominate frequency of a specrogram. Uses seeWave dfreq function. Will plot directly on top of spectrogram. This function
#' will plot and automatically output the matrix result of dfreq. This allows some other analysis to be done, for instance taking
#' minimum/maximum or generating a linear regression.
#'
#' @param wav_file A .wav file or list of frequency data
#' @param Fs Sample rate, optional if included in .wav file
#' @param nfft Default value 128 when bat = TRUE, when bat = FALSE the default is 512
#' @param amp_range Changes default mapping of colors to decible range
#' @param bat Defaults to TRUE, a series of default values tuned to produce nice plots from bat data
#' @param dfcol Sets color for dominant frequency points
#' @param ... Pass parameters on to specplot function !!EXCEPT amp_range!!
#'
#' @examples domplot(bat_syllables$syl1, f = 250000, dfcol = "White")
#'
#' @export

domplot = function(wav_file, Fs, nfft, amp_range, dfcol, bat = TRUE, ...) {

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
    amp_range = c(-10,0)
  }
  if(missing(amp_range) && bat == FALSE) {
    amp_range = c(-25,0)
  } else {
    amp_range = amp_range
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
    dfcol = "Blue"
  } else {
    dfcol = dfcol
  }

  domf = dfreq(wave = wav_file,
               f = Fs,
               wl = nfft,
               ovlp = 75,
               threshold = 15,
               plot = FALSE)

  #linear regression model
  reg1 = lm(domf[,2]~domf[,1])


  #plot spectro and dominant frequency
  specplot(wav_file, Fs, nfft = nfft, amp_range = amp_range, ...)
  par(new = TRUE)
  #dfreq function from seewave
  plot.default(domf,
               type = "p",
               pch = 20,
               xaxt = "none",
               yaxt = "none",
               xlab = "",
               ylab = "",
               col = dfcol)
  abline(reg1, col = dfcol)

  print(reg1)
  return(domf)

}
