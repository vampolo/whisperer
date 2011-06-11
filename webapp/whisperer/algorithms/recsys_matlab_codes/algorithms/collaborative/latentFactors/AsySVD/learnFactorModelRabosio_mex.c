#include "cs_mex.h"
#include "math.h"
#include "stdio.h"
#include "time.h"

/* 
    [bu,bi,q,x,y,[p,z]]=learnFactorModel(urm,mu,bu,bi,iterations,lrate,lambda,q,x,y,[p,z])
    
    -- reference paper -- 
      "Factor in the Neighbors: Scalable and Accurate Collaborative Filtering"
      Yehuda Koren, AT&T Labs - Research
      
*/

#define log 1

double absolute (double x);
bool file_exists(const char * filename);

void mexFunction
(
    int nargout,
    mxArray *pargout [ ],
    int nargin,
    const mxArray *pargin [ ]
)
{
    printf("Factorized neighborhood corretto bu_precomputed, bi_precomputed\n");
	
	int iterations;
    double mu, lrate, lambda;
    double *bu_precomputed, *bi_precomputed, *buin, *biin, *qin, *xin, *yin, *pin, *zin;
    double                                   *bu,   *bi,   *q,   *x,   *y,   *p,   *z;
    int ls;
    int itemsNum, usersNum;
    cs_dl Amatrix, *A;
    bool useruser = false;
    FILE *verbose;
	int indexArgin = 0, indexArgout = 0;
    
    if (nargout < 5 || nargout > 7 || nargin < 12 || nargin > 14)
    {
        mexErrMsgTxt ("Usage: [bu,bi,q,x,y,[p,z]]=learnFactorModel(urm,mu,bu,bi,iterations,lrate,lambda,q,x,y,[p,z]) \n urm must be sparse, bu and bi must be dense") ;
    }
    
    if (nargout>7 && nargin>13)
    {
        useruser=true; /* enable the integration of the user-user model into the item-item model */
        if (log) fprintf(stdout,"user-user model enabled\n");
    }    

	useruser=false;
    
    
    
    if (log>1)
    {
        verbose = fopen("/home/roby/verbose.txt", "w+"); 
        fprintf(stdout, "verbose mode");   
    }
    
    if (log) fprintf(stdout,"--input started\n");

    A = cs_dl_mex_get_sparse (&Amatrix, 0, 1, pargin [indexArgin]) ;  usersNum = mxGetM(pargin[indexArgin++]);  /* get A=urm */
    mu = mxGetScalar (pargin [indexArgin++]);
	bu_precomputed = mxGetPr(pargin[indexArgin++]);
	bi_precomputed = mxGetPr(pargin[indexArgin++]);
    buin = mxGetPr(pargin[indexArgin++]); 
    biin = mxGetPr(pargin[indexArgin++]);
    iterations = mxGetScalar (pargin [indexArgin++]);
    lrate = mxGetScalar (pargin [indexArgin++]);
    lambda = mxGetScalar (pargin [indexArgin++]);
    qin = mxGetPr(pargin[indexArgin]); ls = mxGetM(pargin[indexArgin]); itemsNum = mxGetN(pargin[indexArgin++]); 
    xin = mxGetPr(pargin[indexArgin++]);
    yin = mxGetPr(pargin[indexArgin++]);
    if (useruser)
    {
        pin = mxGetPr(pargin[indexArgin++]);
        zin = mxGetPr(pargin[indexArgin++]);   
        if (log) fprintf(stdout," read: p and z \n");            
    }  
        
    if (log) fprintf(stdout,"users=%d, items=%d\n",usersNum,itemsNum);
    if (log) fprintf(stdout,"number of factors=%d, number of iterations=%d\n",ls,iterations);
    if (log) fprintf(stdout," bu =[%d x %d] \n", mxGetM(pargin[2]), mxGetN(pargin[2]));
    if (log) fprintf(stdout," bi =[%d x %d] \n", mxGetM(pargin[3]), mxGetN(pargin[3]));       
    
    if (log) fprintf(stdout,"--input completed\n");
    
    UF_long Am, An, Anzmax, Anz, *Ap, *Ai ;
    double *Ax ;
    if (!A) { printf ("(null)\n") ; return  ; }
    
    Am = A->m ; An = A->n ; 	    Ap = A->p ;   Ai = A->i ; 
    Ax = A->x ;	Anzmax = A->nzmax ; Anz = A->nz ;
    
    /* 
        B = transpose of URM
    */
    cs_dl *B;
    UF_long Bm, Bn, Bnzmax, Bnz, *Bp, *Bi ;
    double *Bx ;
    B = cs_dl_transpose (A, 1) ;                       /* B = A' = urm' */
    Bm = B->m ; Bn = B->n ; 	    Bp = B->p ;   Bi = B->i ; 
    Bx = B->x ;	Bnzmax = B->nzmax ; Bnz = B->nz ;
    
    int ii;
	
	/*pargout[indexArgout]=mxCreateDoubleMatrix(usersNum,1,mxREAL);
    bu_precomputed=mxGetPr(pargout[indexArgout++]);
    for (ii=0;ii<usersNum;ii++) bu_precomputed[ii] = bu_precomputedin[ii];

	pargout[indexArgout]=mxCreateDoubleMatrix(itemsNum,1,mxREAL);
    bi_precomputed=mxGetPr(pargout[indexArgout++]);
    for (ii=0;ii<itemsNum;ii++) bi_precomputed[ii] = bi_precomputedin[ii];*/

    pargout[indexArgout]=mxCreateDoubleMatrix(usersNum,1,mxREAL);
    bu=mxGetPr(pargout[indexArgout++]);
    for (ii=0;ii<usersNum;ii++) bu[ii] = buin[ii];

    pargout[indexArgout]=mxCreateDoubleMatrix(itemsNum,1,mxREAL);
    bi=mxGetPr(pargout[indexArgout++]);
    for (ii=0;ii<itemsNum;ii++) bi[ii] = biin[ii];

    pargout[indexArgout]=mxCreateDoubleMatrix(ls,itemsNum,mxREAL);
    q=mxGetPr(pargout[indexArgout++]);
    for (ii=0;ii<ls*itemsNum;ii++) q[ii] = qin[ii];

    pargout[indexArgout]=mxCreateDoubleMatrix(ls,itemsNum,mxREAL);
    x=mxGetPr(pargout[indexArgout++]);
    for (ii=0;ii<ls*itemsNum;ii++) x[ii] = xin[ii];

    pargout[indexArgout]=mxCreateDoubleMatrix(ls,itemsNum,mxREAL);
    y=mxGetPr(pargout[indexArgout++]);
    for (ii=0;ii<ls*itemsNum;ii++) y[ii] = yin[ii];

	
    
    if (useruser)    
    {
        pargout[indexArgout]=mxCreateDoubleMatrix(ls,usersNum,mxREAL);
        p=mxGetPr(pargout[indexArgout++]);
        for (ii=0;ii<ls*usersNum;ii++) p[ii] = pin[ii];
        if (log) fprintf(stdout," p initialized \n"); 

        pargout[indexArgout]=mxCreateDoubleMatrix(ls,usersNum,mxREAL);
        z=mxGetPr(pargout[indexArgout++]);
        for (ii=0;ii<ls*usersNum;ii++) z[ii] = zin[ii];
        if (log) fprintf(stdout," z initialized \n");         
    }            
    if (log) fprintf(stdout," \n allocated %d outputs \n",indexArgout);    
    
    int count, u, i, j, k;
    int iii;
    int itemj;
    int numRatedItems, numRatingUsers;
    double puCoeff, zvCoeff;
    double *pu=(double*)calloc(ls, sizeof(double));
    double *zv=(double*)calloc(ls, sizeof(double)); 
    double *sum=(double*)calloc(ls, sizeof(double));
    double *sumUU=(double*)calloc(ls, sizeof(double));
    double cumerror=0.0, pseudoRMSE=0.0; 
    long numTests=0;
    int anomaliesCounter=0;
    const int maxAnomalies=100000;
    time_t t1,t2, t0;
    (void) time(&t0);
    for (count=0;count<iterations;count++) /* FOR count=1,#iterations DO */
    {   
	int numUsers=0;
        (void) time(&t1);
        cumerror=0.0;
        numTests = 0; 
        anomaliesCounter = 0;
        for (u=0;u<usersNum;u++) /* FOR u=1,..,m DO */
        {
            double errorUU=0;
            for (iii=0;iii<ls;iii++) pu[iii]=0.0; /* pu[ls] <- 0 */
            numRatedItems = (int) (Bp [u+1] - Bp [u]);
            if (numRatedItems==0) continue;
           
            /* compute the component independent of i*/
            for (j=Bp[u]; j<Bp[u+1]; j++)
            {   
                double ruj, biasi, xjk, yjk;
                itemj = Bi[j];
                ruj=Bx[j]; /* r_uj */
                
                biasi=bi_precomputed[itemj];
                puCoeff = (ruj - (mu + bu_precomputed[u] + biasi)) / (sqrt((double) numRatedItems)); /* |R(u)|^-1/2 * (r_uj - b_uj) */
                for (k=0;k<ls;k++) /* compute pu for each feature k*/
                {   
                    xjk = x[ls*itemj+k]; /* x[ls*itemj+k] = x[ls,itemj] */ 
                    yjk = y[ls*itemj+k]; /* y[ls*itemj+k] = y[ls,itemj] */
                    pu[k] = pu[k] + (puCoeff * xjk);
                    pu[k] = pu[k] + (yjk / (sqrt((double) numRatedItems)));
                }
            }
            for (iii=0;iii<ls;iii++) sum[iii]=0.0; /* sum[ls] <- 0 */
            if (useruser)
            {
                for (iii=0;iii<ls;iii++) sumUU[iii]=0.0; /* sumUU[ls] <- 0 */           
            }
            /* FOR ALL i (itemj) IN R(u) DO */
            for (j=Bp[u]; j<Bp[u+1]; j++)
            {   
                double r_hat_ui=0.0, e_ui;
                double biasi;
                itemj = Bi[j];
                if (useruser) /* if user-user is enabled */
                {
                    int useri;
                    numRatingUsers = Ap [itemj+1] - Ap [itemj]; /* |R(i)| */ 
                    for (iii=0;iii<ls;iii++) zv[iii]=0.0; /* zv[ls] <- 0 */
                    biasi = bi[itemj]; /* bias item j */
                    for (i=Ap[itemj]; i<Ap[itemj+1]; i++)
                    {   
                        double rvj, biasvj, zjk;
                        useri = Ai[i];
                        rvj=Ax[i];
                        
                        biasvj=bu[useri];
                        zvCoeff = (rvj - (mu + biasvj + biasi)) / (sqrt((double) numRatingUsers)); /* |R(i)|^-1/2 * (r_vj - b_vj) */                    
                        for (k=0;k<ls;k++) /* compute pu for each feature k*/
                        {   
                            zjk = z[ls*useri+k]; /* z[ls*useri+k] = z[ls,itemj] */                                                          
                            zv[k] += (zvCoeff * zjk);                         
                        }
                    }
                    for (k=0; k<ls; k++) /* p_u' * z_v */
                    {                    
                        r_hat_ui += ( p[ls*u+k] * zv[k] ); /* p_u(k) * zv(k) */                          
                    }  
                }

                for (k=0; k<ls; k++) /* q_i' * pu */
                {                
                    r_hat_ui += ( q[ls*itemj+k] * pu[k] ); /* q_i(k) * pu(k) */                  
                }
                r_hat_ui += (mu + bu[u] + bi[itemj]); /* r_hat_ui = mu + bu + bi + q_i'*pu */
                e_ui = Bx[j] - r_hat_ui; /* e_ui = r_ui - r_hat_ui */
                if (log>1) fprintf(verbose,"(%d,%d)=%f\n",u,itemj,e_ui);
                if (mxIsNaN(e_ui) || mxIsInf(e_ui) || absolute(e_ui)>100000) 
                {
                    fprintf(stdout, " -!- [%d] -!- user=%d, item=%d, r=%f, r_hat=%f, e_ui=%f  gradient error too large \n",anomaliesCounter,u,itemj,Bx[j],r_hat_ui,e_ui);
                    fprintf(stdout, "  biasu=%f, biasi=%f \n", bu[u], bi[itemj]);
                    if (log>1) fclose(verbose);
                    return;    
                }                
                if (absolute(e_ui)>7) 
                {
                    fprintf(stdout, " -!- [%d] -!- user=%d, item=%d, r=%f, r_hat=%f, e_ui=%f  gradient error too large \n",anomaliesCounter,u,itemj,Bx[j],r_hat_ui,e_ui);
                    fprintf(stdout, "  biasu=%f, biasi=%f \n", bu[u], bi[itemj]);
                    if (log>1) fclose(verbose);
                    anomaliesCounter++;
                    if (anomaliesCounter>maxAnomalies) return;    
                }
                cumerror += (e_ui*e_ui);
                numTests++;
                for (k=0; k<ls; k++) /* sum <- sum + e_ui * q_i */
                {
                    sum[k] += (e_ui*q[ls*itemj+k]); /* sum(k) = e_ui * q_i(k) */
                }
                if (useruser) /* sumUU <- sumUU + e_ui * p_u */
                {
                    for (k=0; k<ls; k++)
                    {
                        sumUU[k] += (e_ui*p[ls*u+k]); /* sumUU(k) = e_ui * p_u(k) */     
                    }
                }
                /* perform gradient step on qi, bu, bi  AND on "pu" if user-user model is enabled */
                bu[u] += (lrate * (e_ui - lambda*bu[u])); /* bu <- bu + gamma*(e_ui-lambda*bu) */        
                bi[itemj] += (lrate * (e_ui - lambda*bi[itemj])); /* bi <- bi + gamma*(e_ui-lambda*bi) */                                   
                for (k=0; k<ls; k++) 
                {
                    q[ls*itemj+k] += (lrate * (e_ui*pu[k] - lambda* q[ls*itemj+k])); /* q_i <- q_i + gamma*(e_ui*pu-lambda*q_i) */
                    if (useruser)
                    {
                        p[ls*u+k] += (lrate * (e_ui*zv[k] - lambda* p[ls*u+k])); /* p_u <- p_u + gamma*(e_ui*zv-lambda*p_u) */
                    }
                }                
            }
            /* FOR ALL i IN R(u) DO */
            for (j=Bp[u]; j<Bp[u+1]; j++) /* perform gradient step on xi*/
            {   
                itemj = Bi[j];
                double ruj = Bx[j];
                double biasi = bi_precomputed[itemj];
                puCoeff = (1/sqrt((double)numRatedItems)) * (ruj - (mu + bu_precomputed[u] + biasi)); /* |R(u)|^-1/2 * (r_ui - b_ui) */
                for (k=0; k<ls; k++)
                {
                    x[ls*itemj+k] += (lrate * ( puCoeff*sum[k] - lambda*x[ls*itemj+k] ));   /* update of every feature of xi */
                }   
                if (useruser)
                {
                    int useri;
                    numRatingUsers = Ap [itemj+1] - Ap [itemj]; /* |R(i)| */ 
                    /* FOR ALL useri IN R(i) DO */
                    for (i=Ap[itemj]; i<Ap[itemj+1]; i++) /* perform gradient step on zv*/
                    {   
                        double rvj = Ax[i];
                        double biasvj;
                        
                        useri = Ai[i]; /* we are looping on all useri who rated itemj*/
                        biasvj = bu[useri]; /* bias user v*/
    
                        zvCoeff = (1/sqrt((double)numRatingUsers)) * (rvj - (mu + biasvj + biasi)); /* |R(i)|^-1/2 * (r_vj - b_vj) */
                        for (k=0; k<ls; k++)
                        {
                            z[ls*useri+k] += (lrate * ( zvCoeff*sumUU[k] - lambda*z[ls*useri+k] ) );   /* update of every feature of zv */
                        }          
                    }            
                }                       
            }
            /* FOR ALL i IN N(u) DO */
            for (j=Bp[u]; j<Bp[u+1]; j++) /* perform gradient step on yi*/
            {   
                itemj = Bi[j];
                double ruj = Bx[j];
                puCoeff = (1/sqrt((double)numRatedItems)); /* |N(u)|^-1/2 */
                for (k=0; k<ls; k++)
                {
                    y[ls*itemj+k] += (lrate * ( puCoeff*sum[k] - lambda*y[ls*itemj+k] ) );   /* update of every feature of yi */
                }          
            }                   
            if (log && ( ((u-1) % 10000 == 0)) )
            {
                (void) time(&t2);
                printf("[%d] time for last group (up to user %d) is %d secs - remaining Time =%d secs\n", (int) (t2-t0), u, (int) (t2-t1), (int) ( ( (t2-t0)/((double) u))*((double)((usersNum-u)*(count+1)))));
                if ((((double) (t2-t1))/10000.0)>1.0) fprintf (stdout, "warning... high computing time");
                if (file_exists("~/stopnow")) return;
                (void) time(&t1);
            }

numUsers++;


        }

printf("Ci sono %d utenti\n",numUsers);
        pseudoRMSE = cumerror / ((double) numTests);
        if (log) 
        {   
            printf(" cumulative error iteration %d = %g (%d tests) \n", count, pseudoRMSE,numTests);
            if (file_exists("~/stopiter")) return;
        }
        if (mxIsNaN(pseudoRMSE))
        {
            fprintf(stdout, " -!- STOPPED -!- ");
            return;        
        }
    }
    if (log>1) fclose(verbose);
    
}

double absolute (double x)
{
    return (x>0 ? x : -x);
}

bool file_exists(const char * filename)
{
    FILE * file = fopen(filename, "r");
    if (file)
    {
        fclose(file);
        return true;
    }
    return false;
}

