function [] = getQGammaProfile(filenameProfile)
    t=WriteXYLTheta(filenameProfile);
    M = computeMCurlFromXYLTheta("XYLTheta.txt", filenameProfile);
    Mt = computeMTCurlFromXYLTheta("XYLTheta.txt");
    vInf = 40;
    alpha = 10*pi/180;
    [MExp, bExp] = expandM(Mt, M, vInf, alpha);
    sizeMExp=size(MExp);
    q = computeQFromMExp(MExp, bExp);

      filename = "XYLTheta.txt";
  fid = fopen(filename, 'r');

  % Check if file opened successfully
  if fid == -1
    error(['Error: Could not open file ' filename]);
  end

  % Count the number of lines in the file
  numLines = 0;
  tline = fgetl(fid);
  while ischar(tline)
    numLines = numLines + 1;
    tline = fgetl(fid);
  end

  % Close the file and reopen to reset the file pointer
  fclose(fid);
  fid = fopen(filename, 'r');

  % Pre-allocate memory for the matrix with 4 rows
  data = zeros(numLines, 4);

  % Read values and store them in the matrix
  i = 1;
  while i <= numLines
    data(i, :) = fscanf(fid, '%f %f %f %f', [1 4]); %data(i, 1) is X, data(i, 2) is Y, data(i, 3) is L and data(i, 4) is Theta 
    i = i + 1; % Increment by 1 to keep track of lines
  end

  % Close the file
    fclose(fid);

    Mt = computeMTCurlFromXYLTheta("XYLTheta.txt");
    sizeMt = size(Mt);
    %helpVect = zeros(sizeMt(1), 1);
    sizeQ = size(q);
    v = zeros(sizeMExp(1), 1);
    vY = zeros(sizeMExp(1), 1);
    ca = zeros(sizeMExp(1), 1);
    for i = 1:sizeMt(1)
        for j = 1:sizeQ(1)-1
            %helpVect(i) = vInf*cos(alpha - data(i, 4));
            v(i) = v(i) + Mt(i, j)*q(j) - q(sizeQ(1))*M(i, j);
            vY(i) = vY(i) + Mt(i, j)*q(j) + q(sizeQ(1))*M(i, j);
        end
        v(i) = v(i) + vInf*cos(alpha - data(i, 4));
        vY(i) = vY(i) + vInf*sin(alpha);
        ca(i) = ((v(i)/vInf)^2)/t * cos(alpha - data(i, 4))*data(i, 3);
    end
    
    %v = Mt.*q + helpVect;
    disp(v)
    disp("ca:")
    disp(ca)
    fileID = fopen('cpscas.txt','w');
    cp = zeros(sizeMExp(1), 1);
    for i = 1:sizeQ(1)
        cp(i) = 1 - (v(i)/vInf)^2;
        fprintf(fileID,'%f\n', cp(i));
    end
    c_a = sum(ca);
    disp(c_a)
    fclose(fileID);
end