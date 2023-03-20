scores=[0.98
0.94
0.98
0.93
0.54
0.82
0.85
0.80
0.89
0.90
0.31
0.73
0.91
0.88
0.84
0.81
0.93
0.68
0.90
0.62
0.79
0.88
0.48
0.70
1.00
0.69
0.81
0.61
0.71
0.84
0.66
0.84
0.89];

winds = 0:0.05:1;

figure(1); clf;
histogram(scores, winds);
    str = ['n = ', num2str(length(scores))];
text(0.1, 6.0, str);
    str = ['Mean = ', num2str(round(mean(scores)*100)), '%'];
text(0.1, 5.5, str);
text(0.1, 5.0, 'BIOL340•2023•Exam 2');
xlim([0, 1]);
