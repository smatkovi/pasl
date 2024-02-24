function [] = WriteYLTheta(filename)
    x = readFileData(filename);
    U = 0;
    sizeX = size(x);
    fileID = fopen(YLTheta.txt','w');
    for i = 1:sizeX(1)-1
        U = U + sqrt( (x(i+1, 1) - x(i, 1))^2 + (x(i+1, 2) - x(i, 2))^2);

        X = (x(sizeX(1)-i, 1) + x(sizeX(1)-i-1, 1))/2;
        Y = (x(sizeX(1)-i, 2) + x(sizeX(1)-i-1, 2))/2;

        Theta = atan((x(sizeX(1)-i-1, 2) - x(sizeX(1)-i, 2))/(x(sizeX(1)-i-1, 1) - x(sizeX(1)-i, 1)));

        fprintf(fileID,'%f %f %f %f\n',X,Y,Theta,L);
    end
    disp(U);
    
end