function [bu,bi,q,x,y] = learnFactorModel (urm,mu,bu_precomputed,bi_precomputed,bu,bi,iterations,lrate,lambda,q,x,y)                                               %#ok
%    [bu,bi,q,x,y]=learnFactorModel(urm,mu,bu,bi,iterations,lrate,lambda,q,x,y)
%    
%    -- reference paper -- 
%      "Factor in the Neighbors: Scalable and Accurate Collaborative Filtering"
%      Yehuda Koren, AT&T Labs - Research

warning ('learnFactorModel:mexFunctionMissing','learnFactorModel mexFunction not found') ;
warning off learnFactorModel:mexFunctionMissing

%if (nargout < 5 || nargout > 7 || nargin < 10 || nargin > 12)
%    error ('wrong number of input/output');
%end


if (size(bu,2)>size(bu(1)))
    bu = bu';
end
if (size(bi,2)>size(bi(1)))
    bi = bi';
end


usersNum = size(urm,1);
%itemsNum = size(urm,2);
ls = size(x,1);

urmT = urm'; % B = urm' (A=urm);

    %h = waitbar(0,'Please wait...');
    for (count=1:iterations)
        pseudoRMSE = 0;
        testCount = 0;
        %tic;
        for (u=1:usersNum)
           % compute the component independent of i
           pu=zeros(ls,1);
           ratedItems = find(urmT(:,u));
           numRatedItems = length(ratedItems);
           if (numRatedItems==0) 
               continue;
           end
           for i=1:numRatedItems
              item=ratedItems(i);
              pu = pu +  (urmT(item,u) - (mu+bu_precomputed(u)+bi_precomputed(item)))*x(:,item);
              pu = pu +  y(:,item);
           end
           pu = pu / sqrt(numRatedItems);     

           sum = zeros(ls,1);
%            if (useruser)
%                sumUU = zeros(ls,1);
%            end
           % for all i in R(u) DO
           for i=1:numRatedItems
               item = ratedItems(i);
               r_hat_ui = mu + bu(u) + bi(item) + q(:,item)'*pu;

               zv=zeros(ls,1);
%                if (useruser)
%                    ratingUsers = find(urm(:,item));
%                    numRatingUsers = length(ratingUsers);
%                    for j=1:numRatingUsers
%                        usertmp=ratingUsers(j);
%                        zv = zv + (urm(usertmp,item) - (mu+bu(usertmp)+bi(item)))*z(:,usertmp);
%                    end
%                    zv = zv / sqrt(numRatingUsers);
%                    r_hat_ui = r_hat_ui + p(:,u)'*zv;
%                end

               e_ui = urmT(item,u) - r_hat_ui;
               pseudoRMSE = pseudoRMSE + e_ui^2;
               testCount = testCount +1;
               if (abs(e_ui)>5 || (mod(u,10000)==0 && i==1)) 
                   display(['u=',num2str(u),' rmse=',num2str(pseudoRMSE/testCount),' e_ui=',num2str(e_ui)]);
               end
               sum = sum + e_ui*q(:,item); %accumulate info for gradient step

%                if (useruser)
%                   sumUU = sumUU + e_ui * p(:,u); 
%                end

               % perform gradient step on qi, bu, bi:
               q(:,item) = q(:,item) + lrate * (e_ui*pu - lambda*q(:,item));
               bu(u) = bu(u) + lrate * (e_ui - lambda*bu(u));
               bi(item) = bi(item) + lrate * (e_ui - lambda*bi(item));
%                if (useruser)
%                   p(:,u) = p(:,u) +  + lrate * (e_ui*zv - lambda*p(:,u));
%                end
               
           end
           % for all i in R(u) DO
           for i=1:numRatedItems
               item = ratedItems(i);

               % perform gradient step on xi, yi:
               x(:,item) = x(:,item) + lrate * ((urmT(item,u)-(mu + bu_precomputed(u) + bi_precomputed(item)))*sum / sqrt(numRatedItems) - lambda*x(:,item));
               y(:,item) = y(:,item) + lrate * (sum / sqrt(numRatedItems) - lambda*y(:,item));
%                if (useruser)
%                    ratingUsers = find(urm(:,item));
%                    numRatingUsers = length(ratingUsers);
%                    for j=1:numRatingUsers
%                        usertmp=ratingUsers(j);
%                        z(:,usertmp) = z(:,usertmp) + lrate * ((urm(usertmp,item)-(mu + bu(usertmp) + bi(item)))*sumUU / sqrt(numRatingUsers) - lambda*z(:,usertmp));
%                    end               
%                end
           end
           %toc
         
        end
    pseudoRMSE = pseudoRMSE / testCount;
    display (['iteration ', num2str(count),' - RMSE = ', num2str(pseudoRMSE)]);        
    end
end
%close(h);