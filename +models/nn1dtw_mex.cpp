/* This file is part of TimeBox.
 * TimeBox is copyright protected (C) 2016 by Rafael Giusti
 *
 * This is a modified version of the UCR Suite for use with TimeBox.
 * The UCR Suite copyright disclaimer is transcribed below.
 *
 * Please see THIRD-PARTY.txt for the UCR Suite license.
 */



/***********************************************************************/
/************************* DISCLAIMER **********************************/
/***********************************************************************/
/** This UCR Suite software is copyright protected (C) 2012 by        **/
/** Thanawin Rakthanmanon, Bilson Campana, Abdullah Mueen,            **/
/** Gustavo Batista and Eamonn Keogh.                                 **/
/**                                                                   **/
/** Unless stated otherwise, all software is provided free of charge. **/
/** As well, all software is provided on an "as is" basis without     **/
/** warranty of any kind, express or implied. Under no circumstances  **/
/** and under no legal theory, whether in tort, contract,or otherwise,**/
/** shall Thanawin Rakthanmanon, Bilson Campana, Abdullah Mueen,      **/
/** Gustavo Batista, or Eamonn Keogh be liable to you or to any other **/
/** person for any indirect, special, incidental, or consequential    **/
/** damages of any character including, without limitation, damages   **/
/** for loss of goodwill, work stoppage, computer failure or          **/
/** malfunction, or for any and all other damages or losses.          **/
/**                                                                   **/
/** If you do not agree with these terms, then you you are advised to **/
/** not use this software.                                            **/
/***********************************************************************/
/***********************************************************************/

#include "mex.h"

#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <ctime>
#include <iostream>

#define min(x,y) ((x)<(y)?(x):(y))
#define max(x,y) ((x)>(y)?(x):(y))
#define dist(x,y) ((x-y)*(x-y))

#define INF 1e20       //Pseudo Infitinte number for this code

using namespace std;

/// Data structure for sorting the query
typedef struct Index {
	double value;
	int    index;
} Index;

/// Data structure (circular array) for finding minimum and maximum for LB_Keogh envolop
struct deque {
	int *dq;
	int size,capacity;
	int f,r;
};


/// Sorting function for the query, sort by abs(z_norm(q[i])) from high to low
int comp(const void *a, const void* b)
{
	Index* x = (Index*)a;
	Index* y = (Index*)b;
	return abs(y->value) - abs(x->value);   // high to low
}

/// Initial the queue at the begining step of envelop calculation
void init(deque *d, int capacity)
{
	d->capacity = capacity;
	d->size = 0;
	d->dq = (int *) malloc(sizeof(int)*d->capacity);
	d->f = 0;
	d->r = d->capacity-1;
}

/// Destroy the queue
void destroy(deque *d)
{
	free(d->dq);
}

/// Insert to the queue at the back
void push_back(struct deque *d, int v)
{
	d->dq[d->r] = v;
	d->r--;
	if (d->r < 0)
		d->r = d->capacity-1;
	d->size++;
}

/// Delete the current (front) element from queue
void pop_front(struct deque *d)
{
	d->f--;
	if (d->f < 0)
		d->f = d->capacity-1;
	d->size--;
}

/// Delete the last element from queue
void pop_back(struct deque *d)
{
	d->r = (d->r+1)%d->capacity;
	d->size--;
}

/// Get the value at the current position of the circular queue
int front(struct deque *d)
{
	int aux = d->f - 1;

	if (aux < 0)
		aux = d->capacity-1;
	return d->dq[aux];
}

/// Get the value at the last position of the circular queueint back(struct deque *d)
int back(struct deque *d)
{
	int aux = (d->r+1)%d->capacity;
	return d->dq[aux];
}

/// Check whether or not the queue is empty
int empty(struct deque *d)
{
	return d->size == 0;
}

/// Finding the envelop of min and max value for LB_Keogh
/// Implementation idea is intoruduced by Danial Lemire in his paper
/// "Faster Retrieval with a Two-Pass Dynamic-Time-Warping Lower Bound", Pattern Recognition 42(9), 2009.
void lower_upper_lemire(double *t, int len, int r, double *l, double *u)
{
	struct deque du, dl;

	init(&du, 2*r+2);
	init(&dl, 2*r+2);

	push_back(&du, 0);
	push_back(&dl, 0);

	for (int i = 1; i < len; i++) {
		if (i > r) {
			u[i-r-1] = t[front(&du)];
			l[i-r-1] = t[front(&dl)];
		}
		if (t[i] > t[i-1]) {
			pop_back(&du);
			while (!empty(&du) && t[i] > t[back(&du)])
				pop_back(&du);
		}
		else {
			pop_back(&dl);
			while (!empty(&dl) && t[i] < t[back(&dl)])
				pop_back(&dl);
		}
		push_back(&du, i);
		push_back(&dl, i);
		if (i == 2 * r + 1 + front(&du))
			pop_front(&du);
		else if (i == 2 * r + 1 + front(&dl))
			pop_front(&dl);
	}
	for (int i = len; i < len+r+1; i++) {
		u[i-r-1] = t[front(&du)];
		l[i-r-1] = t[front(&dl)];
		if (i-front(&du) >= 2 * r + 1)
			pop_front(&du);
		if (i-front(&dl) >= 2 * r + 1)
			pop_front(&dl);
	}
	destroy(&du);
	destroy(&dl);
}

