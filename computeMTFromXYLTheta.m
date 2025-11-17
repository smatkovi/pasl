function [M] = computeMTFromXYLTheta(filename)
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
    data(i, :) = fscanf(fid, '%e %e %e %e', [1 4]); %data(i, 1) is X, data(i, 2) is Y, data(i, 3) is L and data(i, 4) is Theta 
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
              % Korrigierte Berechnung
              term1 = (data(j, 3) + 2*xi(i,j))^2 + 4*eta(i, j)^2;
              term2 = (data(j, 3) - 2*xi(i,j))^2 + 4*eta(i, j)^2;
              I(i, j) = log(term1/term2)/(4*pi);
              
              % Korrigiertes J mit atan statt atan2
              if abs(eta(i, j)) < 1e-12
                  J(i, j) = 0;
              else
                  arg1 = (data(j, 3) - 2*xi(i, j)) / (2*abs(eta(i, j)));
                  arg2 = (data(j, 3) + 2*xi(i, j)) / (2*abs(eta(i, j)));
                  J(i, j) = (atan(arg1) + atan(arg2))/(2*pi);
                  if eta(i, j) < 0
                      J(i, j) = -J(i, j);
                  end
              end
          end

          % Tangentialkomponente
          M(i, j) = cos(data(i, 4) - data(j, 4))*I(i, j) + sin(data(i, 4) - data(j, 4))*J(i, j);
      end
  end
end
