function [err, cp_numerical, cp_exact] = getOptimalNumPanels(numPanels)
    % Hess-Smith Panelverfahren für Kreiszylinder
    % Input: numPanels - Anzahl der Panels
    % Output: err - mittlerer Fehler
    %         cp_numerical - numerische Druckbeiwerte
    %         cp_exact - exakte Druckbeiwerte
    
    % Erzeuge Zylinder
    WriteCylinder(numPanels);
    
    % Berechne Panel-Parameter
    WriteXYLTheta("cylinder.txt");
    
    % Berechne Systemmatrix
    M = computeMFromXYLTheta("XYLTheta.txt");
    
    % Strömungsparameter
    vInf = 1;     % Anströmgeschwindigkeit
    alpha = 0;    % Anstellwinkel
    
    % Löse für Quellstärken
    [q, ql] = computeQFromM(M, vInf, alpha);
    
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
    
    % Berechne Tangentialgeschwindigkeiten
    Mt = computeMTFromXYLTheta("XYLTheta.txt");
    sizeMt = size(Mt);
    sizeQ = size(q);
    
    v = zeros(sizeMt(1), 1);
    cp_numerical = zeros(sizeMt(1), 1);
    cp_exact = zeros(sizeMt(1), 1);
    
    for i = 1:sizeMt(1)
        % Tangentialgeschwindigkeit
        for j = 1:sizeQ(1)
            v(i) = v(i) + Mt(i, j)*q(j);
        end
        v(i) = v(i) + vInf*cos(alpha - data(i, 4));
        
        % Numerischer Druckbeiwert
        cp_numerical(i) = 1 - (v(i)/vInf)^2;
        
        % Exakter Druckbeiwert für Kreiszylinder
        % cp = 1 - 4*sin^2(phi) für Zylinder
        phi = atan2(data(i, 2), data(i, 1) - 0.5);  % Winkel vom Mittelpunkt
        cp_exact(i) = 1 - 4*sin(phi)^2;
    end
    
    % Fehlerberechnung
    err = mean(abs(cp_numerical - cp_exact));
    
    % Ausgabe
    fprintf('Anzahl Panels: %d\n', numPanels);
    fprintf('Mittlerer Fehler: %.6e\n', err);
    fprintf('Summe q*l: %.6e (sollte ≈ 0 sein)\n', sum(ql));
    
    % Speichere Ergebnisse
    fileID = fopen('cps.txt','w');
    for i = 1:sizeMt(1)
        fprintf(fileID,'%.15e %.15e\n', cp_numerical(i), cp_exact(i));
    end
    fclose(fileID);
    
    % Vergleich mit Referenzwerten (Stefan Braun)
    if numPanels == 8
        fprintf('\nVergleich mit Referenzwerten (8 Panels):\n');
        fprintf('i\tq_num\tq_ref\tv_num\tv_ref\tcp_num\tcp_ref\n');
        q_ref = [-2.19; -0.91; 0.91; 2.19; 2.19; 0.91; -0.91; -2.19];
        v_ref = [-0.77; -1.85; -1.85; -0.77; 0.77; 1.85; 1.85; 0.77];
        cp_ref = [0.41; -2.41; -2.41; 0.41; 0.41; -2.41; -2.41; 0.41];
        
        for i = 1:8
            fprintf('%d\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n', ...
                    i-1, q(i), q_ref(i), v(i), v_ref(i), ...
                    cp_numerical(i), cp_ref(i));
        end
    end
    
    % Plot
    if numPanels <= 32
        figure;
        phi_plot = atan2(data(:, 2), data(:, 1) - 0.5) * 180/pi;
        plot(phi_plot, cp_numerical, 'o-', 'Color', [1, 0.5, 0], ...
             'LineWidth', 1.5, 'MarkerSize', 8, 'DisplayName', 'Numerisch');
        hold on;
        plot(phi_plot, cp_exact, '-', 'Color', [0.5, 0, 0.5], ...
             'LineWidth', 2, 'DisplayName', 'Exakt');
        xlabel('\phi [°]');
        ylabel('c_p');
        title(sprintf('Druckbeiwert - %d Panels', numPanels));
        legend('Location', 'South');
        grid on;
    end
end

