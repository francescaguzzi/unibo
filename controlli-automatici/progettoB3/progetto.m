%% Progetto di Controlli Automatici T 
% Traccia B3
% Controllo trattamento farmacologico contro il cancro
% Gruppo H

% Autori: 
% Damiano Cavazzana
% Alberto Florian 
% Francesca Guzzi
% Nicolò Mascella

clear all; close all; clc;

%% Definizione dei parametri del progetto

syms x1 x2 cf;

rs = 1.7;  % tassi di riproduzione delle cellule suscettibili
rr = 1.4;  % e resistenti
K = 500;   % numero massimo di cellule
ms = 0.95; % mortalità delle cellule suscettibili
mr = 0.05; % e resistenti

% costanti
gamma = 0.2;
beta = 0.8;
alfa = 0.5;

% Sistema non lineare
f1 = -rs*log((x1 + x2)/K)*x1 - ms*cf*x1 - beta*x1 + gamma*x2 - alfa*cf*x1;
f2 = -rr*log((x1 + x2)/K)*x2 - ms*cf*x2 + beta*x1 - gamma*x2 + alfa*cf*x1;
u = cf; % ingresso
y = x2; % uscita 

%% Calcolo coppia di equilibrio

x1_e = 100; % posizioni di equilibrio
x2_e = 400;

%% Sistema linearizzato
% x = A*x + B*u
% y = C*x + D*u

% Definiamo le matrici nel punto di equilibrio 
A = [-rs*(x1_e/K)-beta, -rs*(x1_e/K)+gamma;
     -rr*(x2_e/K)+beta, -rr*(x2_e/K)-gamma];
B = [-ms*x1_e-alfa*x1_e;
     -mr*x2_e+alfa*x2_e];
C = [0,1];
D = 0;

%% Punto 2: funzione di trasferimento
s = tf('s');
sys = ss(A,B,C,D);
G = tf(sys);

G_poli = pole(G);
G_zeri = zero(G);

%% Diagramma di Bode di G(s)

omega_plot_min = 10e-6; % margini necessari solo per il plot
omega_plot_max = 10e6;

figure(1);
bode(G, {omega_plot_min, omega_plot_max});
grid on; zoom on;

if 0
    return;
end

%% Punto 3: sintesi del regolatore

% Specifiche:
% 1. Errore a regime nullo con riferimento a gradino
% 2. Margine di fase >= 45°
% 3. Sovraelongazione percentuale al massimo del 10% 
% 4. Tempo di assestamento al 5% deve essere inferiore a T=0.2
% 5. Disturbo sull'uscita d(t) con banda in [0,0.1] 
%    abbattuto di almeno 45dB
% 6. Rumore di misura n(t) con banda in [5*10^3,5*10^6]
%    abbattuto di almeno 45dB


%% Regolatore statico
% Per soddisfare la precisione statica e attenuazioni del disturbo d

% Specifica 1: precisione statica
% Per avere errore a regime nullo progettiamo il regolatore 
% Rs(s) = 1/s 
mu_s = 0.5;
R_s = mu_s / s;

% calcolo G estesa
G_e = R_s * G;

% Specifica 5: attenuazione del disturbo sull'uscita d(t)

A_d = 45;  % attenuazione d(t)
omega_d_max = 0.1;
omega_d_min = 1e-5;

% coordinate
Bnd_d_x = [omega_d_min; omega_d_max; omega_d_max; omega_d_min];
Bnd_d_y = [A_d; A_d; -100; -100];

% graficare la zona proibita per d(t)
figure(2); hold on; 
patch(Bnd_d_x, Bnd_d_y, 'r', 'FaceAlpha', 0.2, 'EdgeAlpha', 0);

if 0
    legend("d(t)");
    bode(G, {omega_plot_min, omega_plot_max});
    grid on; 
    return;
end

%% Specifiche del regolatore dinamico

% Specifica 6: attenuazione del rumore di misura n(t)
A_n = -80; % attenuazione n(t)
omega_n_max = 5*1e6;
omega_n_min = 5*1e3;

% coordinate
Bnd_n_x = [omega_n_min; omega_n_max; omega_n_max; omega_n_min];
Bnd_n_y = [A_n; A_n; 100; 100];

