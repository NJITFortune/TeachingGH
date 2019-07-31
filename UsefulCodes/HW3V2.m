%2014-01-23

% Passive membrane equation

clear all
close all

C = 1; %capacitance
Rm = 3.333; %resistance
Gl = 1/Rm; %conductance
El = -50.6; %resting membrane potential
ENa = 55; %Sodium equillibrium
Ek = -75; %potassium equillibrium
GNa = 120;%sodium conductance 
Gk = 36;%potassium conductance

%Functions


%define function for gating variables
minf = @(V) 1/(1 + exp(-(V + 40)/9));
hinf = @(V) 1/(1 + exp((V + 62)/10));
ninf = @(V) 1/(1 + exp(-(V + 53)/16));
taum = @(V) 0.3;
tauh = @(V) 1 + 11/(1 + exp(V + 62)/10);
taun = @(V) 1 + 6/(1 + exp(V + 53)/16);

%Values of Iapp



VV = -80:0.1:80;
%m1 = minf(Vv);

 for i= 1:length(VV)
     ma(i) = minf(VV(i));
     ha(i) = hinf(VV(i));
     na(i) = ninf(VV(i));
 end
 
 figure
hold on
plot(ma, VV,'r','linewidth',2);
plot(ha, VV,'c','linewidth',2);
plot(na, VV,'m','linewidth',2);
axis([0 1 -80 80]);
set(gca,'fontsize',20);
xlabel('VV');
ylabel('Voltage'); 


%Define time parameters
T = 4000; %tmax
dt = 0.1; %step size
t = 0:dt:T; %time scale

%Generate square pulse
ti = 1000;
tf = 3000;
H = zeros(1,length(t));
H(floor(ti/dt):floor(tf/dt))=1;

%%Pulses
%tt = find(t > ti & t < tf);

% Io = [0 1 2 3 4]; % Current levels
% 
% figure(1); clf; hold on;
% for i = 1:length(Io) % For each of the current levels Io
%         Iapp(i,1:length(t)) = zeros(1,length(t)); % Make a tim duration zero current signal
%         Iapp(i,tt) = Io(i); % Change the tt region (stimulus) to the current Io value
%         plot(t, Iapp(i,:)); % Plot baby plot Iapp(X,Y) where X is the current level and Y is value at each step 
% end


%create empty matricies for function output
V = zeros(1,length(t));
m = zeros(1,length(t));
h = zeros(1,length(t));
n = zeros(1,length(t));
V(1) = El;
m(1) = 0; %could also be equal to El
h(1) = 0;
n(1) = 0;

%analytical inter-spike interval rate
Iapp=4;

%Hodkin-Huxley %modified oiler
for j=1:length(t)-1
    kv1 = (Iapp*H(j) - Gl*(V(j) - El) - GNa*m(j)^3*h(j)*(V(j) - ENa) - Gk*n(j)^4*(V(j) - Ek))/C;
    km1 = (minf(V(j)) - m(j))/taum(V(j));
    kh1 = (hinf(V(j)) - h(j))/tauh(V(j));
    kn1 = (ninf(V(j)) - n(j))/taun(V(j));
    av = V(j) + kv1*dt;
    am = m(j) + km1*dt;
    ah = h(j) + kh1*dt;
    an = n(j) + kn1*dt;
    kv2 = (Iapp*H(j) - Gl*(av - El) - GNa*am^3*ah*(av - ENa) - Gk*an^4*(av - Ek))/C;
    km2 = (minf(av) - am)/taum(av);
    kh2 = (hinf(av) - ah)/tauh(av);
    kn2 = (ninf(av) - an)/taun(av);
    V(j+1) = V(j) + (kv1+kv2)*dt/2;
    m(j+1) = m(j) + (km1+km2)*dt/2;
    h(j+1) = h(j) + (kh1+kh2)*dt/2;
    n(j+1) = n(j) + (kn1+kn2)*dt/2;
end



%Find the spiking frequency
spikethreshold = 0;
[spikeamp, idx] = findpeaks(V); xx = find(spikeamp > spikethreshold); 
    spikeamp = spikeamp(xx); 
    idx = idx(xx);
ifreq = diff(t(idx));
ifreq = 1000 ./ifreq;


figure
hold on
ax(1) = subplot(2,1,1); 
    plot(t,V,'r','linewidth',2); % Plot the voltage trace
    hold on; plot(t(idx), V(idx), 'g*'); % Marks spikes with stars
    axis([0 T -110 20]);
    set(gca,'fontsize',20);
    xlabel('t')
    ylabel('V');
    title('Q1a Io=4');
    
    ax(2) = subplot(212);
    plot(t(idx(1:end-1)), ifreq, 'b*'); ylim([0 100]);
    xlabel('t'); ylabel('Frequency')
    linkaxes(ax, 'x');
    xlim([0 4000]);
    
