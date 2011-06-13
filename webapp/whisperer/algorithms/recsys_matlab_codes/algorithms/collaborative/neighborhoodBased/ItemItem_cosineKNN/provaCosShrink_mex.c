#include "cs_mex.h"
#include <stdio.h>

#define log 0 
/* 
    [C, [E]] = provaCosShrink (A,B), computes shrank COS(A,B), where A and B must be sparse.
        E is a matrix contaninng the number of common elements
*/
void mexFunction
(
    int nargout,
    mxArray *pargout [ ],
    int nargin,
    const mxArray *pargin [ ]
)
{
    CS_INT modeAllElement ;
    if (nargout > 2 || nargin < 2 || nargin > 2)
    {
        mexErrMsgTxt ("Usage: [C, [E]] = provaCosShrink (A,B)") ;
    }

    cs_dl Amatrix, Bmatrix, *A, *B, *C;
    A = cs_dl_mex_get_sparse (&Amatrix, 0, 1, pargin [0]) ; /* get A */
    B = cs_dl_mex_get_sparse (&Bmatrix, 0, 1, pargin [1]) ; /* get B */

    UF_long i, p, pp, Am, An, Anzmax, Anz, *Ap, *Ai ; 
    UF_long j, q, qq, Bm, Bn, Bnzmax, Bnz, *Bp, *Bi ;
    double *Ax, *Bx;
    if (!A || !B) { if (log) printf ("(null)\n") ; return  ; }
   	Am = A->m ; 	An = A->n ; 	Ap = A->p ; 	Ai = A->i ; Ax = A->x ;	Anzmax = A->nzmax ; Anz = A->nz ;
   	Bm = B->m ; 	Bn = B->n ; 	Bp = B->p ; 	Bi = B->i ; Bx = B->x ;	Bnzmax = B->nzmax ; Bnz = B->nz ;
    if (log) fprintf(stdout,"A: mxn = %dx%d\n",Am,An);	
    if (log) fprintf(stdout,"B: mxn = %dx%d\n",Bm,Bn);	


    /* allocate result */       
    cs *corrMatrix = cs_spalloc (An, Bn, An*Bn, 1, 1) ;                    
    cs *commonElementMatrix = cs_spalloc (An, Bn, An*Bn, 1, 1) ;
     
    for (i = 0 ; i < An ; i++)
    {
        for (j = 0 ; j < Bn ; j++)
        {    
            p=Ap[i];
            q=Bp[j];
            pp = Ap[i+1];
            qq = Bp[j+1];                               
            
            /* cosine on common elements*/
            double corr;
            double corrNum=0, corrDenA=0, corrDenB=0;
            double entryA, entryB;            
            
            p=Ap[i];
            q=Bp[j];
            pp = Ap[i+1];
            qq = Bp[j+1];
            
            long countCommonElements=0;    
            while (pp && qq && p<pp && q<qq)
            {         
                if (Ai[p]==Bi[q])
                {     
                    entryA=Ax[p];
                    entryB=Bx[q];   
                    corrDenA += entryA*entryA;
                    corrDenB += entryB*entryB;                    
                    corrNum += entryA * entryB;                     
                    p++;
                    q++;
                    countCommonElements++;
                    /* values Ax[p] and Bx[q] referring to the same row */ 
                }
                else if (Ai[p]>Bi[q])
                {
                    entryB=Bx[q];
                    corrDenB += entryB*entryB;
                    q++;
                }
                else
                {
                    entryA=Ax[p];
                    corrDenA += entryA*entryA;                    
                    p++;
                }
            }

            while (p<pp) 
            {
                entryA=Ax[p++];
                corrDenA += entryA*entryA;                    
            }
            while (q<qq) 
            {
                entryB=Bx[q++];
                corrDenB += entryB*entryB;
            }
                
/*            fprintf(stdout,"corrNum=%f, corrDenA=%f, corrDenB=%f\n",corrNum,corrDenA,corrDenB);  */
            corrDenA = (corrDenA==0) ? 1 : corrDenA;
            corrDenB = (corrDenB==0) ? 1 : corrDenB; 
            corr = corrNum / (sqrt(corrDenA*corrDenB)); 
/*            fprintf(stdout,"corr(%d,%d)=%f\n",i,j,corr); */
            cs_entry(corrMatrix,i,j,corr);
            cs_entry(commonElementMatrix,i,j,countCommonElements);
        }
    }
    
        if (log) fprintf(stdout,"provaCosShrink: outputing computed matrices \n");
        corrMatrix=cs_compress(corrMatrix);
        pargout [0] = cs_dl_mex_put_sparse (&corrMatrix) ;               /* return C */
        if (nargout>1) 
        {
            commonElementMatrix=cs_compress(commonElementMatrix);
            pargout [1] = cs_dl_mex_put_sparse (&commonElementMatrix) ;               /* return E */
        }

}
