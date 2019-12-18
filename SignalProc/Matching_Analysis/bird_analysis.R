clipping1 = readWave("~/Desktop/Matching2018/clippings_for_analysis/ZOOM0007_2015_clipped.wav")

specplot(clipping1, amp_range = c(-20,0), y_limit=c(0,5000))

test_clippings = sepsyll(clipping1)
         
specplot(test_clippings$syl23, amp_range = c(-20,0), Fs = 44100, y_limit =c(0,5000) )
