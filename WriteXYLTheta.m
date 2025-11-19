function [t] = WriteXYLTheta(filename)
    % Berechnet Panel-Parameter X, Y, L, Theta aus Profildaten
    % Input: filename - Profildatei
    % Output: t - Profiltiefe
    % Schreibt XYLTheta.txt mit Panel-Mittelpunkten und Parametern
    
    % Profildaten einlesen
    fid = fopen(filename, 'r');
    if fid == -1
        error(['Error: Could not open file ' filename]);
    end
    
    % Anzahl der Punkte zaehlen
    numPoints = 0;
    tline = fgetl(fid);
    while ischar(tline)
        numPoints = numPoints + 1;
        tline = fgetl(fid);
    end
    
    % Datei neu oeffnen und Daten einlesen
    fclose(fid);
    fid = fopen(filename, 'r');
    
    points = zeros(numPoints, 2);
    for i = 1:numPoints
        points(i, :) = fscanf(fid, '%e %e', [1 2]);
    end
    fclose(fid);
    
    % Pruefen ob erster und letzter Punkt identisch sind
    % (geschlossenes Profil)
    tolerance = 1e-10;
    if norm(points(1,:) - points(end,:)) < tolerance
        % Letzten Punkt entfernen wenn identisch mit erstem
        points = points(1:end-1, :);
        numPoints = numPoints - 1;
    end
    
    % Anzahl der Panels
    numPanels = numPoints;
    
    % Arrays fuer Panel-Parameter
    X = zeros(numPanels, 1);
    Y = zeros(numPanels, 1);
    L = zeros(numPanels, 1);
    theta = zeros(numPanels, 1);
    
    % Panel-Parameter berechnen
    for i = 1:numPanels
        % Indizes fuer Panelendpunkte
        i1 = i;
        i2 = mod(i, numPanels) + 1;  % Zyklisch
        
        % Panel-Mittelpunkt
        X(i) = (points(i1, 1) + points(i2, 1)) / 2;
        Y(i) = (points(i1, 2) + points(i2, 2)) / 2;
        
        % Panel-Laenge
        dx = points(i2, 1) - points(i1, 1);
        dy = points(i2, 2) - points(i1, 2);
        L(i) = sqrt(dx^2 + dy^2);
        
        % Panel-Neigungswinkel (mit atan2 fuer korrekte Quadranten)
        theta(i) = atan2(dy, dx);
    end
    
    % Profiltiefe berechnen (max x - min x)
    t = max(points(:, 1)) - min(points(:, 1));
    
    % In Datei schreiben
    fileID = fopen('XYLTheta.txt', 'w');
    for i = 1:numPanels
        fprintf(fileID, '%.15e %.15e %.15e %.15e\n', X(i), Y(i), L(i), theta(i));
    end
    fclose(fileID);
    
    fprintf('Panel-Parameter geschrieben: %d Panels\n', numPanels);
    fprintf('Profiltiefe: %.6f\n', t);
end
