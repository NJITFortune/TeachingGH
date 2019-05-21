install.packages("signal")
library(signal)

nfft = 1024
wl = 256
ovlp = 128
snd = zf_data@left

spec = specgram(snd, nfft, Fs, 256, 128)

P = abs(spec$S)

P = P/max(P)

P = 10*log10(P)

t = spec$t


image(x = t, y = spec$f, z = t(P), 
      zlim = c(-35, -5),
      col = (100), 
      ylab = "Frequency [Hz]", 
      xlab = "Time [s]")

spectro(zf_data, zf_data@samp.rate, 256, ovlp = 50, 
        scale = FALSE, 
        collevels = c(-80, 0, 1))

z = t(P)
max(z)
min(z)


drericfortunesperfectspectrogramplottingfunction = function(freq_data, Fs, nfft, wl, ovlp, normal = TRUE, dBscale) {
  #nfft, wl are input in points
  #ovlp is input in percent 
  
  #check if sample rate is given, if not extract from .wav file
  if(missing(Fs)) {
    Fs = wave_file@samp.rate
  } else {
    Fs = Fs
  }
  
  #checks if nfft is given, if not substitutes default value
  if(missing(nfft)) {
    nfft = 1024
  } else {
    nfft = nfft
  }
  
  #checks if wl is given, if not substitutes default value
  if(missing(wl)) {
    wl = 256
  } else {
    wl = wl
  }
  
  #checks if ovlp is given, if not substitutes default value
  if(missing(ovlp)) {
    ovlp = 128
  } else {
    ovlp = (ovlp/100) * wl
  }
  #check to see if input file is .wav.
  #if .wav, extract freq data, else directly use the data provided
  if(isS4(freq_data) == TRUE) {
    snd = freq_data@left
  } else {
    snd = freq_data
  }

  #remove offset
  snd = snd - mean(snd)
  
  #produce spectrogram of data using signal function  
  ##MUST HAVE SIGNAL INSTALLED 
  spec = specgram(snd, nfft, Fs, wl, ovlp)
  
  #remove phase info
  P = abs(spec$S)
  
  #normalize
  if(normal) {
    P = P/max(P)
  }
  
  #convert to dB
  P = 10*log10(P)
  
  #extract time
  t = spec$t
  
  #check min and max of z and determine reasonable zlims 
  if(missing(dBscale)) {
    dBscale = c(min(t(P)), max(t(p)))
  } else {
    
    
  }
  
  
  #plot
  image(x = t, y = spec$f, z = t(P), 
        zlim = c(-35, -5),
        col = (100), 
        ylab = "Frequency [Hz]", 
        xlab = "Time [s]")
}


