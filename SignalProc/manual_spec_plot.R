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
