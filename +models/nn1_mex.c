#include "mex.h"

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

	if (nright != 4) {
		mexErrMsgTxt("Four inputs required.");
	}
	if (nleft != 2) {
		mexErrMsgTxt("Two outputs required.");
	}

	/* First argument must be a non-complex matrix of double
	*/
	nseries = mxGetN(right[0]);
	len = mxGetM(right[0]) - 1;
	if (!mxIsDouble(right[0]) || mxIsComplex(right[0]) || len < 1) {
		mexErrMsgTxt("First input (STACK) must be a non-complex "
				"matrix of double");
	}

	/* Second argument must be a non-complex row array of double
	 */
	if (mxGetM(right[1]) != 1 || mxGetN(right[1]) != len + 1 ||
			!mxIsDouble(right[1]) || mxIsComplex(right[1])) {
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
}
