function plotCps(name)
    % Validierung und Formatierung des Eingabe-Arguments
    if nargin < 1 || ~ischar(name) && ~isstring(name)
        error('Bitte geben Sie einen Namen als String-Argument an.');
    end
    name = char(name);
    if ~isempty(name)
        name(1) = upper(name(1));
    else
        error('Name darf nicht leer sein.');
    end
    outputFileName = ['cps' name '.png'];

    % Daten einlesen
    cps1 = load('cps1.txt');
    cps2 = load('cps2.txt');
    n1 = length(cps1);
    n2 = length(cps2);
    x1 = (0:n1-1)' / n1;
    x2 = (0:n2-1)' / n2;

    % Figur erstellen
    f = figure('Visible','off');
    hold on;
    plot(x1, cps1, 'o-', 'Color', [1,0.5,0], 'DisplayName', ['c_p ' name ' upper wing']);
    plot(x2, cps2, 'x-', 'Color', [0.5,0,0.5], 'DisplayName', ['c_p ' name ' lower wing']);
    hold off;
    xlabel('Panel');
    ylabel('c_p');
    title(['Data from cps.txt for ' name ' wingfoil']);
	legend('Location','northoutside','Orientation','horizontal');
    grid on;

    % Bildauflösung einstellen: 1024 x 768 Pixel bei 150 dpi
    dpi = 150;
    width_pix = 1024;
    height_pix = 768;
    width_in = width_pix / dpi;   % in inches
    height_in = height_pix / dpi; % in inches

    set(f, 'PaperUnits', 'inches');
    set(f, 'PaperPosition', [0 0 width_in height_in]);
    set(f, 'PaperSize', [width_in height_in]);

    % Bild als PNG speichern mit 150 dpi (entspricht 1024x768 Pixel)
    print(f, outputFileName, '-dpng', ['-r' num2str(dpi)]);

    fprintf('Plot gespeichert unter: %s\n', outputFileName);
    close(f);  % Figur schließen, um Ressourcen frei zu geben
end

