/* Implements the 1-Nearest Neighbor with many distance functions.
 *
 * A distance function is chosen by passing this MEX function an integer
 * corresponding to the distance code.
 */

/* This file is part of TimeBox. Copyright 2015-17 Rafael Giusti
 * Revision 0.1.0
 */

#include "mex.h"

#include <math.h>
#include <stdlib.h>
#include <string.h>

#define DEBUG 0

#if DEBUG
#include <stdio.h>
#define DEBUG_PATH "/tmp/timebox-nn1_mex-debug.txt"
FILE *__debug_file = NULL;
#define debug(...) do { \
	fprintf(__debug_file, __VA_ARGS__); \
	fflush(__debug_file); \
} while (0)
#define start_debugger() do { \
	if (!(__debug_file = fopen(DEBUG_PATH, "w"))) { \
		mexErrMsgTxt("Can't open debug log at " DEBUG_PATH ". If " \
				"is not required, please disable DEBUG and " \
				"recompile this mex file."); \
	} \
} while (0)
#define end_debugger() do { \
	if (__debug_file) fclose(__debug_file); \
} while (0)
#define mexErrMsgTxt(...) do { \
	end_debugger(); \
	mexErrMsgTxt(__VA_ARGS__); \
} while (0)
#else
/* No debugging
*/
#define debug(...) do { } while (0)
#define start_debugger() do { } while (0)
#define end_debugger() do { } while (0)
#endif

/* Points "ptr" to the first observation of an instance
 */
#define seekstack(_ptr, _stack, _instance, _len) do { \
	(_ptr) = (_stack) + ((_instance) - 1) * (_len) + 1; \
} while (0)

/* Check if a float is larger
 */
#define FLT_GT(_flt1, _flt2, _eps) \
	(fabs((_flt1) - (_flt2)) > (_eps) && (_flt1) > (_flt2))

#include "nn1fast_distances.c"

int nn1fast(double *stack, double *needle, int nseries, int len,
		int skipindex, double epsilon, double *bestidx,
		distancefunction distfun, double *distance)
{
	double *test;
	double bsf = INFINITY;
	double dist;
	int current;
	int neighbors = 0;

 	debug("Called nn1fast(PTR, PTR, %d, %d, %d, %e, PTR, PTR, PTR)\n", 
			nseries, len, skipindex, epsilon); 

	/* Skip the needle class and point the test pointer to the first
	 * instance
	 */
	needle++;
	test = stack + 1;

	/* Calculate the squared distance from the needle to all series
	 */
	current = 1;
	while (current <= nseries) {
		/* Allow in-loco classification
		 */
		if (current == skipindex) {
			current++;
			seekstack(test, stack, current, len);
			continue;
		}
		
		debug("Distance #%d: ", current);
		dist = distfun(test, needle, len, bsf, epsilon);
		if (FLT_GT(bsf, dist, epsilon)) {
			/* Distance to nearest neighbor got smaller
			*/
			bsf = dist;
			bestidx[0] = current;
			neighbors = 1;
		}
		else if (!FLT_GT(dist, bsf, epsilon)) {
			/* Another instance just as far from the previous
			 * neighbors
			 */
			bestidx[neighbors++] = current;
		}
		
		current++;
		seekstack(test, stack, current, len);
	}

	*distance = bsf;
	return neighbors;
}

