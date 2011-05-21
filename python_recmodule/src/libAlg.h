/*
 * MATLAB Compiler: 4.15 (R2011a)
 * Date: Sat May 21 16:13:59 2011
 * Arguments: "-B" "macro_default" "-W" "lib:libAlg" "-T" "link:lib" "-d"
 * "/home/goshawk/Matlab/bin/libAlg/src" "-w" "enable:specified_file_mismatch"
 * "-w" "enable:repeated_file" "-w" "enable:switch_ignored" "-w"
 * "enable:missing_lib_sentinel" "-w" "enable:demo_license" "-v"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_pearsonKoren/computePearsonSimilarity.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/latentFactors/AsySV
 * D/createModel_AsySVD.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_cosine/createModel_cosine_II.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_cosineKNN/createModel_cosineIIknn.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/content-based/directContent_knn/c
 * reateModel_directContent_knn.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_dr/createModel_drII.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_drKNN/createModel_drIIknn.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/content-based/lsaCosine/createMod
 * el_lsaCosine.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/non-personalized/movieAvg/createM
 * odel_movieAvg.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_pearsonKoren/createModel_pearsonIIkoren.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/latentFactors/pureS
 * VD/createModel_pureSVD.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/non-personalized/random/createMod
 * el_random.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/non-personalized/topRated/createM
 * odel_toprated.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/latentFactors/AsySV
 * D/learnFactorModelRabosio.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/content-based/normalizeICMwithIDF
 * .m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_cosineKNN/onLineRecom__CosNgbr_II_knn.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/latentFactors/AsySV
 * D/onLineRecom_AsySVD.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_cosine/onLineRecom_CosNgbr_II.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/content-based/directContent_knn/o
 * nLineRecom_directContent_knn.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_dr/onLineRecom_drII.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_drKNN/onLineRecom_drIIknn.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/content-based/lsaCosine/onLineRec
 * om_lsa_Cosine.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/content-based/lsaCosine/onLineRec
 * om_lsa_NNCosine.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/non-personalized/movieAvg/onLineR
 * ecom_movieAvg.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_cosine/onLineRecom_NNCosNgbr_II.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_cosineKNN/onLineRecom_NNCosNgbr_II_knn.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_pearsonKoren/onLineRecom_pearsonIIkoren.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/latentFactors/pureS
 * VD/onLineRecom_pureSVD.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/non-personalized/random/onLineRec
 * om_random.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/non-personalized/topRated/onLineR
 * ecom_toprated.m"
 * "/home/goshawk/Matlab/bin/RecSys/algorithms/collaborative/neighborhoodBased/I
 * temItem_pearsonKoren/pearsonCoeff.m" 
 */

#ifndef __libAlg_h
#define __libAlg_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__SUNPRO_CC)
/* Solaris shared libraries use __global, rather than mapfiles
 * to define the API exported from a shared library. __global is
 * only necessary when building the library -- files including
 * this header file to use the library do not need the __global
 * declaration; hence the EXPORTING_<library> logic.
 */

#ifdef EXPORTING_libAlg
#define PUBLIC_libAlg_C_API __global
#else
#define PUBLIC_libAlg_C_API /* No import statement needed. */
#endif

#define LIB_libAlg_C_API PUBLIC_libAlg_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_libAlg
#define PUBLIC_libAlg_C_API __declspec(dllexport)
#else
#define PUBLIC_libAlg_C_API __declspec(dllimport)
#endif

#define LIB_libAlg_C_API PUBLIC_libAlg_C_API


#else

#define LIB_libAlg_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_libAlg_C_API 
#define LIB_libAlg_C_API /* No special import/export declaration */
#endif

extern LIB_libAlg_C_API 
bool MW_CALL_CONV libAlgInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV libAlgInitialize(void);

extern LIB_libAlg_C_API 
void MW_CALL_CONV libAlgTerminate(void);



