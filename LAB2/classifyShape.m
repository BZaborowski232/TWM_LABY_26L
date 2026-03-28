function shape = classifyShape(props)

c = props.Circularity;
ecc  = props.Eccentricity;
sol  = props.Solidity;

if c > 0.9 && ecc < 0.4
    shape = 'circle';

elseif c > 0.70 && c <= 0.9 && sol > 0.9
    shape = 'square';

else
    shape = 'other';
end

end