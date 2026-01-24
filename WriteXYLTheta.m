function [t] = WriteXYLTheta(filename)
    x = readFileData(filename);
    U = 0;
    sizeX = size(x);
    
    % Check if profile is closed (first and last points are the same)
    closing_distance = sqrt((x(1,1)-x(sizeX(1),1))^2 + (x(1,2)-x(sizeX(1),2))^2);
    profile_is_closed = closing_distance < 1e-10;
    
    if atan2(x(2,2)-x(1,2), x(2,1)-x(1,1)) < 0
        disp("alert: first panel suggests clockwise order of points,\n should be counterclockwise (mathematically positive)");
    end
    fileID = fopen('XYLTheta.txt','w');

    % Only create closing panel if profile is not already closed
    if ~profile_is_closed
        X = (x(1, 1) + x(sizeX(1), 1))/2;
        Y = (x(1, 2) + x(sizeX(1), 2))/2;
        Theta = atan2((x(sizeX(1), 2) - x(1, 2)), (x(sizeX(1), 1) - x(1, 1)));
        L = closing_distance;
        fprintf(fileID,'%.15e %.15e %.15e %.15e\n',X,Y,L,Theta);
    end
    
    for i = 0:sizeX(1)-2
        X = (x(sizeX(1)-i, 1) + x(sizeX(1)-i-1, 1))/2;
        Y = (x(sizeX(1)-i, 2) + x(sizeX(1)-i-1, 2))/2;
        Theta = atan2((x(sizeX(1)-i-1, 2) - x(sizeX(1)-i, 2)), (x(sizeX(1)-i-1, 1) - x(sizeX(1)-i, 1)));
        L = sqrt((x(sizeX(1)-i-1, 1) - x(sizeX(1)-i, 1))^2 + (x(sizeX(1)-i-1, 2) - x(sizeX(1)-i, 2))^2);
        fprintf(fileID,'%.15e %.15e %.15e %.15e\n',X,Y,L,Theta);
    end

    fclose(fileID);
    t = max(x(:, 1)) - min(x(:, 1));
end