/// Calculate quick lower bound
/// Usually, LB_Kim take time O(m) for finding top,bottom,fist and last.
/// However, because of z-normalization the top and bottom cannot give siginifant benefits.
/// And using the first and last points can be computed in constant time.
/// The prunning power of LB_Kim is non-trivial, especially when the query is not long, say in length 128.
double lb_kim_hierarchy(double *t, double *q, int j, int len, double mean, double std, double bsf = INF)
{
	/// 1 point at front and back
	double d, lb;
	double x0 = (t[j] - mean) / std;
	double y0 = (t[(len-1+j)] - mean) / std;
	lb = dist(x0,q[0]) + dist(y0,q[len-1]);
	if (lb >= bsf)
		return lb;

	/// 2 points at front
	double x1 = (t[(j+1)] - mean) / std;
	d = min(dist(x1,q[0]), dist(x0,q[1]));
	d = min(d, dist(x1,q[1]));
	lb += d;
	if (lb >= bsf)
		return lb;

	/// 2 points at back
	double y1 = (t[(len-2+j)] - mean) / std;
	d = min(dist(y1,q[len-1]), dist(y0, q[len-2]) );
	d = min(d, dist(y1,q[len-2]));
	lb += d;
	if (lb >= bsf)
		return lb;

	/// 3 points at front
	double x2 = (t[(j+2)] - mean) / std;
	d = min(dist(x0,q[2]), dist(x1, q[2]));
	d = min(d, dist(x2,q[2]));
	d = min(d, dist(x2,q[1]));
	d = min(d, dist(x2,q[0]));
	lb += d;
	if (lb >= bsf)
		return lb;

	/// 3 points at back
	double y2 = (t[(len-3+j)] - mean) / std;
	d = min(dist(y0,q[len-3]), dist(y1, q[len-3]));
	d = min(d, dist(y2,q[len-3]));
	d = min(d, dist(y2,q[len-2]));
	d = min(d, dist(y2,q[len-1]));
	lb += d;

	return lb;
}

/// LB_Keogh 1: Create Envelop for the query
/// Note that because the query is known, envelop can be created once at the begenining.
///
/// Variable Explanation,
/// order : sorted indices for the query.
/// uo, lo: upper and lower envelops for the query, which already sorted.
/// t     : a circular array keeping the current data.
/// j     : index of the starting location in t
/// cb    : (output) current bound at each position. It will be used later for early abandoning in DTW.
double lb_keogh_cumulative(int* order, double *t, double *uo, double *lo, double *cb, int j, int len, double mean, double std, double best_so_far = INF)
{
	double lb = 0;
	double x, d;

	for (int i = 0; i < len && lb < best_so_far; i++) {
		x = (t[(order[i]+j)] - mean) / std;
		d = 0;
		if (x > uo[i])
			d = dist(x,uo[i]);
		else if(x < lo[i])
			d = dist(x,lo[i]);
		lb += d;
		cb[order[i]] = d;
	}
	return lb;
}

/// LB_Keogh 2: Create Envelop for the data
/// Note that the envelops have been created (in main function) when each data point has been read.
///
/// Variable Explanation,
/// tz: Z-normalized data
/// qo: sorted query
/// cb: (output) current bound at each position. Used later for early abandoning in DTW.
/// l,u: lower and upper envelop of the current data
double lb_keogh_data_cumulative(int* order, double *tz, double *qo, double *cb, double *l, double *u, int len, double mean, double std, double best_so_far = INF)
{
	double lb = 0;
	double uu,ll,d;

	for (int i = 0; i < len && lb < best_so_far; i++) {
		uu = (u[order[i]]-mean)/std;
		ll = (l[order[i]]-mean)/std;
		d = 0;
		if (qo[i] > uu)
			d = dist(qo[i], uu);
		else {
			if(qo[i] < ll)
				d = dist(qo[i], ll);
		}
		lb += d;
		cb[order[i]] = d;
	}
	return lb;
}

