function [] = getQGammaCylinder(panels)
    numPanels = panels;
    t = 1; % Profiltiefe
    
    % Erzeuge Zylinder und berechne Panel-Parameter
    WriteCylinder(numPanels);
    WriteXYLTheta("cylinder.txt");
    
    % Berechne Matrizen fuer Wirbelbelegung
    % M ist fuer Normalgeschwindigkeiten
    M = computeMFromXYLTheta("XYLTheta.txt");
    
    % Mt ist fuer Tangentialgeschwindigkeiten  
    Mt = computeMTFromXYLTheta("XYLTheta.txt");
    
    vInf = 1;
    alpha = 0;
    
    % Erweitere System fuer Wirbelbelegung
    [MExp, bExp] = expandM(Mt, M, vInf, alpha);
    sizeMExp = size(MExp);
    
    % Loese erweitertes System (q1...qn, Gamma)
    q = computeQFromMExp(MExp, bExp);
    
    % Lade Panel-Daten
    filename = "XYLTheta.txt";
    fid = fopen(filename, 'r');
    if fid == -1
        error(['Error: Could not open file ' filename]);
    end
    
    numLines = 0;
    tline = fgetl(fid);
    while ischar(tline)
        numLines = numLines + 1;
        tline = fgetl(fid);
    end
    
    fclose(fid);
    fid = fopen(filename, 'r');
    
    data = zeros(numLines, 4);
    i = 1;
    while i <= numLines
        data(i, :) = fscanf(fid, '%e %e %e %e', [1 4]);
        i = i + 1;
    end
    fclose(fid);
    
    sizeMt = size(Mt);
    sizeQ = size(q);
    
    % Berechne Geschwindigkeiten
    v = zeros(sizeMt(1), 1);
    
    for i = 1:sizeMt(1)
        % Tangentialgeschwindigkeit von Quellen und Wirbel
        for j = 1:sizeMt(1)
            % Beitrag der Quelle j zur Tangentialgeschwindigkeit bei i
            v(i) = v(i) + Mt(i,j) * q(j);
        end
        
        % Beitrag der konstanten Wirbelbelegung Gamma (letztes Element von q)
        % Die Wirbelbelegung traegt zur Tangentialgeschwindigkeit bei
        % WICHTIG: Verwende Mt, nicht M!
        if sizeQ(1) > sizeMt(1)
            % Fuer konstante Wirbelbelegung auf allen Panels
            for j = 1:sizeMt(1)
                % Der Einfluss eines Wirbels ist wie eine Quelle um 90 Grad gedreht
                % Also verwenden wir die Normalgeschwindigkeitsmatrix M
                % mit negativem Vorzeichen fuer die Tangentialgeschwindigkeit
                v(i) = v(i) - M(i,j) * q(sizeQ(1));
            end
        end
        
        % Anstroemgeschwindigkeit
        v(i) = v(i) + vInf * cos(alpha - data(i, 4));
    end
    
    % Berechne Druckbeiwerte
    cp = zeros(sizeMt(1), 1);
    for i = 1:sizeMt(1)
        cp(i) = 1 - (v(i)/vInf)^2;
    end
    
    % Ausgabe
    fprintf('Zylinder mit %d Panels und Wirbelbelegung:\n', numPanels);
    fprintf('Gamma = %.6f\n', q(end));
    fprintf('cp Bereich: [%.2f, %.2f]\n', min(cp), max(cp));
    
    % Fuer Zylinder sollte Gamma ~ 0 sein (kein Auftrieb)
    if abs(q(end)) < 1e-6
        fprintf('OK: Gamma ~ 0 (kein Auftrieb beim Zylinder)\n');
    else
        fprintf('WARNUNG: Gamma = %.6f (sollte ~ 0 sein)\n', q(end));
    end
    
    % Speichere Ergebnisse
    fileID = fopen('cpscas.txt','w');
    for i = 1:sizeMt(1)
        fprintf(fileID,'%.15e\n', cp(i));
    end
    fclose(fileID);
    
    % Pruefe auf unrealistische Werte
    if max(abs(cp)) > 10
        fprintf('WARNUNG: Unrealistische cp-Werte detektiert!\n');
        fprintf('Ueberpruefe die Matrizen-Berechnung.\n');
    end
end
