function [recList] = flow_lsa_Cosine (model, urm, icm, userIndex)
%%%%%% LSA 

%%%%% 1. Perform a recommendation

vectorActiveUser = urm( userIndex, : ); %extract a single row from the URM (i.e., it's a single user with his ratings)
                                        %we will provide recommendations for this user

viewedItems = find( vectorActiveUser ); %this vector will contains the indexes of the items rated by the user


%onlineParamLSA.postProcessingFunction = @keep1000randomItems;
%onlineParamLSA.filterViewedItems = true;
%onlineParamLSA.viewedItems = viewedItems;
%onlineParamLSA.itemToTest = 2000;
onlineParamLSA.shrinking = 0;

recList = feval( @onLineRecom_lsa_NNCosine, vectorActiveUser, model, onlineParamLSA );

recList( viewedItems ) = -inf;