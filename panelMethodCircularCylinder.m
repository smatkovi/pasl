function M = panelMethodCylinder(n)
    % panelMethodCylinder - Computes the system matrix M for a circular
    % cylinder using the panel method with n panels.
    %
    % Syntax:  M = panelMethodCylinder(n)
    %
    % Inputs:
    %    n - Number of panels
    %
    % Outputs:
    %    M - System matrix for the normal velocities at the panel midpoints
    %
    % Example: 
    %    M = panelMethodCylinder(8);
    
    % Define Circle Coordinates
    theta = linspace(0, 2*pi, n+1);
    x = cos(theta);
    y = sin(theta);

    % Pre-allocate matrices and vectors
    M = zeros(n, n);
    I = zeros(n, n);
    J = zeros(n, n);

    % Calculate Panel Midpoints and Panel Lengths
    Xm = zeros(n, 1);
    Ym = zeros(n, 1);
    L = zeros(n, 1);
    theta_i = zeros(n, 1);

    for i = 1:n
        Xm(i) = (x(i) + x(mod(i, n)+1))/2;
        Ym(i) = (y(i) + y(mod(i, n)+1))/2;
        L(i) = sqrt((x(mod(i, n)+1) - x(i))^2 + (y(mod(i, n)+1) - y(i))^2);
        theta_i(i) = atan2(y(mod(i, n)+1) - y(i), x(mod(i, n)+1) - x(i));
    end

    % Compute Influence Coefficients
    for i = 1:n
        for j = 1:n
            if i ~= j
                Xi = Xm(i);
                Yi = Ym(i);
                Xj = Xm(j);
                Yj = Ym(j);
                cos_theta_j = cos(theta_i(j));
                sin_theta_j = sin(theta_i(j));

                xi_j = (Xi - Xj) * cos_theta_j + (Yi - Yj) * sin_theta_j;
                eta_j = -(Xi - Xj) * sin_theta_j + (Yi - Yj) * cos_theta_j;

                I(i, j) = (1/(4*pi)) * log(((L(j) + 2*xi_j)^2 + 4*eta_j^2) / ((L(j) - 2*xi_j)^2 + 4*eta_j^2));
                J(i, j) = (1/(2*pi)) * (atan((L(j) - 2*xi_j) / (2*eta_j)) + atan((L(j) + 2*xi_j) / (2*eta_j)));
            end
        end
    end

    % Compute Matrix M
    for i = 1:n
        for j = 1:n
            M(i, j) = -sin(theta_i(i) - theta_i(j)) * I(i, j) + cos(theta_i(i) - theta_i(j)) * J(i, j);
        end
    end
end
