function L2 = L2norm(vec)
    if size(vec,1)==1
        L2 = vec*vec';
    elseif size(vec,2)==1
        L2 = vec'*vec;
    end
    L2 = L2/length(vec);
end