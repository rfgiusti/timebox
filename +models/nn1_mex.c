#include "mex.h"

#define DEBUG 0

#if DEBUG
#include <stdio.h>
#define DEBUG_PATH "/tmp/timebox-nn1_mex-debug.txt"
FILE *__debug_file = NULL;
#define debug(...) do { \
	fprintf(__debug_file, __VA_ARGS__); \
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
	len = mxGetM(right[0]) - 1;
	if (!mxIsDouble(right[0]) || mxIsComplex(right[0]) || len < 1) {
		debug("First input error\nmxIsDouble: %d, mxIsComplex: %d, "
				"len: %d\n", mxIsDouble(right[0]),
				mxIsComplex(right[0]), len);
		mexErrMsgTxt("First input (STACK) must be a non-complex "
				"matrix of double");
	}

	/* Second argument must be a non-complex row array of double
	*/
	if (mxGetM(right[1]) != 1 || mxGetN(right[1]) != len + 1 ||
			!mxIsDouble(right[1]) || mxIsComplex(right[1])) {
		debug("Second input error\nmxIsDouble: %d, mxIsComplex: %d, "
				"mxGetM: %d, mxGetN: %d\n",
				mxIsDouble(right[1]), mxIsComplex(right[1]),
				mxGetM(right[1]), mxGetN(right[1]));
		mexErrMsgTxt("Second input (NEEDLE) must be a non-complex "
				"row array of double with same number of "
				"elements as the first input");
	}

	/* Third argument must be a scalar
	*/
	if (!mxIsDouble(right[2]) || mxIsComplex(right[2]) ||
			mxGetNumberOfElements(right[2]) != 1) {
		mexErrMsgTxt("Third input (SKIPINDEX) must ba non-complex "
				"scalar");
	}

	/* Fourh argument must be a scalar
	*/
	if (!mxIsDouble(right[3]) || mxIsComplex(right[3]) ||
			mxGetNumberOfElements(right[3]) != 1) {
		mexErrMsgTxt("Fourth input (EPSILON) must ba non-complex "
				"scalar");
	}

	debug("Input arguments OK\n");

	/* Create two dummy output arguments
	*/
	left[0] = mxCreateDoubleScalar(1);
	left[1] = mxCreateDoubleScalar(2);

	end_debugger();
}