/// Calculate Dynamic Time Wrapping distance
/// A,B: data and query, respectively
/// cb : cummulative bound used for early abandoning
/// r  : size of Sakoe-Chiba warpping band
double dtw(double* A, double* B, double *cb, int m, int r, double bsf = INF)
{

	double *cost;
	double *cost_prev;
	double *cost_tmp;
	int i,j,k;
	double x,y,z,min_cost;

	/// Instead of using matrix of size O(m^2) or O(mr), we will reuse two array of size O(r).
	cost = (double*)malloc(sizeof(double)*(2*r+1));
	for(k=0; k<2*r+1; k++)
		cost[k]=INF;

	cost_prev = (double*)malloc(sizeof(double)*(2*r+1));
	for(k=0; k<2*r+1; k++)
		cost_prev[k]=INF;

	for (i=0; i<m; i++)
	{
		k = max(0,r-i);
		min_cost = INF;

		for(j=max(0,i-r); j<=min(m-1,i+r); j++, k++) {
			/// Initialize all row and column
			if ((i==0)&&(j==0)) {
				cost[k]=dist(A[0],B[0]);
				min_cost = cost[k];
				continue;
			}

			if ((j-1<0)||(k-1<0))     y = INF;
			else                      y = cost[k-1];
			if ((i-1<0)||(k+1>2*r))   x = INF;
			else                      x = cost_prev[k+1];
			if ((i-1<0)||(j-1<0))     z = INF;
			else                      z = cost_prev[k];

			/// Classic DTW calculation
			cost[k] = min( min( x, y) , z) + dist(A[i],B[j]);

			/// Find minimum cost in row for early abandoning (possibly to use column instead of row).
			if (cost[k] < min_cost) {
				min_cost = cost[k];
			}
		}

		/// We can abandon early if the current cummulative distace with lower bound together are larger than bsf
		if (i+r < m-1 && min_cost + cb[i+r+1] >= bsf) {
			free(cost);
			free(cost_prev);
			return min_cost + cb[i+r+1];
		}

		/// Move current array to previous array.
		cost_tmp = cost;
		cost = cost_prev;
		cost_prev = cost_tmp;
	}
	k--;

	/// the DTW distance is in the last cell in the matrix of size O(m^2) or at the middle of our array.
	double final_dtw = cost_prev[k];
	free(cost);
	free(cost_prev);
	return final_dtw;
}

/// Print function for debugging
void printArray(double *x, int len)
{
	for(int i=0; i<len; i++)
		printf(" %6.2lf",x[i]);
	printf("\n");
}

/// If expected error happens, teminated the program.
void error(int id)
{
	if(id==1)
		printf("ERROR : Memory can't be allocated!!!\n\n");
	else if ( id == 2 )
		printf("ERROR : File not Found!!!\n\n");
	else if ( id == 3 )
		printf("ERROR : Can't create Output File!!!\n\n");
	else if ( id == 4 ) {
		printf("ERROR : Invalid Number of Arguments!!!\n");
		printf("Command Usage:  UCR_DTW.exe  data-file  query-file   m   R\n\n");
		printf("For example  :  UCR_DTW.exe  data.txt   query.txt   128  0.05\n");
	}
	exit(1);
}

