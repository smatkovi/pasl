function [M] = computeMFromXYLTheta(filename)
  % Open the file with XYLTheta for reading
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

  xi = zeros(numLines, numLines);
  eta = zeros(numLines, numLines);
  I = zeros(numLines, numLines);
  J = zeros(numLines, numLines);
  M = zeros(numLines, numLines);

  for i = 1:numLines
      for j = 1:numLines
          xi(i, j) = (data(i, 1) - data(j, 1))*cos(data(j, 4)) + (data(i, 2) - data(j, 2))*sin(data(j, 4));
          eta(i, j) = -(data(i, 1) - data(j, 1))*sin(data(j, 4)) + (data(i, 2) - data(j, 2))*cos(data(j, 4));

          if i == j
              I(i, j) = 0;
              J(i, j) = 0.5;
          else
              I(i, j) = log(((data(j, 3) + 2*xi(i,j))^2 + 4*eta(i, j)^2)/((data(j, 3) - 2*xi(i,j))^2 + 4*eta(i, j)^2))/(4*pi);
              J(i, j) = atan((data(j, 3) - 2*xi(i, j))/(2*eta(i, j)))/(2*pi) + atan((data(j, 3) + 2*xi(i, j))/(2*eta(i, j)))/(2*pi);
          end

          M(i, j) = -sin(data(i, 4) - data(j, 4))*I(i, j)+cos(data(i, 4) - data(j, 4))*I(i, j);
      end
  end

end
