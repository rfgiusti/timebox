#include "mex.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define min(x,y) ((x)<(y)?(x):(y))
#define max(x,y) ((x)>(y)?(x):(y))
#define inf 1e20

// Euclidean Distance of 2 values
double dist(double x, double y) 
{   return (x-y)*(x-y);
}

double dtw(double* A, double* B, int m, int n, int r)
{       
    //int r = (int)(ceil(min(m,n)*0.1));
        
    if (abs(m-n) > r)       return -1; 
   
    double *cost;
    double *cost_prev;
    double *cost_tmp;
    int i,j,k;
    double x,y,z;
    
    cost = (double*)malloc(sizeof(double)*(2*r+1));                
    for(k=0; k<2*r+1; k++)    cost[k]=inf;
                    
    cost_prev = (double*)malloc(sizeof(double)*(2*r+1));                
    for(k=0; k<2*r+1; k++)    cost_prev[k]=inf;
        
    for (i=0; i<m; i++)
    {   k = max(0,r-i);
        for(j=max(0,i-r); j<=min(n-1,i+r); j++)
        {   
            if ((i==0)&&(j==0)) 
            {   cost[r]=dist(A[0],B[0]);
                k++;              
                continue;
            }            
            if ((j-1<0)||(k-1<0))     y = inf;
            else                      y = cost[k-1];
            if ((i-1<0)||(k+1>2*r))   x = inf;
            else                      x = cost_prev[k+1];
            if ((i-1<0)||(j-1<0))     z = inf;
            else                      z = cost_prev[k];

            //printf("[%d,%d], k:%d, r=%d, x:%d, y:%d, z:%d\n",i,j,k,r,(int)x,(int)y,(int)z);
                    
            cost[k] = min( min( x, y) , z) + dist(A[i],B[j]);            
            k++;  
        }
        
        cost_tmp = cost;
        cost = cost_prev;
        cost_prev = cost_tmp;
        //for(int i=0; i<2*r+1; i++)  printf("%8d ",(int)cost_prev[i]);  printf("\n");
    }
    
    k--;
    //printf("cost_prev[%d]=%d\n",k,(int)cost_prev[k]);
    double final_dtw = sqrt(cost_prev[k]);
    free(cost);
    free(cost_prev);

    return final_dtw;    
}


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double  mwSize, a_nrows,a_ncols,b_nrows,b_ncols;
  
  /* Check for proper number of arguments. */
  if(nrhs!=3) {
    printf("");
    printf("      ");
    mexErrMsgTxt("Three inputs required. \nExample of usage:\n\tdist = DTW(TS1, TS2, r)\n");
  } 
  else if(nlhs>1) {
    mexErrMsgTxt("At most one output required.");
  }
  
  /* The input must be a noncomplex scalar double.*/
  a_nrows = mxGetM(prhs[0]);
  a_ncols = mxGetN(prhs[0]);
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      !(a_nrows==1) ) {
    mexErrMsgTxt("First input (TS) must be a noncomplex row array double.");            
  }
  
  b_nrows = mxGetM(prhs[0]);
  b_ncols = mxGetN(prhs[0]);  
  if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[0]) ||
      !(b_nrows==1) ) {
    mexErrMsgTxt("Second input (Mark) must be a noncomplex row array double.");
  }  
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
  
  /* Assign pointers to each input and output. */
  double *A, *B, *In3, *Out;
  A = mxGetPr(prhs[0]);     // TS1
  B = mxGetPr(prhs[1]);     // TS2
  In3 = mxGetPr(prhs[2]);     // TS2
  
  Out = mxGetPr(plhs[0]);      // Motif = [bsf, index1, index2]
    
  int m = (int)a_ncols;
  int n = (int)b_ncols;
  int r = (int)(*In3);

    
  double d = dtw(A,B,m,n,r);    
  Out[0] = d;
}
