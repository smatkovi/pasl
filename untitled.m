clc; clear; close all;

%% Funktionale Implementierung des Source-Panel-Verfahrens

% Hauptprogramm
R = 0.5;                  % Radius des Zylinders [m]
V_inf = 1;               % Anströmgeschwindigkeit [m/s]
alpha = 0;               % Anstellwinkel [Grad]
n = 8;                   % Anzahl der Panels

[x, y, x_mid, y_mid, theta_panel, lengths] = define_geometry(R, n);
M = compute_system_matrix(x_mid, y_mid, theta_panel, lengths, n);
b = compute_rhs(theta_panel, V_inf, alpha, n);

q = solve_linear_system(M, b);

[v_t, c_p] = compute_velocity_and_cp(x_mid, y_mid, theta_panel, lengths, q, V_inf, alpha, n);

% Ausgabe der Ergebnisse
results = table((0:n-1)', q, v_t, c_p, 'VariableNames', {'i', 'q_i', 'v_t', 'c_p'});
disp(results);

disp('Systemmatrix M:');
disp(M);

%% Funktionen

function [x, y, x_mid, y_mid, theta_panel, lengths] = define_geometry(R, n)
    % Definiert die Geometrie des Kreiszylinders und berechnet Panel-Eigenschaften
    dtheta = 2 * pi / n;     % Winkel zwischen den Panels [rad]
    theta = linspace(0, 2*pi - dtheta, n); % Mittelpunkte der Panels

    % Panel-Endpunkte
    x = R * cos(theta + dtheta / 2); 
    y = R * sin(theta + dtheta / 2);

    % Panel-Mittelpunkte
    x_mid = R * cos(theta);
    y_mid = R * sin(theta);

    % Panel-Neigungswinkel und Länge
    dx = -R * sin(theta + dtheta / 2) + R * sin(theta - dtheta / 2);
    dy =  R * cos(theta + dtheta / 2) - R * cos(theta - dtheta / 2);
    lengths = sqrt(dx.^2 + dy.^2); % Panel-Längen
    theta_panel = atan2(dy, dx);   % Neigungswinkel der Panels
end

function M = compute_system_matrix(x_mid, y_mid, theta_panel, lengths, n)
    % Berechnet die Systemmatrix M
    M = zeros(n, n);

    for i = 1:n
        for j = 1:n
            if i ~= j
                % Relativkoordinaten
                xi = x_mid(i) - x_mid(j);
                yi = y_mid(i) - y_mid(j);

                % Transformation in lokale Koordinaten
                xi_local = xi * cos(theta_panel(j)) + yi * sin(theta_panel(j));
                eta_local = -xi * sin(theta_panel(j)) + yi * cos(theta_panel(j));

                % Berechnung von I und J
                I = (1 / (4 * pi)) * log(((lengths(j) + 2*xi_local)^2 + 4*eta_local^2) / ((lengths(j) - 2*xi_local)^2 + 4*eta_local^2));
                J = (1 / (2 * pi)) * (atan((lengths(j) - 2*xi_local) / (2*eta_local)) + atan((lengths(j) + 2*xi_local) / (2*eta_local)));

                % Matrixelement M(i,j)
                M(i,j) = -sin(theta_panel(i) - theta_panel(j)) * I + cos(theta_panel(i) - theta_panel(j)) * J;
            else
                % Diagonalelemente
                M(i,j) = 0.5;
            end
        end
    end
end

function b = compute_rhs(theta_panel, V_inf, alpha, n)
    % Berechnet die rechte Seite des Gleichungssystems
    b = zeros(n, 1);
    for i = 1:n
        b(i) = -V_inf * cos(theta_panel(i) - deg2rad(alpha));
    end
end

function q = solve_linear_system(M, b)
    % Löse das Gleichungssystem
    q = M \ b;
end

function [v_t, c_p] = compute_velocity_and_cp(x_mid, y_mid, theta_panel, lengths, q, V_inf, alpha, n)
    % Berechnet die Tangentialgeschwindigkeiten und den Druckkoeffizienten
    v_t = zeros(n, 1);
    c_p = zeros(n, 1);

    for i = 1:n
        for j = 1:n
            if i ~= j
                % Relativkoordinaten
                xi = x_mid(i) - x_mid(j);
                yi = y_mid(i) - y_mid(j);

                % Transformation in lokale Koordinaten
                xi_local = xi * cos(theta_panel(j)) + yi * sin(theta_panel(j));
                eta_local = -xi * sin(theta_panel(j)) + yi * cos(theta_panel(j));

                % Berechnung von I und J
                I = (1 / (4 * pi)) * log(((lengths(j) + 2*xi_local)^2 + 4*eta_local^2) / ((lengths(j) - 2*xi_local)^2 + 4*eta_local^2));
                J = (1 / (2 * pi)) * (atan((lengths(j) - 2*xi_local) / (2*eta_local)) + atan((lengths(j) + 2*xi_local) / (2*eta_local)));

                % Berechnung von A_t(i,j)
                A_t = cos(theta_panel(i) - theta_panel(j)) * I + sin(theta_panel(i) - theta_panel(j)) * J;

                % Tangentialgeschwindigkeit
                v_t(i) = v_t(i) + A_t * q(j);
            end
        end

        % Hinzufügen der Anströmgeschwindigkeit
        v_t(i) = v_t(i) + V_inf * cos(theta_panel(i) - deg2rad(alpha));

        % Druckkoeffizient
        c_p(i) = 1 - (v_t(i) / V_inf)^2;
    end
end
