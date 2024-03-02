function [] = getOptimalNumPanels(numPanels)
    %numPanels = 8;
    WriteCylinder(numPanels);
    WriteXYLTheta("cylinder.txt");
    M = computeMFromXYLTheta("XYLTheta.txt");
    x = readFileData("cylinder.txt");
    vInf = 50;
    alpha = pi/18;
    q = computeQFromM(M, vInf, alpha);

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

    Mt = computeMTFromXYLTheta("XYLTheta.txt");
    sizeMt = size(Mt);
    %helpVect = zeros(sizeMt(1), 1);
    sizeQ = size(q);
    v = zeros(sizeMt(1), 1);
    cp = zeros(sizeMt(1), 1);
    phi = zeros(sizeMt(1), 1);
    %cpPhi = zeros(sizeMt(1), 1);
    l = 0;
    for i = 1:sizeMt(1)
        for j = 1:sizeQ(1)
            %helpVect(i) = vInf*cos(alpha - data(i, 4));
            v(i) = v(i) + Mt(i, j)*q(j);
        end
        v(i) = v(i) + vInf*cos(alpha - data(i, 4));
        cp(i) = 1 - (v(i)/vInf)^2;
        r = sqrt((0 - x(i, 1))^2 + (-1 - x(i, 2))^2);
        %l = l + data(i, 3);
        if i>1
            l = l + data(i-1, 3);
            phi(i) = q(i)*l*log(r)/(4*pi); %int(f(x), dx, a, b) = (b-a)f(a+b)/2
            %phi(i) = q(i)*data(i, 3)*log(data(i, 3))/(2*pi);
            %cpPhi(i) = 2*cos(2*phi(i));
        end
    end
    %phi = phi - sin(alpha)*vInf;
    phiTot = - (sin(alpha)*vInf) + sum(phi) ;
    %v = Mt.*q + helpVect;
    %%disp(v);
    disp(cp(1));
    %disp(sum(cp));
    disp(2*cos(2*(phiTot)- 1));
end