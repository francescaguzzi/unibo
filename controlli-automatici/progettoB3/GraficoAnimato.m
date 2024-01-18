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

% condizioni iniziali dello stato del sistema (numero di cellule suscettibili e resistenti)
x1 = 100;
x2 = 400;

% tempo iniziale (t0) e finale (tf) per la risoluzione delle equazioni differenziali
% e condizioni iniziali del sistema (x0)
x0 = [x1, x2];
t0 = 0;
tf = 5; % tempo di rappresentazione

% utilizzo della funzione ode45 per risolvere le equazioni differenziali descritte dalla funzione fun.
[t,x] = ode45(@(t,x) fun(t,x), [t0, tf], x0);

% grafico che visualizza il numero di cellule suscettibili e resistenti nel tempo
figure
s1 = scatter(t(1),x(1,1),'c','filled');
hold on
s2 = scatter(t(1),x(1,2),'b','filled');
xlabel('Tempo');
ylabel('Numero di cellule');
legend([s1,s2],{'Cellule suscettibili','Cellule resistenti'});

% ciclo for per aggiornare continuamente il grafico nel tempo
for i=5:length(t)
s1.XData = t(1:i);
s1.YData = x(1:i,1);
s2.XData = t(1:i);
s2.YData = x(1:i,2);
drawnow;
end

% funzione in cui vengono definiti i parametri dati, e implementate le
% equazioni differenziali
function dxdt = fun(t,x)
rs = 1.7; % tassi di riproduzione delle cellule suscettibili
rr = 1.4; % e resistenti
K = 500; % numero massimo di cellule
ms = 0.95; % mortalità delle cellule suscettibili
mr = 0.05; % e resistenti
cf = 20; % concentrazione del farmaco

% costanti
gamma = 0.2;
beta = 0.8;
alfa = 0.5;

dxdt = [-rs*log((x(1) + x(2))/K)*x(1) - ms*cf*x(1) - beta*x(1) + gamma*x(2) - alfa*cf*x(1);
-rr*log((x(1) + x(2))/K)*x(2) - mr*cf*x(2) + beta*x(1) - gamma*x(2) + alfa*cf*x(1)];

end   