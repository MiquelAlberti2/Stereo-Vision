imageA = Cast(1).gray;
imageB = double(Cast(2).gray);


imagePatchA = double(imageA(26:75,26:75)); % patch

nruns = 1e2;

% First search: do whole image B
t1 = tic;
for i = 1:nruns
    c1 = fastncc(imagePatchA,imageB);
end
toc(t1);


% Second search: do part of B centered on horizontal line around point
t2 = tic;
for i = 1:nruns
    y = 50;
    jdx = y + (-floor(size(imagePatchA,1)/2):floor(size(imagePatchA,1)/2));
    imagePatchB = imageB(jdx,:);
    c2 = fastncc(imagePatchA,imagePatchB);
end
toc(t2);