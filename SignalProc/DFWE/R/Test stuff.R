bat_sounds = readWave("Myotis_nattereri_1_o.wav")
zfinch_data = readWave("zfinch.wav")


zf_syllables = sepsyll(zfinch_data,
                       thresh = 100,
                       plot_thresh = FALSE,
                       syllable_filter = TRUE)

bat_syllables = sepsyll(bat_sounds,
                        syllable_filter = TRUE,
                        sms = 0.0002,
                        syl_filt = .002,
                        plot_syl = FALSE,
                        index_simp = TRUE)
document()

roxygen2::roxygenize()



