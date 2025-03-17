% Function to read data from a file
function [data] = readFileData(filename)
  % Open the file for reading
  fid = fopen(filename, 'r');
  
  % Check if file opened successfully
  if fid == -1
    error(['Error: Could not open file ' filename]);
  end

  % Read the first line to get the number of values
    numValues = 0;
  tline = fgetl(fid);
  while ischar(tline)
    numValues = numValues + 1;
    tline = fgetl(fid);
  end

  % Close the file and reopen to reset the file pointer
  fclose(fid);
  fid = fopen(filename, 'r');

  % Pre-allocate memory for the matrix to improve efficiency
  data = zeros(numValues, 2);

  % Read remaining lines and store values in the matrix
  for i = 1:numValues
    data(i, :) = fscanf(fid, '%e %e', [1 2]);
  end

  % Close the file
  fclose(fid);
end
