function [MExp, bExp] = expandM(M, v, alpha)
    sizeM = size(M);

    MExp = zeros(sizeM(1)+1, sizeM(1)+1);
    for i = 1:sizeM(1)
        for j = 1:sizeM(1)
            MExp(i, j) = M(i, j);
        end
    end

    for i = 1:sizeM(1)
        for j = 1:sizeM(1)
            MExp(i, sizeM(1)+1) = MExp(i, sizeM(1)) + M (i, j);
        end
    end
    for j = 1:sizeM(1)
        MExp(sizeM(1)+1, j) = M(1, j) + M(sizeM(1), j);
        MExp(sizeM(1)+1, sizeM(1)+1) = MExp(sizeM(1)+1, sizeM(1)+1) - M(1, j) + M(sizeM(1), j);
    end
   
    bExp = zeros(sizeM(1)+1, 1);

  % Open the file with XYLTheta for reading
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
    for i = 1:sizeM(1)
        bExp(i) = v*sin(alpha - data(i, 4));
    end
    bExp(sizeM(1)+1) = -v*(cos(alpha - data(1, 4)) + cos(alpha - data(sizeM(1), 4)));
end