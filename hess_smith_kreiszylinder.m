function hess_smith_kreiszylinder(N)
% Hess-Smith Panelverfahren für einen Kreiszylinder mit Skalierung und Gewichtung

% Parameter
R = 1; % Radius des Kreiszylinders
V_inf = 1; % Anströmgeschwindigkeit
alpha = 0; % Anstellwinkel
N = 8; % Anzahl der Panels

% Geometrie
theta = linspace(0, 2*pi, N+1);
theta = theta(1:end-1);
x = R*cos(theta);
y = R*sin(theta);
dx = diff([x,x(1)]);
dy = diff([y,y(1)]);
dl = sqrt(dx.^2 + dy.^2);

% Einflussmatrix
M = zeros(N);
for i = 1:N
    for j = 1:N
        xi = x(i); yi = y(i);
        xj = x(j); yj = y(j);
        rij = sqrt((xi-xj)^2 + (yi-yj)^2);
        M(i,j) = (1/(2*pi))*(log(rij) + (xi-xj)*dx(j)/rij^2 + (yi-yj)*dy(j)/rij^2);
    end
end

% Skalierung der Matrix M
for i = 1:N
    M(i,:) = M(i,:) / dl(i);
end

% Inhomogenitäten (mit Gewichtung)
b = -V_inf*sin(alpha-theta)' .* dl';

% Lösung des Gleichungssystems
q = M\b;

% Tangentiale Geschwindigkeiten und Druckbeiwerte
vt = zeros(N,1);
for i = 1:N
    sum = 0;
    for j = 1:N
        xi = x(i); yi = y(i);
        xj = x(j); yj = y(j);
        rij = sqrt((xi-xj)^2 + (yi-yj)^2);
        sum = sum + q(j)*(dy(j)*(xi-xj) - dx(j)*(yi-yj))/(2*pi*rij^2);
    end
    vt(i) = V_inf*cos(alpha-theta(i)) + sum;
end
cp = 1 - (vt/V_inf).^2;

% Darstellung der Ergebnisse
figure;
plot(theta, cp);
xlabel('Winkel theta');
ylabel('Druckbeiwert cp');
title('Druckverteilung am Kreiszylinder');
end