% graficare la zona proibita per n(t)
patch(Bnd_n_x, Bnd_n_y, 'r', 'FaceAlpha', 0.2, 'EdgeAlpha', 0);

if 0
    legend("n(t)"); hold on;
    bode(G, {omega_plot_min, omega_plot_max});
    grid on; 
    return;
end

% Precisione dinamica 
% Specifiche 3 e 4: sovraelongazione e tempo di assestamento

S_100_spec = 0.10;
T_a1_spec = 0.2;

% calcolo xi e Mf ottimale
logsq = (log(S_100_spec))^2;
xi = sqrt(logsq/(pi^2+logsq));
Mf_spec = xi * 100;

% mappatura specifiche tempo d'assestamento (minima pulsazione di taglio)
omega_Ta_min = 1e-4; % lower bound per il plot
omega_Ta_MAX = 460 /(Mf_spec*T_a1_spec);

Bnd_Ta_x = [omega_Ta_min; omega_Ta_MAX; omega_Ta_MAX; omega_Ta_min];
Bnd_Ta_y = [0; 0; -100; -100];
patch(Bnd_Ta_x, Bnd_Ta_y,'b','FaceAlpha',0.2,'EdgeAlpha',0);

if 0
    legend("T_{a,\epsilon}"); grid on;
    bode(G,{omega_plot_min, omega_plot_max});
    return;
end

% legenda 
leg_amp = ["A_d", "A_n", "\omega_{c,min}", "G(j\omega)"];
legend(leg_amp);

hold on;
bode(G_e, {omega_plot_min, omega_plot_max});
grid on, zoom on; 


% mappatura specifiche sovraelongazione
omega_c_min = omega_Ta_MAX;
omega_c_MAX = omega_n_min;

phi_spec = Mf_spec - 180;
phi_low = -270; % lower bound per il plot

Bnd_Mf_x = [omega_c_min; omega_c_MAX; omega_c_MAX; omega_c_min];
Bnd_Mf_y = [phi_spec; phi_spec; phi_low; phi_low];
patch(Bnd_Mf_x, Bnd_Mf_y, 'g', 'FaceAlpha', 0.2, 'EdgeAlpha', 0);

% Legenda colori
leg_arg = ["G(j\omega)"; "M_f"];
legend(leg_arg);

% Stop qui per il regolatore statico con specifiche mappate
if 0
    return;
end

%% Design del regolatore dinamico

% Margine di fase minimo da speciica 2: Mf >= 45°
% Margine di fase minimo da specifica sulla sovraelongazione: 59°

Mf_star = Mf_spec + 8;
omega_c_star = 60; % deve essere maggiore di omega_c_min = 38.9

% rete anticipatrice
[mag_omega_c_star, arg_omega_c_star, ~] = bode(G_e, omega_c_star);
mag_omega_c_star_db = 20 * log10(mag_omega_c_star);

M_star = 10^(-mag_omega_c_star_db/20);
phi_star = Mf_star - 180 - arg_omega_c_star;

% formule di inversione
alpha_tau = (cos(phi_star*pi/180) - 1/M_star)/(omega_c_star*sin(phi_star*pi/180));
tau = (M_star - cos(phi_star*pi/180))/(omega_c_star*sin(phi_star*pi/180));
alpha = alpha_tau / tau;

if M_star <= 1
    disp('Errore: M_star non soddisfa la specifica (M_star > 1)')
    return;
end


check_flag = min(tau, alpha_tau);
if check_flag < 0
    disp('Errore: polo/zero positivo');
    return;
end

%% Diagrammi di Bode con specifiche includendo il regolatore dinamico

% aggiungiamo due poli ad alte frequenze
% per far si che il grafico rispetti le specifiche

P1 = 1/10e2;
P2 = 1/10e7;

R_a = (1 + tau*s)/(1 + alpha_tau*s); % rete anticipatrice
R_d = R_a / (1 + P1 * s) / (1 + P2 * s);

LL = R_d * G_e;

% controllo se il regolatore è fisicamente realizzabile
% poli e zeri >= 0
check_reg = R_d * R_s;
if size(pole(check_reg)) - size(zero(check_reg)) < 0
    fprintf('Il regolatore NON è fisicamente realizzabile!');
    return;
