function shape = classifyShape(props)

c = props.Circularity;
ecc  = props.Eccentricity;
sol  = props.Solidity;

% ===== KOŁO =====
if c > 0.9 && ecc < 0.4
    shape = 'circle';

% ===== KWADRAT =====
elseif c > 0.70 && c <= 0.9 && sol > 0.9
    shape = 'square';

% ===== RESZTA =====
else
    shape = 'other';
end

end