/// Main Function
void ucrsuite_main(int &neighbor, double &distance, int &pruned, double *stack, double *q, int len, double r)
{
	double bsf;          /// best-so-far
	int *order;          ///new order of the query
	double *u, *l, *qo, *uo, *lo,*cb, *cb1, *cb2,*u_d, *l_d;

	double d;
	long long i , j;
	int m=-1, r=-1;
	long long loc = 0;
	double t1,t2;
	int kim = 0,keogh = 0, keogh2 = 0;
	double dist=0, lb_kim=0, lb_k=0, lb_k2=0;
	double *series, *upper_lemire, *lower_lemire;
	Index *Q_tmp;

	/// malloc everything here
	qo = (double *)malloc(sizeof(double)*m);
	if( qo == NULL )
		error(1);
	uo = (double *)malloc(sizeof(double)*m);
	if( uo == NULL )
		error(1);
	lo = (double *)malloc(sizeof(double)*m);
	if( lo == NULL )
		error(1);

	order = (int *)malloc(sizeof(int)*m);
	if( order == NULL )
		error(1);

	Q_tmp = (Index *)malloc(sizeof(Index)*m);
	if( Q_tmp == NULL )
		error(1);

	u = (double *)malloc(sizeof(double)*m);
	if( u == NULL )
		error(1);

	l = (double *)malloc(sizeof(double)*m);
	if( l == NULL )
		error(1);

	cb = (double *)malloc(sizeof(double)*m);
	if( cb == NULL )
		error(1);

	cb1 = (double *)malloc(sizeof(double)*m);
	if( cb1 == NULL )
		error(1);

	cb2 = (double *)malloc(sizeof(double)*m);
	if( cb2 == NULL )
		error(1);

	u_d = (double *)malloc(sizeof(double)*m);
	if( u == NULL )
		error(1);

	l_d = (double *)malloc(sizeof(double)*m);
	if( l == NULL )
		error(1);

	upper_lemire = (double *)malloc(sizeof(double)*m);
	if( upper_lemire == NULL )
		error(1);

	lower_lemire = (double *)malloc(sizeof(double)*m);
	if( lower_lemire == NULL )
		error(1);


	bsf = INF;

	/// Create envelop of the query: lower envelop, l, and upper envelop, u
	lower_upper_lemire(q, m, r, l, u);

	/// Sort the query one time by abs(z-norm(q[i]))
	for( i = 0; i<m; i++) {
		Q_tmp[i].value = q[i];
		Q_tmp[i].index = i;
	}
	qsort(Q_tmp, m, sizeof(Index),comp);

	/// also create another arrays for keeping sorted envelop
	for( i=0; i<m; i++) {
		int o = Q_tmp[i].index;
		order[i] = o;
		qo[i] = q[o];
		uo[i] = u[o];
		lo[i] = l[o];
	}
	free(Q_tmp);

	/// Initial the cummulative lower bound
	for( i=0; i<m; i++) {
		cb[i]=0;
		cb1[i]=0;
		cb2[i]=0;
	}

	int it=0, k=0;

	//start with the first series
	series = stack;

	while(1) {
		it++;

		lower_upper_lemire(series, m, r, lower_lemire, upper_lemire);

		/// Use a constant lower bound to prune the obvious subsequence
		lb_kim = lb_kim_hierarchy(series, q, 0, m, 0, 1, bsf);

		if (lb_kim < bsf) {
			/// Use a linear time lower bound to prune
			/// uo, lo are envelop of the query.
			lb_k = lb_keogh_cumulative(order, series, uo, lo, cb1, 0, m, 0, 1, bsf);
			if (lb_k < bsf) {
				/// Use another lb_keogh to prune
				/// qo is the sorted query. tz is unsorted z_normalized data.
				lb_k2 = lb_keogh_data_cumulative(order, series, qo, cb2, lower_lemire, upper_lemire, m, 0, 1, bsf);
				if (lb_k2 < bsf) {
					/// Choose better lower bound between lb_keogh and lb_keogh2 to be used in early abandoning DTW
					/// Note that cb and cb2 will be cumulative summed here.
					if (lb_k > lb_k2) {
						cb[m-1]=cb1[m-1];
						for(k=m-2; k>=0; k--)
							cb[k] = cb[k+1]+cb1[k];
					}
					else {
						cb[m-1]=cb2[m-1];
						for(k=m-2; k>=0; k--)
							cb[k] = cb[k+1]+cb2[k];
					}

					/// Compute DTW and early abandoning if possible
					dist = dtw(series, q, cb, m, r, bsf);

					if( dist < bsf ) {
						/// Update bsf
						// loc is the index of the nearest neighbor
						bsf = dist;
						neighbor = it;
					}
				} else
					pruned++;
			} else
				pruned++;
		} else
			pruned++;


		// point to the next series in the data set
		series += len;
	}

endsearch:
	i = it;

	free(q);
	free(u);
	free(l);
	free(uo);
	free(lo);
	free(qo);
	free(cb);
	free(cb1);
	free(cb2);
	free(l_d);
	free(u_d);
	free(lower_lemire);
	free(upper_lemire);

	dist = sqrt(bsf);
}

void mexFunction(int nleft, mxArray *left[], int nright, const mxArray *right)
{
	int neighbor;
	double distance;
	int pruned;

	double *stack;
	double *needle;
	int len;
	int r;

	if (nright != 4) {
		mexErrMsgTxt("Three inputs expected\n");
	}


	/* First argument is the training data set: it must be a non-complex
	 * matrix of double
	 */
	len = mxGetM(right[0]);
	if (!mxIsDouble(right[0]) || mxIsComplex(right[0]) || len < 1) {
		mexErrMsgTxt("First input argument (STACK) must be a "
				"non-complex matrix of DOUBLE");
	}
	stack = mxGetPr(right[0]);

	/* Second argument is the needle: it must be a non-complex row vector
	 * with appropriate number of elements
	 */
	if (!mxIsDouble(right[1]) || mxIsComplex(right[1]) ||
			mxGetNumberofElements(right[1] != len)) {
		mexErrMsgTxt("Second input argument (NEEDLE) must be a "
				"non-complex vector of DOUBLE with as many "
				"elements as the number of observations in "
				"the STACK");
	}
	needle = mxGetPr(right[1]);

	/* Third argument is the Sakoe-Chiba window size
	 */
	if (!mxIsDouble(right[2]) || mxIsComplex(right[2]) ||
			mxGetNumberofElements(right[2]) != 1) {
		mexErrMsgTxt("Third input argument (r) must be a non-complex "
				"DOUBLE scalar");
	}
}