else
    fprintf('Il regolatore è fisicamente realizzabile!');
end

figure(3);
hold on;

% Specifiche su ampiezza
patch(Bnd_d_x, Bnd_d_y,'r','FaceAlpha',0.2,'EdgeAlpha',0);
patch(Bnd_n_x, Bnd_n_y,'r','FaceAlpha',0.2,'EdgeAlpha',0);
patch(Bnd_Ta_x, Bnd_Ta_y,'b','FaceAlpha',0.2,'EdgeAlpha',0);

% Plot Bode con margini di stabilità
margin(LL, {omega_plot_min, omega_plot_max});
grid on;

% Specifiche su fase
patch(Bnd_Mf_x, Bnd_Mf_y,'g','FaceAlpha',0.2,'EdgeAlpha',0);
hold on;

% Stop qui per sistema con R_d + specifiche
if 0
    return;
end


%% Punto 4: test del sistema di controllo sul sistema linearizzato
% w(t) = -3 * 1(t)

% Funzione di sensitività
SS = 1 / (1 + LL);
% Funzione di sensitività complementare
FF = LL / (1 + LL);
FF = tf(minreal(FF));

if 0
    figure(4);
    legend('S(s)','F(s)'); hold on;
    bode(SS, {omega_plot_min, omega_plot_max});
    bode(FF, {omega_plot_min, omega_plot_max});
    grid on;
    return;
end

tt = (0:1e-4:1e3);

figure(4);

WW = -3;
T_sim = 0.5;
[y_step, t_step] = step(WW * FF, T_sim);
S_FF = stepinfo(FF, 'SettlingTimeThreshold', 0.2);
st_FF = S_FF.SettlingTime;

plot(t_step, y_step, 'b');
grid on; hold on;

% vincolo sovraelongazione <= 10%
patch([0, T_sim, T_sim, 0], [WW * (1 + S_100_spec), WW * (1 + S_100_spec), WW - 1, WW - 1], 'r', 'FaceAlpha', 0.3, 'EdgeAlpha', 0.5);
ylim([WW + 1, 0]);

% vincolo tempo di assestamento al 5%
LV = evalfr(WW * FF, 0);
patch([T_a1_spec, T_sim, T_sim, T_a1_spec], [LV * (1 - 0.01), LV * (1 - 0.01), 0, 0], 'g', 'FaceAlpha', 0.1, 'EdgeAlpha', 0.5);
patch([T_a1_spec, T_sim, T_sim, T_a1_spec], [LV * (1 + 0.01), LV * (1 + 0.01), LV - 1, LV - 1], 'g', 'FaceAlpha', 0.1, 'EdgeAlpha', 0.1);

Legend_step = ["Risposta al gradino"; "Vincolo sovraelongazione"; "Vincolo tempo di assestamento"];
legend(Legend_step);

if 0
    return;
end

%% Controllo sul disturbo in uscita
% d(t) = sum_{k = 1}^{4} 0.2 * sin(0.025kt)

figure(5);
omega_d = 0.025;
syms k

DD = 0.2;
dd = 0;

for k = 1:4 
    dd = dd + DD * sin(omega_d * tt * k);
end

y_d = lsim(SS, dd, tt);
hold on; grid on; zoom on;

plot(tt, dd, 'm');
plot(tt, y_d, 'b');

grid on;
legend('dd','y_d');

%% Controllo sul disturbo di misura
% n(t) = sum_{k=1}^{4} 0.1 * sin(5*10^3kt)

figure(6);

omega_n = 5 * 1e3;
syms k

NN = 0.1;
nn = 0;

for k = 1:4
    nn = nn + NN * sin(omega_n * tt * k);
end

y_n = lsim(-FF, nn, tt);
hold on; grid on; zoom on;

plot(tt, nn, 'm');
plot(tt, y_n, 'b');
grid on;

legend('nn', 'y_n');

if 0
    figure(8);
    bode(-FF, {omega_plot_min, omega_plot_max});
    grid on;
    return;
end

%% Test uscita totale
y_step = step(WW * FF, tt);
figure(8);
y_tot = y_d + y_n + y_step;
plot(tt, y_tot);
