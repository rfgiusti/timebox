/* This file contains the bodies of the functions that will be used by
 * nn1fast_mex.c. This is intended to be #included by that file. 
 */

/* This file is part of TimeBox. Copyright 2015-17 Rafael Giusti
 * Revision 0.1.0
 */

typedef double (*distancefunction)(double *, double *, int, double, double);

double euclidean2(double *s, double *z, int len, double bsf, double epsilon)
{
	/* Return the squared Euclidean distance between two series
	*/
	double dist = 0;
	while (--len) {
		dist += (*s - *z) * (*s - *z);
		s++;
		z++;
		/* Early abandon
		*/
		if (FLT_GT(dist, bsf, epsilon)) {
			debug(" %.6f (early abandoned)\n", dist);
			return dist;
		}
	}
	debug(" %.6f\n", dist);
	return dist;
}

double manhattan(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	while (--len) {
		dist += (*s > *z ? *s - *z : *z - *s);
		s++;
		z++;
		if (FLT_GT(dist, bsf, epsilon)) {
			debug(" %.6f (early abandoned)\n", dist);
			return dist;
		}
	}
	debug(" %.6f\n", dist);
	return dist;
}

double chebyshev(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	double d;
	while (--len) {
		d = (*s > *z ? *s - *z : *z - *s);
		s++;
		z++;
		if (FLT_GT(d, dist, epsilon)) {
			dist = d;
		}
		if (FLT_GT(dist, bsf, epsilon)) {
			debug(" %.6f (early abandoned)\n", dist);
			return dist;
		}
	}
	debug(" %.6f\n", dist);
	return dist;
}

double avg_l1_linf(double *s, double *z, int len, double bsf, double epsilon)
{
	double m, c;
	debug("(");
	m = manhattan(s, z, len, INFINITY, epsilon);
	debug (" + ");
	c = chebyshev(s, z, len, INFINITY, epsilon);
	debug (") / 2 --> %.6f\n", (m + c) / 2);
	return (m + c) / 2;
}


double canberra(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	double u, b;
	while (--len) {
		u = fabs(*s - *z);
		b = fabs(*s) + fabs(*z);
		if (b < epsilon) {
			dist += u;
		}
		else {
			dist += u / b;
		}
		s++;
		z++;
		if (FLT_GT(dist, bsf, epsilon)) {
			debug(" %.6f (early abandoned)\n", dist);
			return dist;
		}
	}
	debug(" %.6f\n", dist);
	return dist;
}

double lorentzian(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	while (--len) {
		dist += log(1 + fabs(*s - *z));
		s++;
		z++;
		if (FLT_GT(dist, bsf, epsilon)) {
			debug(" %.6f (early abandoned)\n", dist);
			return dist;
		}
	}
	debug(" %.6f\n", dist);
	return dist;
}

double sorensen(double *s, double *z, int len, double bsf, double epsilon)
{
	double num = 0, den = 0;
	while (--len) {
		num += fabs(*s - *z);
		den += fabs(*s) + fabs(*z);
		s++;
		z++;
	}
	debug(" %.6f\n", num / den);
	return num / den;
}

double cosine(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	double norm1 = 0, norm2 = 0;
	while (--len) {
		dist += *s * *z;
		norm1 += *s * *s;
		norm2 += *z * *z;
		s++;
		z++;
	}
	dist = 1 - dist / (sqrt(norm1) * sqrt(norm2));
	debug(" %.6f\n", dist);
	return dist;
}

double jaccard(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist;
	double diff = 0;
	double mul = 0;
	while (--len) {
		diff += (*s - *z) * (*s - *z);
		mul += *s * *z;
		s++;
		z++;
	}
	dist = diff / (diff + mul);
	debug(" %.6f\n", dist);
	return dist;
}

double dice(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist;
	double num = 0, den = 0;;
	while (--len) {
		num += (*s - *z) * (*s - *z);
		den += *s * *s + *z * *z;
		s++;
		z++;
	}
	dist = num / den;
	debug(" %.6f\n", dist);
	return dist;
}


