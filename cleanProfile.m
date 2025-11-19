function cleanProfile(inputFile, outputFile)
    % Bereinigt Profildaten von häufigen Problemen
    % Input: inputFile - Eingabe-Profildatei
    %        outputFile - Bereinigte Ausgabedatei
    
    if nargin < 2
        [~, name, ~] = fileparts(inputFile);
        outputFile = sprintf('%s_clean.dat', name);
    end
    
    fprintf('\nBereinige Profil: %s\n', inputFile);
    fprintf('=====================================\n');
    
    % Lade Profildaten
    profile = load(inputFile);
    [n, ~] = size(profile);
    x = profile(:,1);
    y = profile(:,2);
    
    fprintf('Original: %d Punkte\n', n);
    
    % 1. Entferne doppelte Punkte
    tolerance = 1e-8;
    keep = true(n, 1);
    
    for i = 2:n
        if norm(profile(i,:) - profile(i-1,:)) < tolerance
            keep(i) = false;
            fprintf('  Entferne doppelten Punkt %d\n', i);
        end
    end
    
    % Prüfe auch ersten und letzten Punkt
    if n > 1 && norm(profile(1,:) - profile(end,:)) < tolerance
        keep(end) = false;
        fprintf('  Entferne letzten Punkt (identisch mit erstem)\n');
    end
    
    profile = profile(keep, :);
    x = profile(:,1);
    y = profile(:,2);
    n = size(profile, 1);
    
    % 2. Stelle sicher, dass Punkte im Gegenuhrzeigersinn sind
    area = 0;
    for i = 1:n-1
        area = area + x(i)*y(i+1) - x(i+1)*y(i);
    end
    area = area + x(n)*y(1) - x(1)*y(n);
    area = area / 2;
    
    if area < 0
        fprintf('  Kehre Reihenfolge um (war im Uhrzeigersinn)\n');
        profile = flipud(profile);
        x = profile(:,1);
        y = profile(:,2);
    end
    
    % 3. Sortiere Punkte für bessere Panel-Verteilung
    % Finde Vorder- und Hinterkante
    [~, idx_leading] = min(x);
    [~, idx_trailing] = max(x);
    
    % Teile in Ober- und Unterseite
    if idx_leading < idx_trailing
        % Oberseite: von Hinterkante über Index 1 zur Vorderkante
        if idx_trailing < n
            upper_idx = [idx_trailing+1:n, 1:idx_leading];
        else
            upper_idx = 1:idx_leading;
        end
        % Unterseite: von Vorderkante zur Hinterkante
        lower_idx = idx_leading:idx_trailing;
    else
        % Oberseite: von Hinterkante zur Vorderkante
        upper_idx = idx_trailing:idx_leading;
        % Unterseite: von Vorderkante über Index 1 zur Hinterkante
        if idx_trailing > 1
            lower_idx = [idx_leading:n, 1:idx_trailing];
        else
            lower_idx = idx_leading:n;
        end
    end
    
    % Reorganisiere: Oberseite (rückwärts) + Unterseite
    upper_points = profile(upper_idx, :);
    lower_points = profile(lower_idx, :);
    
    % Kombiniere im Gegenuhrzeigersinn
    % Start an Hinterkante, Oberseite entlang, dann Unterseite zurück
    profile_new = [flipud(upper_points); lower_points(2:end,:)];
    
    % 4. Entferne Punkte mit zu kleinen Panels
    min_panel_length = 1e-5;
    keep = true(size(profile_new, 1), 1);
    
    for i = 1:size(profile_new, 1)
        i_next = mod(i, size(profile_new, 1)) + 1;
        panel_length = norm(profile_new(i_next,:) - profile_new(i,:));
        
        if panel_length < min_panel_length && sum(keep) > 20
            keep(i) = false;
            fprintf('  Entferne Punkt %d (Panel zu klein: %.2e)\n', i, panel_length);
        end
    end
    
    profile_clean = profile_new(keep, :);
    
    % 5. Glätte extreme Winkeländerungen (optional)
    n_clean = size(profile_clean, 1);
    smooth_factor = 0.1;  % Glättungsfaktor
    
    for iter = 1:3  % Mehrere Glättungsdurchgänge
        for i = 2:n_clean-1
            % Berechne Winkel zu Nachbarn
            v1 = profile_clean(i,:) - profile_clean(i-1,:);
            v2 = profile_clean(i+1,:) - profile_clean(i,:);
            
            angle = acos(dot(v1, v2) / (norm(v1) * norm(v2)));
            
            % Glätte bei scharfen Winkeln
            if angle < pi/6  % < 30 Grad
                % Verschiebe Punkt leicht zum Mittelwert der Nachbarn
                midpoint = (profile_clean(i-1,:) + profile_clean(i+1,:)) / 2;
                profile_clean(i,:) = (1-smooth_factor) * profile_clean(i,:) + ...
                                     smooth_factor * midpoint;
            end
        end
    end
    
    % Speichere bereinigte Daten
    fid = fopen(outputFile, 'w');
    for i = 1:size(profile_clean, 1)
        fprintf(fid, '%.15e %.15e\n', profile_clean(i,1), profile_clean(i,2));
    end
    fclose(fid);
    
    fprintf('\nBereinigt: %d Punkte\n', size(profile_clean, 1));
    fprintf('Gespeichert als: %s\n', outputFile);
    
    % Visualisierung
    figure('Name', 'Profil-Bereinigung');
    
    subplot(1,2,1);
    plot(profile(:,1), profile(:,2), 'r-o', 'MarkerSize', 3);
    axis equal;
    grid on;
    xlabel('x');
    ylabel('y');
    title(sprintf('Original (%d Punkte)', n));
    
    subplot(1,2,2);
    plot(profile_clean(:,1), profile_clean(:,2), 'b-o', 'MarkerSize', 3);
    axis equal;
    grid on;
    xlabel('x');
    ylabel('y');
    title(sprintf('Bereinigt (%d Punkte)', size(profile_clean, 1)));
end
