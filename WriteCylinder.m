function [] = WriteCylinder(numPanels)
    fileID = fopen('cylinder.txt','w');
    x = [0.5; 0];
    fprintf(fileID,'%d\n', numPanels-1);
    fprintf(fileID,'%f %f\n', x);
    theta = 2*pi/numPanels;
    rot = zeros(2, 2);
    rot(1, 1) = cos(theta);
    rot(1, 2) = -sin(theta);
    rot(2, 1) = sin(theta);
    rot(2, 2) = cos(theta);

    for i = 1:numPanels-1
        x = rot*x;
        fprintf(fileID,'%f %f\n', x);
    end
    fclose(fileID);
end