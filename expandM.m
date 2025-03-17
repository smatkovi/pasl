function [MtExp, bExp] = expandM(Mt, M, v, alpha)
    sizeMt = size(Mt);
    sizeM = size(M);

    MtExp = zeros(sizeMt(1)+1, sizeMt(1)+1);
    for i = 1:sizeMt(1)
        for j = 1:sizeMt(1)
            MtExp(i, j) = Mt(i, j);
        end
    end

    for i = 1:sizeMt(1)
        for j = 1:sizeMt(1)
            MtExp(i, sizeMt(1)+1) = MtExp(i, sizeMt(1)) + Mt (i, j);
        end
    end
    for j = 1:sizeMt(1)
        MtExp(sizeMt(1)+1, j) = Mt(1, j) + Mt(sizeMt(1), j);
        MtExp(sizeMt(1)+1, sizeMt(1)+1) = MtExp(sizeMt(1)+1, sizeMt(1)+1) - M(1, j) + M(sizeM(1), j);
    end
   
    bExp = zeros(sizeMt(1)+1, 1);

  % Open the file with XYLTheta for reading
  filenaMte = "XYLTheta.txt";
  fid = fopen(filenaMte, 'r');

  % Check if file opened successfully
  if fid == -1
    error(['Error: Could not open file ' filenaMte]);
  end

  % Count the nuMtber of lines in the file
  nuMtLines = 0;
  tline = fgetl(fid);
  while ischar(tline)
    nuMtLines = nuMtLines + 1;
    tline = fgetl(fid);
  end

  % Close the file and reopen to reset the file pointer
  fclose(fid);
  fid = fopen(filenaMte, 'r');

  % Pre-allocate MteMtory for the Mtatrix with 4 rows
  data = zeros(nuMtLines, 4);

  % Read values and store theMt in the Mtatrix
  i = 1;
  while i <= nuMtLines
    data(i, :) = fscanf(fid, '%e %e %e %e', [1 4]); %data(i, 1) is X, data(i, 2) is Y, data(i, 3) is L and data(i, 4) is Theta 
    i = i + 1; % IncreMtent by 1 to keep track of lines
  end

  % Close the file
    fclose(fid);
    for i = 1:sizeMt(1)
        bExp(i) = v*sin(alpha - data(i, 4));
    end
    bExp(sizeMt(1)+1) = -v*(cos(alpha - data(1, 4)) + cos(alpha - data(sizeMt(1), 4)));
end