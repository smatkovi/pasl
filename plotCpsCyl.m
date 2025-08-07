function plotCpsCyl(numPanels)
    % plotCpsCyl(numPanels) liest 'cps.txt' ein und plottet zwei Spalten
    % analog zum Gnuplot-Skript:
    % set terminal png size 1024,768
    % set output "cps<numPanels>.png"
    % plot "cps.txt" using ($0/(AnzahlZeilen)):1 ls 1 title 'c_p', \
    %      '' using ($0/(AnzahlZeilen)):2 ls 2 title 'c_p aus Potenzialtheorie'
    %
    % numPanels: Anzahl der Panels, wird genutzt für Ausgabe-Dateiname
    %            und für Anzeige im Titel.
    %
    % Beispiel: plotCpsCyl(360)
    
    if nargin < 1 || ~isscalar(numPanels) || numPanels <= 0
        error('Bitte eine positive Zahl für numPanels angeben.');
    end
    
    % Daten einlesen
    data = load('cpscas.txt');  % erwartet mindestens zwei Spalten
    nRows = size(data,1);
    
    % Normalisierte Panel-Positionen: 0 bis knapp unter 1
    x = (0:nRows-1)' / nRows;
    
    % Farben analog zu Gnuplot
    color1 = [1, 0.5, 0];    % orange
    color2 = [0.5, 0, 0.5];  % lila (purple)
    
    % Figur erstellen, unsichtbar zum Speichern
    fig = figure('Visible','off', 'Units', 'pixels', 'Position', [100 100 1024 768]);
    hold on;
    
    % Plot zwei Datenreihen mit Linienpoints
    plot(x, data(:,1), 'x-', 'Color', color1, 'DisplayName', 'c_p');
    %plot(x, data(:,2), 'x-', 'Color', color2, 'DisplayName', 'c_p aus Potenzialtheorie');
    
    hold off;
    xlabel('Panel');
    ylabel('c_p');
    title(sprintf('Data from cps.txt with %d panels', numPanels));
	legend('Location','northoutside','Orientation','horizontal');
    grid on;
    
    % Papiergröße für PNG mit 1024x768 Pixel bei 150 dpi setzen
    dpi = 150;
    width_pix = 1024;
    height_pix = 768;
    width_in = width_pix / dpi;
    height_in = height_pix / dpi;
    set(fig, 'PaperUnits', 'inches');
    set(fig, 'PaperPosition', [0 0 width_in height_in]);
    set(fig, 'PaperSize', [width_in height_in]);
    
    % Dateiname analog Gnuplot-Ausgabe
    filename = sprintf('cpcurl%d.png', numPanels);
    
    % Bild speichern
    print(fig, filename, '-dpng', ['-r' num2str(dpi)]);
    fprintf('Plot gespeichert als: %s\n', filename);
    
    close(fig);
end

