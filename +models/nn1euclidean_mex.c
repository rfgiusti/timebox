/* Implements the 1-Nearest Neighbor with Euclidean distance.
 */

/* This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
 * Revision 1.0
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

double euclidean2(double *s1, double *s2, int len, double bsf, double epsilon)
{
	/* Return the squared Euclidean distance between two series
	 */
	double dist = 0;
	while (--len) {
		dist += (*s1 - *s2) * (*s1 - *s2);
		s1++;
		s2++;
		/* Early abandon
		 */
		if (FLT_GT(dist, bsf, epsilon)) {
			return dist;
		}
	}
	return dist;
}

int nn1euclidean(double *stack, double *needle, int nseries, int len,
		int skipindex, double epsilon, double *bestidx,
		double *distance)
{
	double *test;
	double bsf = INFINITY;
	double dist;
	int current;
	int neighbors = 0;

 	debug("Called nn1euclidean(PTR, PTR, %d, %d, %d, %e, PTR, PTR)\n", 
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
		
		dist = euclidean2(test, needle, len, bsf, epsilon);
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

	*distance = sqrt(bsf);
	return neighbors;
}

void mexFunction(int nleft, mxArray *left[], int nright, const mxArray *right[])
{
	/*
	 *  Usage:
	 *
	 *     [bestidx, distance] = mexFunction(stack, needle, ...
	 *                                       skipindex, epsilon);
	 *
	 *  Where the input arguments are:
	 *
	 *     stack     - the data set*
	 *     needle    - the test instance
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
	 *     [bestidx, distance] = mexFunction(stack', test(1,:), -1, 1e-10)
	 *
	 *  The data set is transformed into the expected notation with stack'.
	 *  The test instance should be kept a row vector.
	 */

	int nseries, len;
	double *stack, *needle;
	int skipindex;
	double epsilon;
	double *bestidx_large, *bestidx, distance;
	int numneighbors;

	start_debugger();
	debug("Started mexFunction\n\n");
	debug("Verifying input/output arguments\n");

	if (nright != 4) {
		debug("Got %d inputs (expected 4)\n", nright);
		mexErrMsgTxt("Four inputs required.");
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
		mexErrMsgTxt("Third input (SKIPINDEX) must ba non-complex "
				"scalar");
	}
	skipindex = mxGetScalar(right[2]);
#if DEBUG
	{
		char *msg = (skipindex == -1 ? "in another set" : "in loco");
		debug("skipindex == %d (test sample is %s)\n", skipindex, msg);
	}
#endif

	/* Fourh argument must be a scalar
	*/
	if (!mxIsDouble(right[3]) || mxIsComplex(right[3]) ||
			mxGetNumberOfElements(right[3]) != 1) {
		mexErrMsgTxt("Fourth input (EPSILON) must be a non-complex "
				"scalar");
	}
	epsilon = mxGetScalar(right[3]);
	debug("epsilon == %e\n", epsilon);

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
	debug("Running 1-NN with euclidean distance\n");

	numneighbors = nn1euclidean(stack, needle, nseries, len, skipindex,
			epsilon, bestidx_large, &distance);

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
