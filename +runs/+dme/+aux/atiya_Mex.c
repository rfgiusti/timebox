#include "mex.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdio.h>

#define INITIAL_WEIGHTS		0.5
#define MINMAX_WEIGH_DIFF	1e-5
#define MAX_ITERATIONS		1000000
#define NI			0.1
#define EPS			1e-8

#define DEBUG			0
#define debug(...)		do { \
		if (DEBUG) { \
			fprintf(__debug_file, __VA_ARGS__); } \
			fflush(__debug_file); \
	} while (0)
#if DEBUG
#	define mexErrMsgIdAndTxt(...) do { \
		fclose(__debug_file); \
		mexErrMsgIdAndTxt(__VA_ARGS__); \
	} while (0)
#endif

FILE *__debug_file;


/* Implement the iteration part of "Atiya 2005, Estimating the Posterior
 * Probabilities Using the K-Nearest Neighbor Rule"
 */

#define MYID 		"atiya_Mex"
#define INERR		MYID ":InputChk"
#define OUTERR		MYID ":OutputChk"
#define EXPECTEDARGS 	"Expected arguments are training classes, neighbor "   \
			"classes, neighborhood size k, total number of "       \
			"dataset instances, number of unique classes"


double stepweight(const double *oldweights, int **matchingneighbors,
		const int size, const int k, const int numclasses,
		const double sum_w, const int currentweight)
{
	int n, i;
	double sum_m, match_w;
	double frac = 1.0 / numclasses;
	double step = 0;

#if DEBUG
	debug("w%d -> {", currentweight + 1);
	debug("%e", oldweights[0]);
	for (i = 1; i <= k; i++) {
		debug(",%e", oldweights[i]);
	}
	debug("} -> (");
#endif

	for (n = 0; n < size; n++) {
#if DEBUG
		if (n) {
			debug(" + ");
		}
#endif

		/* Each weight refers to a level "k" of the k-nearest neighbor.
		 * currentweight == 1 means nearest neighbor, currentweight == 2
		 * means second-nearest neighbor and so forth. Exception goes
		 * for currentweight == k, which is a "virtual" neighbor. If
		 * the class of currentweight-nearest neighbor of n matches the
		 * class of n, or if this is the "virtual" neighbor, then this
		 * will add a positive value to the summation; otherwise its 0
		 */
		if (currentweight == k) {
			match_w = frac * exp(oldweights[currentweight]);
			debug("%.1fe^w%d", frac, currentweight + 1);
		}
		else if (matchingneighbors[n][currentweight]) {
			match_w = exp(oldweights[currentweight]);
			debug("e^w%d", currentweight + 1);
		}
		else {
			debug("0");
			continue;
		}

		debug(" / (");

		/* Sum the exponential of weights whose neighbors match the
		 * class of n. Add fractional part of the last weight
		 */
		debug("%0.1fe^w%d", frac, k + 1);
		sum_m = 0;
		for (i = 0; i < k; i++) {
			if (matchingneighbors[n][i]) {
				sum_m += exp(oldweights[i]);
				debug(" + e^w%d", i + 1);
			}
		}
		sum_m += frac * exp(oldweights[k]);

		/* Add to the summation in the left side of Eq. 2.8
		 */
		step += match_w / sum_m;

		debug(" {%e/%e = %e}", match_w, sum_m, match_w / sum_m);

		debug(")");
	}

	debug(" - %de^w%d/X {%e/%e = %e})\n", size, currentweight + 1, size * exp(oldweights[currentweight]),
			sum_w, size * exp(oldweights[currentweight]) / sum_w);

	/* Add to the summation the right side of Eq. 2.8
	 */
	step -= size * exp(oldweights[currentweight]) / sum_w;

	return step;
}


