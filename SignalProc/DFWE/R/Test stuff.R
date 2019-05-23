document()
library(tuneR)
library(ggplot2)
library(oce)
library(signal)
bat_sounds = readWave("Myotis_nattereri_1_o.wav")
sepsyll(bat_sounds)
zfinch_data = readWave("zfinch.wav")
zf_syllables = sepsyll(zfinch_data, thresh = 100, plot_thresh = FALSE, syllable_filter = TRUE)
bat_syllables = sepsyll(bat_sounds,
                        syllable_filter = TRUE,
                        sms = 0.0002,
                        syl_filt = .002,
                        plot_syl = FALSE,
                        index_simp = TRUE)

ggplot() +
  geom_line(aes(y = bat_syllables$syllable4, x = bat_syllables$timmy4), colour = "Blue")
warnings()

getclicks(zfinch_data)

zfinch_data@samp.rate
specplot(zfinch_data)
plot(bat_sounds@left, type = "l")

specplot(bat_syllables$syllable1, Fs = bat_sounds@samp.rate, ovlp = 95, nfft = 512)
specplot(bat_syllables$syllable2, Fs = bat_sounds@samp.rate, ovlp = 95, nfft = 512)
specplot(bat_syllables$syllable3, Fs = bat_sounds@samp.rate, ovlp = 95, nfft = 512)
specplot(bat_syllables$syllable19, Fs = bat_sounds@samp.rate, ovlp = 95, nfft = 512)
specplot(bat_syllables$syllable20, Fs = bat_sounds@samp.rate, ovlp = 95, nfft = 512)

traceback()
