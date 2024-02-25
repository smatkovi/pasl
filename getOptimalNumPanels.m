function [numPanels] = getOptimalNumPanels()
    numPanels = 8;
    WriteCylinder(numPanels);
    WriteXYLTheta(cylinder.txt);
    M = computeMFromXYLTheta("XYLTheta.txt");
    vInf = 50;
    alpha = pi/18;
    q= computeQFromM(M, vInf, alpha);

      filename = "YLTheta.txt";
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
    v = Mt.*q + vInf*cos(alpha - data(1:numLines-1,4));
    cp = 1 - (v/vInf)^2;
    disp(cp);
end