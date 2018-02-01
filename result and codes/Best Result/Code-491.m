clc
clear all
close all

train = xlsread('train.xlsx');
evaluation = xlsread('evaluation.xlsx');
realClass = xlsread('realClass1.xlsx');
[x,y]=size(evaluation);
output=zeros(x,y+1);
[row,col]=size(train);
price = zeros(570, 56);
sales = zeros(570,56);
realSales = zeros(570,14);
a=14*570;

result=zeros(a,1);
period =1;
p = zeros(1,8);  % these are for obtaining of price and sales for regression function
s = zeros(1,8);
for j = 1:570
    for k = 1:42
        price(j,k) = train((k-1)*570 + j,3);  % fills the price(item , day) for day 1 to 42
        sales(j,k) = train((k-1)*570 + j,4);  % fills the sales(item , day) for day 1 to 42
    end
end

for j = 1:570
    for k = 1:14
        price(j,k+42) = evaluation((k-1)*570 + j,3); % fills the price(item, day) for day 43 to 56
        realSales(j,k) = realClass((k-1)*570 + j,4);
    end
end



for t=43:56
    for k=1:570
        p = zeros(1,8);
        s = zeros(1,8);
        minimum = min(price(1:570,t));
        maximum = max(price(1:570,t)); %maximum = max(price(k,1:42));
        delta = maximum - minimum;
        u = price(k ,t) * (1 + delta/249);
        l = price(k ,t) * (1 - delta/100);
        w = t - period;
        counter = 1;
        while( w >= 1)
            if (price(k,w)<u && price(k,w)>l)
                p(1, counter) = price(k,w);
                s(1, counter) = sales(k,w);
                counter = counter + 1;
            end
            w = w - period;
        end
        if (counter ~= 1)
            sales(k,t) = regression(p , s , price(k,t) , counter);
        else
            sales(k,t)=0;
        end
    end
end
error = 0;

for g=1:14
    for b=1:570
        error = error + (sales(b,g+42) - realSales(b,g))*(sales(b,g+42) - realSales(b,g));
    end
end
tatalError = sqrt(error);
errorPercent = tatalError/(14*570);


for i=1:14 % extract predected data from sales
    result((i-1)*570+1:i*570,1)=sales(1:570,(i+42));
end
output(1:x,1:y)=evaluation(1:x,1:y);
output(1:x,y+1)=result(1:x,1);
fName = 'output.txt';
fid = fopen('output.txt','w');
dlmwrite(fName, output, '-append', 'newline', 'pc', 'delimiter','|');

