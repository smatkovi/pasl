function [] = WriteYLTheta(filename)
    x = readFileData(filename)
    U = 0;
    sizeX = size(x);
    for i = 1:sizeX(1)-1
        U = U + sqrt( (x(i+1, 1) - x(i, 1))^2 + (x(i+1, 2) - x(i, 2))^2);
    end
    disp(U);
    
end