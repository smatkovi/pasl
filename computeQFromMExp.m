function [q, ql] = computeQFromMExp(MExp, bExp)
    sizeMExp = size(MExp);
    q = linsolve(MExp, bExp);
    ql = q.*data(1:sizeMExp(1),3);
end