extern LIB_libAlg_C_API 
void MW_CALL_CONV libAlgPrintStackTrace(void);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxComputePearsonSimilarity(int nlhs, mxArray *plhs[], int nrhs, 
                                              mxArray *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_AsySVD(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                        *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_cosine_II(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                           *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_cosineIIknn(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                             *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_directContent_knn(int nlhs, mxArray *plhs[], int nrhs, 
                                                   mxArray *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_drII(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                      *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_drIIknn(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                         *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_lsaCosine(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                           *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_movieAvg(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                          *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_pearsonIIkoren(int nlhs, mxArray *plhs[], int nrhs, 
                                                mxArray *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_pureSVD(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                         *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_random(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                        *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxCreateModel_toprated(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                          *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxLearnFactorModelRabosio(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                             *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxNormalizeICMwithIDF(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                         *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom__CosNgbr_II_knn(int nlhs, mxArray *plhs[], int nrhs, 
                                                 mxArray *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_AsySVD(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                        *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_CosNgbr_II(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                            *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_directContent_knn(int nlhs, mxArray *plhs[], int nrhs, 
                                                   mxArray *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_drII(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                      *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_drIIknn(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                         *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_lsa_Cosine(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                            *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_lsa_NNCosine(int nlhs, mxArray *plhs[], int nrhs, 
                                              mxArray *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_movieAvg(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                          *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_NNCosNgbr_II(int nlhs, mxArray *plhs[], int nrhs, 
                                              mxArray *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_NNCosNgbr_II_knn(int nlhs, mxArray *plhs[], int nrhs, 
                                                  mxArray *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_pearsonIIkoren(int nlhs, mxArray *plhs[], int nrhs, 
                                                mxArray *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_pureSVD(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                         *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_random(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                        *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxOnLineRecom_toprated(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                          *prhs[]);

extern LIB_libAlg_C_API 
bool MW_CALL_CONV mlxPearsonCoeff(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libAlg_C_API 
long MW_CALL_CONV libAlgGetMcrID();



extern LIB_libAlg_C_API bool MW_CALL_CONV mlfComputePearsonSimilarity(int nargout, mxArray** II, mxArray* URM, mxArray* knn, mxArray* lambdaS, mxArray* Cdisabled);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_AsySVD(int nargout, mxArray** model, mxArray* URM, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_cosine_II(int nargout, mxArray** model, mxArray* URM, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_cosineIIknn(int nargout, mxArray** model, mxArray* URM, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_directContent_knn(int nargout, mxArray** model, mxArray* URM, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_drII(int nargout, mxArray** model, mxArray* URM, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_drIIknn(int nargout, mxArray** model, mxArray* URM, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_lsaCosine(int nargout, mxArray** model, mxArray* URM, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_movieAvg(int nargout, mxArray** model, mxArray* URM, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_pearsonIIkoren(int nargout, mxArray** model, mxArray* URM, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_pureSVD(int nargout, mxArray** model, mxArray* URM, mxArray* modelParam);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_random(int nargout, mxArray** model, mxArray* URM, mxArray* modelParam);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfCreateModel_toprated(int nargout, mxArray** model, mxArray* URM, mxArray* modelParam);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfLearnFactorModelRabosio(int nargout, mxArray** bu, mxArray** bi, mxArray** q, mxArray** x, mxArray** y, mxArray* urm, mxArray* mu, mxArray* bu_precomputed, mxArray* bi_precomputed, mxArray* bu_in1, mxArray* bi_in1, mxArray* iterations, mxArray* lrate, mxArray* lambda, mxArray* q_in1, mxArray* x_in1, mxArray* y_in1);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfNormalizeICMwithIDF(int nargout, mxArray** icm_idf, mxArray* icm);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom__CosNgbr_II_knn(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_AsySVD(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_CosNgbr_II(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_directContent_knn(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_drII(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_drIIknn(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_lsa_Cosine(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_lsa_NNCosine(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_movieAvg(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_NNCosNgbr_II(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_NNCosNgbr_II_knn(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_pearsonIIkoren(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_pureSVD(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_random(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfOnLineRecom_toprated(int nargout, mxArray** recomList, mxArray* userProfile, mxArray* model, mxArray* param);

extern LIB_libAlg_C_API bool MW_CALL_CONV mlfPearsonCoeff(int nargout, mxArray** C, mxArray** E, mxArray* A, mxArray* B, mxArray* mode);

#ifdef __cplusplus
}
#endif
#endif
