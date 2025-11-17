function [] = WriteCylinder(numPanels)
    % Schreibt Zylinder-Koordinaten in Datei
    % numPanels: Anzahl der Panels
    
    fileID = fopen('cylinder.txt','w');
    
    % Erzeuge Punkte im Gegenuhrzeigersinn
    theta = linspace(0, 2*pi, numPanels+1);
    theta = theta(1:end-1);  % Letzter Punkt = erster Punkt
    
    radius = 0.5;
    x = radius * cos(theta) + 0.5;  % Verschiebung um 0.5 nach rechts
    y = radius * sin(theta);
    
    % Schreibe Punkte
    for i = 1:numPanels
        fprintf(fileID,'%.15e %.15e\n', x(i), y(i));
    end
    
    fclose(fileID);
end
