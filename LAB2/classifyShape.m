function shape = classifyShape(props)

c = props.Circularity;
e = props.Extent;
ecc = props.Eccentricity;
sol = props.Solidity;

if c > 0.85
    shape = 'circle';

elseif e > 0.45 && c > 0.65 && ecc < 0.8 && sol > 0.9
    shape = 'square';

else
    shape = 'other';
end

end