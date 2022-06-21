function noisy = add_noise(field, sig)
L           = length(field.Bx);
noisy.Bx    = field.Bx + normrnd(0, sig, 1, L);
noisy.By    = field.By + normrnd(0, sig, 1, L);
noisy.Bz    = field.Bz + normrnd(0, sig, 1, L);
noisy.pos   = field.pos;
end
