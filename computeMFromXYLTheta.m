function [M] = computeMFromXYLTheta(filename)
    % Berechnet die Systemmatrix M fuer das Hess-Smith Panelverfahren
    % Input: filename - Datei mit X, Y, L, Theta Werten
    % Output: M - Systemmatrix fuer Normalgeschwindigkeiten
    
    % Datei einlesen
    fid = fopen(filename, 'r');
    if fid == -1
        error(['Error: Could not open file ' filename]);
    end
    
    % Anzahl der Zeilen zaehlen
    numLines = 0;
    tline = fgetl(fid);
    while ischar(tline)
        numLines = numLines + 1;
        tline = fgetl(fid);
    end
    
    % Datei neu oeffnen
    fclose(fid);
    fid = fopen(filename, 'r');
    
    % Daten einlesen: X, Y, L, Theta
    data = zeros(numLines, 4);
    for i = 1:numLines
        data(i, :) = fscanf(fid, '%e %e %e %e', [1 4]);
    end
    fclose(fid);
    
    % Matrizen initialisieren
    xi = zeros(numLines, numLines);
    eta = zeros(numLines, numLines);
    I = zeros(numLines, numLines);
    J = zeros(numLines, numLines);
    M = zeros(numLines, numLines);
    
    % Berechnung der Matrixelemente
    for i = 1:numLines
        for j = 1:numLines
            % Lokale Koordinaten
            xi(i,j) = (data(i,1) - data(j,1)) * cos(data(j,4)) + ...
                      (data(i,2) - data(j,2)) * sin(data(j,4));
            eta(i,j) = -(data(i,1) - data(j,1)) * sin(data(j,4)) + ...
                        (data(i,2) - data(j,2)) * cos(data(j,4));
            
            if i == j
                % Diagonalelemente
                I(i,j) = 0;
                J(i,j) = 0.5;
            else
                % I-Integral (logarithmisch)
                numerator = (data(j,3) + 2*xi(i,j))^2 + 4*eta(i,j)^2;
                denominator = (data(j,3) - 2*xi(i,j))^2 + 4*eta(i,j)^2;
                
                % Singularitaetsbehandlung
                if abs(numerator) < 1e-12 || abs(denominator) < 1e-12
                    I(i,j) = 0;
                else
                    I(i,j) = log(numerator/denominator) / (4*pi);
                end
                
                % J-Integral mit atan2 fuer korrekte Quadranten
                if abs(eta(i,j)) < 1e-12
                    % Sonderfall: eta ~ 0
                    if abs(xi(i,j)) < data(j,3)/2
                        J(i,j) = 0.5;
                    else
                        J(i,j) = 0;
                    end
                else
                    % Normale Berechnung mit atan2
                    % WICHTIG: atan2(y, x) nicht atan2(x, y)!
                    angle1 = atan2(2*eta(i,j), data(j,3) - 2*xi(i,j));
                    angle2 = atan2(2*eta(i,j), data(j,3) + 2*xi(i,j));
                    
                    % Winkeldifferenz berechnen
                    dangle = angle2 - angle1;
                    
                    % Auf [-pi, pi] normalisieren
                    while dangle > pi
                        dangle = dangle - 2*pi;
                    end
                    while dangle < -pi
                        dangle = dangle + 2*pi;
                    end
                    
                    J(i,j) = dangle / (2*pi);
                end
            end
            
            % Systemmatrix-Element
            M(i,j) = -sin(data(i,4) - data(j,4)) * I(i,j) + ...
                      cos(data(i,4) - data(j,4)) * J(i,j);
        end
    end
end