int iterate(double *weights, const double *classes, 
		const double *neighborclasses, const int k, const int size,
		const int numclasses)
{
	double *oldweights;
	double maxdiff, diff;
	int **matchingneighbors;
	int n, i;
	int it = 0;

#if DEBUG
	debug("Size = %d\n", size);
	debug("k = %d\n", k);
	debug("# classes = %d\n", numclasses);

	debug("Classes:");
	for (n = 0; n < size; n++) {
		debug(" %d", (int)classes[n]);
	}
	debug("\n");
#endif

	/* matchingneighbors is a size:k matrix where element n,i is 1 if the
	 * class of the i-th neighbor of n is the same as the class of n
	 */
	if (!(matchingneighbors = malloc(size * sizeof (int*)))) {
		mexErrMsgIdAndTxt(MYID ":MemErr", "Could not allocate %d "
				"bytes", size * sizeof (int*));
	}	
	for (n = 0; n < size; n++) {
		if (!(matchingneighbors[n] = malloc(k * sizeof (int)))) {
			mexErrMsgIdAndTxt(MYID ":MemErr", "Could not allocate "
					"%d bytes", k * sizeof (int));
		}
		for (i = 0; i < k; i++) {
			matchingneighbors[n][i] =
				(neighborclasses[i * size + n] == classes[n]);
		}
	}

	/* Print the matching neighbors for the debug version
	 */
#if DEBUG
	debug("Neighborclass remap:\n");
	for (n = 0; n < size; n++) {
		for (i = 0; i < k; i++) {
			debug("%-2d  ", i * size + n);
		}
		debug("\n");
	}

	debug("\nMatching neighbors:\n");
	for (n = 0; n < size; n++) {
		debug("\nInstance #%d (class %d)\n", n, (int)classes[n]);
		for (i = 0; i < k; i++) {
			int nclass = neighborclasses[i * size + n];
			debug("Neighbor #%d (class %d): %s\n", n, nclass,
					classes[n] == nclass ? "match" : "no match");
		}
	}
#endif

	/* Weights are initially the same
	 */
	for (i = 0; i <= k; i++) {
		weights[i] = INITIAL_WEIGHTS;
	}

	oldweights = malloc(sizeof (double) * (k + 1));
	do {
		double sum_w;

#if DEBUG
		debug("Iteration #%d:", it);
		for (i = 0; i <= k; i++) {
			debug("  %e", weights[i]);
		}
		debug("\n");
#endif

		if (it == MAX_ITERATIONS) {
			return it;
		}
		it++;
		
		memcpy(oldweights, weights, sizeof (double) * (k + 1));

		/* Get the sum of e^weights
		 */
		sum_w = 0;
		for (i = 0; i <= k; i++) {
			sum_w += exp(weights[i]);
		}

		/* Step each weight
		 */
		maxdiff = 0;
		for (i = 0; i <= k; i++) {
			weights[i] += NI * stepweight(oldweights,
					matchingneighbors, size, k, numclasses,
					sum_w, i);

			/* Get the maximum weight difference
			 */
			diff = fabs(weights[i] - oldweights[i]);
			if (diff > maxdiff && fabs(diff - maxdiff) > EPS) {
				maxdiff = diff;
			}
		}

		debug("\n");
	} while (maxdiff > MINMAX_WEIGH_DIFF &&
			fabs(maxdiff - MINMAX_WEIGH_DIFF) > EPS);

	debug("Converged with %d iterations\n", it);

	return it;
}


int testmatrix(const mxArray *arg, const int rows, const int cols)
{
	return mxIsDouble(arg) && !mxIsComplex(arg) && 
		mxGetM(arg) == rows && mxGetN(arg) == cols;
}


int testdouble(const mxArray *arg)
{
	return mxIsDouble(arg) && !mxIsComplex(arg) &&
		mxGetNumberOfElements(arg) == 1;
}


void mexFunction(int nleft, mxArray *left[], int nright, const mxArray *right[])
{
	/* Usage:
	 *
	 *    weights = mexFunction(trainclasses, neighboorclasses, k,
	 *    		ntrain, nclasses)
	 */
	mwSize k, ntrain, nclasses;
	double *trainclasses, *neighborclasses;
	double *weights;
	int numit;

#if DEBUG
	__debug_file = fopen("debug.txt", "w");
#endif
	
	/* Check number of arguments
	 */
	if (nleft > 2) {
		mexErrMsgIdAndTxt(OUTERR, "Too many output arguments");
	}
	if (nright != 5) {
		mexErrMsgIdAndTxt(INERR, "Exactly 5 input arguments expected");
	}

	/* Check and get arguments #3 and #4: size of neighborhood and size
	 * of dataset
	 */
	if (!testdouble(right[2]) || !testdouble(right[3]) || !testdouble(right[4])) {
		mexErrMsgIdAndTxt(INERR, EXPECTEDARGS);
	}

	k = mxGetScalar(right[2]);
	ntrain = mxGetScalar(right[3]);
	nclasses = mxGetScalar(right[4]);

	/* Check and get arguments #1 and #2: dataset classes and neighbor classes
	 */
	if (!testmatrix(right[0], ntrain, 1)) {
		mexErrMsgIdAndTxt(INERR, "First argument should be %d:1 matrix",
				ntrain);
	}
	if (!testmatrix(right[1], ntrain, k)) {
		mexErrMsgIdAndTxt(INERR, "Second argument should be "
				"%d:%d matrix", ntrain, k);
	}

	trainclasses = mxGetPr(right[0]);
	neighborclasses = mxGetPr(right[1]);

	/* Create output matrix and run iteration process
	 */
	left[0] = mxCreateDoubleMatrix(1, k + 1, mxREAL);
	weights = mxGetPr(left[0]);
	numit = iterate(weights, trainclasses, neighborclasses, k, ntrain, nclasses);

	/* Return the number of iterations if there was specified an output variable for it
	 */
	if (nleft == 2) {
		left[1] = mxCreateDoubleScalar(numit);
	}

#if DEBUG
	debug("\n\nNumber of iterations = %d (max was %d)\n", numit, MAX_ITERATIONS);
	fclose(__debug_file);
#endif
}
