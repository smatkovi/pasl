function [] = WriteCylinder(numPanels)
    fileID = fopen('cylinder.txt','w');
    x = [1; 0];
    %.15eprintf(fileID,'%d\n', numPanels-1);
    fprintf(fileID,'%.15e %.15e\n', x);
    theta = 2*pi/numPanels;
    rot = zeros(2, 2);
    rot(1, 1) = cos(theta);
    rot(1, 2) = -sin(theta);
    rot(2, 1) = sin(theta);
    rot(2, 2) = cos(theta);

    x = [0.5; 0];
    for i = 1:numPanels-1
        x = rot*x;% + [0.5; 0];
        fprintf(fileID,'%.15e %.15e\n', x + [0.5; 0]);
    end
    fclose(fileID);
end
