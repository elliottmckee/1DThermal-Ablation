function [ M2n,p2op1,rho2orho1,t2ot1,deltasoR,p02op01 ] =...
    shock_calc( M1, g )

M2n=sqrt((1+(g-1)/2*M1^2)/(g*M1^2-(g-1)/2));
p2op1=1+2*g/(g+1)*(M1^2-1);
rho2orho1=(g+1)*M1^2/(2+(g-1)*M1^2);
t2ot1=p2op1/rho2orho1;
deltasoR=g/(g-1)*log(t2ot1)-log(p2op1);
p02op01=exp(-deltasoR);
end