void mexFunction(int nleft, mxArray *left[], int nright, const mxArray *right[])
{
	/*
	 *  Usage:
	 *
	 *     [bestidx, distance] = mexFunction(stack, needle, distcode, ...
	 *                                       skipindex, epsilon);
	 *
	 *  Where the input arguments are:
	 *
	 *     stack     - the data set*
	 *     needle    - the test instance
	 *     distcode  - the ID distance function ID
	 *     skipindex - if the test instance is contained in the data set,
	 *                 skipindex must be the instance of the test instance;
	 *                 otherwise it should be -1
	 *     epsilon   - tolerance threshold for float operations
	 *
	 *  And the output arguments are:
	 *
	 *     bestidx   - a row vector containing the nearest neighbors of the
	 *                 test instance (within tolerance)
	 *     distance  - the distance from the test instance to the neighbors
	 *
	 *  TimeBox data sets contains instances in rows and observations in
	 *  columns. This mex requires the instances in the columns and the
	 *  observations in the rows. The first row is, therefore, the classes.
	 *  
	 *  Example usage:
	 *
	 *     [train, test] = ts.load('Sample dataset');
	 *     needle = test(1, :);
	 *     [bestidx, distance] = mexFunction(stack', needle, 3, -1, 1e-10)
	 *
	 *  This runs the 1-NN with Chebyshev distance (L_inf norm).
	 * 
	 *  The data set is transformed into the expected notation with stack'.
	 *  The test instance should be kept a row vector.
	 */

	int nseries, len;
	double *stack, *needle;
	int distcode;
	int skipindex;
	double epsilon;
	double *bestidx_large, *bestidx, distance;
	int numneighbors;
	distancefunction distfun;

	start_debugger();
	debug("Started mexFunction\n\n");
	debug("Verifying input/output arguments\n");

	if (nright != 5) {
		debug("Got %d inputs (expected 5)\n", nright);
		mexErrMsgTxt("Five inputs required.");
	}
	if (nleft != 2) {
		debug("Got %d outputs (expected 2)\n", nleft);
		mexErrMsgTxt("Two outputs required.");
	}

	/* First argument must be a non-complex matrix of double
	*/
	nseries = mxGetN(right[0]);
	len = mxGetM(right[0]);
	if (!mxIsDouble(right[0]) || mxIsComplex(right[0]) || len <= 1) {
		debug("First input error\nmxIsDouble: %d, mxIsComplex: %d, "
				"len: %d\n", mxIsDouble(right[0]),
				mxIsComplex(right[0]), len);
		mexErrMsgTxt("First input (STACK) must be a non-complex "
				"matrix of double");
	}
	stack = mxGetPr(right[0]);
	debug("Stack: %d series of lenght %d\n", nseries, len);

	/* Second argument must be a non-complex row array of double
	*/
	if (mxGetM(right[1]) != 1 || mxGetN(right[1]) != len ||
			!mxIsDouble(right[1]) || mxIsComplex(right[1])) {
		debug("Second input error\nmxIsDouble: %d, mxIsComplex: %d, "
				"mxGetM: %zu, mxGetN: %zu\n",
				mxIsDouble(right[1]), mxIsComplex(right[1]),
				mxGetM(right[1]), mxGetN(right[1]));
		mexErrMsgTxt("Second input (NEEDLE) must be a non-complex "
				"row array of double with same number of "
				"elements as the first input");
	}
	needle = mxGetPr(right[1]);
	debug("Needle: ok\n"); 

	/* Third argument must be a scalar
	*/
	if (!mxIsDouble(right[2]) || mxIsComplex(right[2]) ||
			mxGetNumberOfElements(right[2]) != 1) {
		mexErrMsgTxt("Third input (DISTCODE) must ba non-complex "
				"scalar");
	}
	distcode = mxGetScalar(right[2]);
	debug("distcode == %d\n", distcode);

	/* Fourh argument must be a scalar
	*/
	if (!mxIsDouble(right[3]) || mxIsComplex(right[3]) ||
			mxGetNumberOfElements(right[3]) != 1) {
		mexErrMsgTxt("Fourth input (SKIPINDEX) must ba non-complex "
				"scalar");
	}
	skipindex = mxGetScalar(right[3]);
#if DEBUG
	{
		char *msg = (skipindex == -1 ? "in another set" : "in loco");
		debug("skipindex == %d (test sample is %s)\n", skipindex, msg);
	}
#endif

	/* Fifth argument must be a scalar
	*/
	if (!mxIsDouble(right[4]) || mxIsComplex(right[4]) ||
			mxGetNumberOfElements(right[4]) != 1) {
		mexErrMsgTxt("Fitht input (EPSILON) must be a non-complex "
				"scalar");
	}
	epsilon = mxGetScalar(right[4]);
	debug("epsilon == %e\n", epsilon);

	/* Select the distance function
	 */
	distfun = selectdistance(distcode);

	/* Make room for the maximum possible number of neighbors (all of them)
	*/
	bestidx_large = malloc(sizeof (double) * nseries);
	if (!bestidx_large) {
		debug("Could not allocate %zu bytes for %d neighbors\n", 
				sizeof (double) * nseries, nseries);
		mexErrMsgTxt("Error allocating memory\n");
	}

	/* Run the classifier
	*/
	debug("Input ok\n\n");	
	debug("Running 1-NN with generic distance\n");

	numneighbors = nn1fast(stack, needle, nseries, len, skipindex,
			epsilon, bestidx_large, distfun, &distance);

	/* The 1-NN with Euclidean distance actually uses the Euclidean distance
	 * squared; fixes that here.
	 */
	if (distcode == 1) {
		distance = sqrt(distance);
	}

	/* Make the first argument the distances from the needle to all series
	*/
	debug("Trying to allocate first output argument\n");
	left[0] = mxCreateDoubleMatrix(numneighbors, 1, mxREAL);
	bestidx = mxGetPr(left[0]);
	memcpy(bestidx, bestidx_large, sizeof (double) * numneighbors);

	/* Make the second the distance to the nearest neighbor
	*/
	debug("Making second scalar\n");
	left[1] = mxCreateDoubleScalar(distance);

	end_debugger();
}