double pearson(double *s, double *z, int len, double bsf, double epsilon)
{
	/* Notice this is the Pearson Chi-Square distance, not the Pearson
	 * correlation coefficient.
	 */
	double dist = 0;
	while (--len) {
		if (fabs(*z) < epsilon) {
			dist += *s * *s;
		}
		else {
			dist += ((*s - *z) * (*s - *z)) / *z;
		}
		s++;
		z++;
	}
	debug(" %.6f\n", dist);
	return dist;
}

double squared_chi(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	double num, den;
	while (--len) {
		num = (*s - *z) * (*s - *z);
		den = *s + *z;
		if (fabs(den) < epsilon) {
			dist += num;
		}
		else {
			dist += num / den;
		}
		s++;
		z++;
	}
	debug(" %.6f\n", dist);
	return dist;
}

double kullback(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	double sz;
	while (--len) {
		sz = *s * *z;
		if (fabs(sz) > epsilon && sz > 0) {
			dist += *s * log(*s / *z);
		}
		else {
			dist += *s;
		}
		s++;
		z++;
	}
	debug(" %.6f\n", dist);
	return dist;
}

double jeffrey(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	double sz;
	while (--len) {
		sz = *s * *z;
		if (fabs(sz) > epsilon && sz > 0) {
			dist += (*s - *z) * log(*s / *z);
		}
		s++;
		z++;
	}
	debug(" %.6f\n", dist);
	return dist;
}

double bhattacharyya(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	double sz;
	while (--len) {
		sz = *s * *z;
		if (fabs(sz) < epsilon || sz > 0) {
			dist += sqrt(sz);
		}
		s++;
		z++;
	}
	if (fabs(dist) > epsilon && dist > 0) {
		dist = -log(dist);
	}
	debug(" %.6f\n", dist);
	return dist;
}

double hellinger(double *s, double *z, int len, double bsf, double epsilon)
{
	double dist = 0;
	double sz;
	while (--len) {
		sz = *s * *z;
		if (fabs(sz) < epsilon || sz > 0) {
			dist += sqrt(*s * *z);
		}
		s++;
		z++;
	}
	if (fabs(dist - 1) < epsilon || dist < 1) {
		dist = 2 * sqrt(1 - dist);
	}
	else {
		dist = 0.0 / 0.0;
	}
	debug(" %.6f\n", dist);
	return dist;
}


distancefunction selectdistance(int distcode)
{
	switch (distcode) {
	case 1:
		/* Lp norm family
		*/
		debug("Distance: Euclidean\n");
		return euclidean2;
	case 2:
		debug("Distance: Manhattan\n");
		return manhattan;
	case 3:
		debug("Distance: Chebyshev\n");
		return chebyshev;
	case 9:
		debug("Distance: average Manhattan and Chebyshev\n");
		return avg_l1_linf;

	case 10:
		/* Manhattan-derived family
		*/
		debug("Distance: Canberra\n");
		return canberra;
	case 11:
		debug("Distance: Lorentzian\n");
		return lorentzian;
	case 12:
		debug("Distance: Sorensen\n");
		return sorensen;

	case 20:
		/* Dot product family
		 */
		debug("Distance: Cosine\n");
		return cosine;
	case 21:
		debug("Distance: Jaccard\n");
		return jaccard;
	case 22:
		debug("Distance: Dice\n");
		return dice;
		
	case 30:
		/* Pearson Chi-Square coefficient family
		 */
		debug("Distance: Pearson Chi-Square\n");
		return pearson;
	case 31:
		debug("Distance: Squared Chi-Square\n");
		return squared_chi;

	case 40:
		/* Kullback-Leibler family
		 */
		debug("Distance: Kullback-Leibler\n");
		return kullback;
	case 41:
		debug("Distance: Jeffrey's\n");
		return jeffrey;

	case 50:
		/* Bhattacharyya coefficient family
		 */
		debug("Distance: Bhattacharyya distance\n");
		return bhattacharyya;
	case 51:
		debug("Distance: Hellinger\n");
		return hellinger;

	default:
		{
			char buf[1024];
			sprintf(buf, "Unexpected distance code: %d", distcode);
			mexErrMsgTxt(buf);
		}
	}
}
