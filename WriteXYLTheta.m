function [t] = WriteXYLTheta(filename)
    x = readFileData(filename);
    U = 0;
    %dimdisp(x);
    sizeX = size(x);
    if atan2(x(2,2)-x(1,2), x(2,1)-x(1,1)) < 0
        disp("alert: first panel suggests clockwise order of points,\n should be counterclockwise (mathematically positive)");
    end
    fileID = fopen('XYLTheta.txt','w');
    %disp(sizeX);

    X = (x(1, 1) + x(sizeX(1), 1))/2;
    Y = (x(1, 2) + x(sizeX(1), 2))/2;
    Theta = atan2((x(sizeX(1), 2) - x(1, 2)), (x(sizeX(1), 1) - x(1, 1)));
    L = sqrt((x(sizeX(1), 1) - x(1, 1))^2 + (x(sizeX(1), 2) - x(1, 2))^2);
    fprintf(fileID,'%.15e %.15e %.15e %.15e\n',X,Y,L,Theta);
    for i = 0:sizeX(1)-2
        %i = sizeX(1)-k-1;
        %U = U + sqrt( (x(i+1, 1) - x(i, 1))^2 + (x(i+1, 2) - x(i, 2))^2);
        %if i < sizeX(1)
            X = (x(sizeX(1)-i, 1) + x(sizeX(1)-i-1, 1))/2;
            Y = (x(sizeX(1)-i, 2) + x(sizeX(1)-i-1, 2))/2;
            Theta = atan2((x(sizeX(1)-i-1, 2) - x(sizeX(1)-i, 2)), (x(sizeX(1)-i-1, 1) - x(sizeX(1)-i, 1)));
            L = sqrt((x(sizeX(1)-i-1, 1) - x(sizeX(1)-i, 1))^2 + (x(sizeX(1)-i-1, 2) - x(sizeX(1)-i, 2))^2);
        %else 
        %    X = (x(1, 1) + x(sizeX(1), 1))/2;
        %    Y = (x(1, 2) + x(sizeX(1), 2))/2;
        %    Theta = atan2((x(sizeX(1), 2) - x(1, 2)), (x(sizeX(1), 1) - x(1, 1)));
        %    L = sqrt((x(sizeX(1), 1) - x(1, 1))^2 + (x(sizeX(1), 2) - x(1, 2))^2);
        %end
        
        fprintf(fileID,'%.15e %.15e %.15e %.15e\n',X,Y,L,Theta);
    end

    %U = U + sqrt( (x(sizeX(1)-1, 1) - x(sizeX(1)-2, 1))^2 + (x(sizeX(1)-1, 2) - x(sizeX(1)-2, 2))^2);
    U = U + sqrt( (x(sizeX(1), 1) - x(sizeX(1)-1, 1))^2 + (x(sizeX(1), 2) - x(sizeX(1)-1, 2))^2);

    fclose(fileID);
    %disp(U);
    t = max(x(:, 1)) - min(x(:, 1));
end
