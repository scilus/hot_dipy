# distutils: language = c
# cython: wraparound=False, cdivision=True, boundscheck=False

import numpy as np
cimport numpy as np

from libc.math cimport sqrt

from cythonutils cimport tuple2shape, shape2tuple, same_shape
from featurespeed cimport IdentityFeature

DEF biggest_double = 1.7976931348623157e+308  #  np.finfo('f8').max


cdef class Metric(object):
    """ Computes distance between two sequential data.

    A sequence of N-dimensional points is represented as a 2D array with
    shape (nb_points, nb_dimensions). A `feature` object can be specified
    in order to calculate the distance between extracted features, rather
    than directly between the sequential data.

    Parameters
    ----------
    feature : `Feature` object, optional
        It is used to extract features before computing the distance.

    Notes
    -----
    When subclassing `Metric`, one only needs to override the `dist` and
    `are_compatible` methods.
    """
    def __init__(Metric self, Feature feature=IdentityFeature()):
        self.feature = feature
        self.is_order_invariant = self.feature.is_order_invariant

    property feature:
        """ `Feature` object used to extract features from sequential data """
        def __get__(Metric self):
            return self.feature

    property is_order_invariant:
        """ Is this metric invariant to the sequence's ordering """
        def __get__(Metric self):
            return bool(self.is_order_invariant)

    cdef int c_are_compatible(Metric self, Shape shape1, Shape shape2) nogil:
        """ Cython version of `Metric.are_compatible`. """
        with gil:
            return self.are_compatible(shape2tuple(shape1), shape2tuple(shape2))

    cdef double c_dist(Metric self, Data2D features1, Data2D features2) nogil:
        """ Cython version of `Metric.dist`. """
        with gil:
            return self.dist(np.asarray(features1), np.asarray(features2))

    cpdef are_compatible(Metric self, shape1, shape2):
        """ Checks if features can be used by `metric.dist` based on their shape.

        Basically this method exists so we don't have to do this check
        inside the `metric.dist` function (speedup).

        Parameters
        ----------
        shape1 : tuple
            shape of the first data point's features
        shape2 : tuple
            shape of the second data point's features

        Returns
        -------
        are_compatible : bool
            whether or not shapes are compatible
        """
        raise NotImplementedError("Metric's subclasses must implement method `are_compatible(self, shape1, shape2)`!")

    cpdef double dist(Metric self, features1, features2):
        """ Computes distance between two data points based on their features.

        Parameters
        ----------
        features1 : 2D array
            Features of the first data point.
        features2 : 2D array
            Features of the second data point.

        Returns
        -------
        double
            Distance between two data points.
        """
        raise NotImplementedError("Metric's subclasses must implement method `dist(self, features1, features2)`!")


cdef class CythonMetric(Metric):
    """ Computes distance between two sequential data.

    A sequence of N-dimensional points is represented as a 2D array with
    shape (nb_points, nb_dimensions). A `feature` object can be specified
    in order to calculate the distance between extracted features, rather
    than directly between the sequential data.

    Parameters
    ----------
    feature : `Feature` object, optional
        It is used to extract features before computing the distance.

    Notes
    -----
    When subclassing `CythonMetric`, one only needs to override the `c_dist` and
    `c_are_compatible` methods.
    """
    cpdef are_compatible(CythonMetric self, shape1, shape2):
        """ Checks if features can be used by `metric.dist` based on their shape.

        Basically this method exists so we don't have to do this check
        inside method `dist` (speedup).

        Parameters
        ----------
        shape1 : tuple
            Shape of the first data point's features.
        shape2 : tuple
            Shape of the second data point's features.

        Returns
        -------
        bool
            Whether or not shapes are compatible.

        Notes
        -----
        This method calls its Cython version `self.c_are_compatible` accordingly.
        """
        return self.c_are_compatible(tuple2shape(shape1), tuple2shape(shape2)) == 1

    cpdef double dist(CythonMetric self, features1, features2):
        """ Computes distance between two data points based on their features.

        Parameters
        ----------
        features1 : 2D array
            Features of the first data point.
        features2 : 2D array
            Features of the second data point.

        Returns
        -------
        double
            Distance between two data points.

        Notes
        -----
        This method calls its Cython version `self.c_dist` accordingly.
        """
        if not self.are_compatible(features1.shape, features2.shape):
            raise ValueError("Features are not compatible according to this metric!")

        return self.c_dist(features1, features2)


cdef class SumPointwiseEuclideanMetric(CythonMetric):
    r""" Computes the sum of pointwise Euclidean distances between two
    sequential data.

    A sequence of N-dimensional points is represented as a 2D array with
    shape (nb_points, nb_dimensions). A `feature` object can be specified
    in order to calculate the distance between the features, rather than
    directly between the sequential data.

    Parameters
    ----------
    feature : `Feature` object, optional
        It is used to extract features before computing the distance.

    Notes
    -----
    The distance between two 2D sequential data::

        s1       s2

        0*   a    *0
          \       |
           \      |
           1*     |
            |  b  *1
            |      \
            2*      \
                c    *2

    is equal to $a+b+c$ where $a$ is the Euclidean distance between s1[0] and
    s2[0], $b$ between s1[1] and s2[1] and $c$ between s1[2] and s2[2].
    """
    cdef double c_dist(SumPointwiseEuclideanMetric self, Data2D features1, Data2D features2) nogil:
        cdef :
            int N = features1.shape[0], D = features1.shape[1]
            int n, d
            double dd, dist_n, dist = 0.0

        for n in range(N):
            dist_n = 0.0
            for d in range(D):
                dd = features1[n, d] - features2[n, d]
                dist_n += dd*dd

            dist += sqrt(dist_n)

        return dist

    cdef int c_are_compatible(SumPointwiseEuclideanMetric self, Shape shape1, Shape shape2) nogil:
        return same_shape(shape1, shape2)


cdef class AveragePointwiseEuclideanMetric(SumPointwiseEuclideanMetric):
    r""" Computes the average of pointwise Euclidean distances between two
    sequential data.

    A sequence of N-dimensional points is represented as a 2D array with
    shape (nb_points, nb_dimensions). A `feature` object can be specified
    in order to calculate the distance between the features, rather than
    directly between the sequential data.

    Parameters
    ----------
    feature : `Feature` object, optional
        It is used to extract features before computing the distance.

    Notes
    -----
    The distance between two 2D sequential data::

        s1       s2

        0*   a    *0
          \       |
           \      |
           1*     |
            |  b  *1
            |      \
            2*      \
                c    *2

    is equal to $(a+b+c)/3$ where $a$ is the Euclidean distance between s1[0] and
    s2[0], $b$ between s1[1] and s2[1] and $c$ between s1[2] and s2[2].
    """
    cdef double c_dist(AveragePointwiseEuclideanMetric self, Data2D features1, Data2D features2) nogil:
        cdef int N = features1.shape[0]
        cdef double dist = SumPointwiseEuclideanMetric.c_dist(self, features1, features2)
        return dist / N


cdef class MinimumAverageDirectFlipMetric(AveragePointwiseEuclideanMetric):
    r""" Computes the ADF distance (minimum average direct-flip) between two
    sequential data.

    A sequence of N-dimensional points is represented as a 2D array with
    shape (nb_points, nb_dimensions).

    Notes
    -----
    The distance between two 2D sequential data::

        s1       s2

        0*   a    *0
          \       |
           \      |
           1*     |
            |  b  *1
            |      \
            2*      \
                c    *2

    is equal to $\min((a+b+c)/3, (a'+b'+c')/3)$ where $a$ is the Euclidean distance
    between s1[0] and s2[0], $b$ between s1[1] and s2[1], $c$ between s1[2]
    and s2[2], $a'$ between s1[0] and s2[2], $b'$ between s1[1] and s2[1]
    and $c'$ between s1[2] and s2[0].
    """
    def __init__(MinimumAverageDirectFlipMetric self):
        super(MinimumAverageDirectFlipMetric, self).__init__(feature=IdentityFeature())

    property is_order_invariant:
        """ Is this metric invariant to the sequence's ordering """
        def __get__(MinimumAverageDirectFlipMetric self):
            return True  # Ordering is handled in the distance computation

    cdef double c_dist(MinimumAverageDirectFlipMetric self, Data2D features1, Data2D features2) nogil:
        cdef double dist_direct = AveragePointwiseEuclideanMetric.c_dist(self, features1, features2)
        cdef double dist_flipped = AveragePointwiseEuclideanMetric.c_dist(self, features1, features2[::-1])
        return min(dist_direct, dist_flipped)


cpdef distance_matrix(Metric metric, data1, data2=None):
    """ Computes the distance matrix between two lists of sequential data.

    The distance matrix is obtained by computing the pairwise distance of all
    tuples spawn by the Cartesian product of `data1` with `data2`. If `data2`
    is not provided, the Cartesian product of `data1` with itself is used
    instead. A sequence of N-dimensional points is represented as a 2D array with
    shape (nb_points, nb_dimensions).

    Parameters
    ----------
    metric : `Metric` object
        Tells how to compute the distance between two sequential data.
    data1 : list of 2D array
        List of sequences of N-dimensional points.
    data2 : list of 2D array
        Llist of sequences of N-dimensional points.

    Returns
    -------
    2D array (double)
        Distance matrix.
    """
    cdef int i, j
    if data2 is None:
        data2 = data1

    shape = metric.feature.infer_shape(data1[0].astype(np.float32))
    distance_matrix = np.zeros((len(data1), len(data2)), dtype=np.float64)
    cdef:
        Data2D features1 = np.empty(shape, np.float32)
        Data2D features2 = np.empty(shape, np.float32)

    for i in range(len(data1)):
        datum1 = data1[i] if data1[i].flags.writeable and data1[i].dtype is np.float32 else data1[i].astype(np.float32)
        metric.feature.c_extract(datum1, features1)
        for j in range(len(data2)):
            datum2 = data2[j] if data2[j].flags.writeable and data2[j].dtype is np.float32 else data2[j].astype(np.float32)
            metric.feature.c_extract(datum2, features2)
            distance_matrix[i, j] = metric.c_dist(features1, features2)

    return distance_matrix


cpdef double dist(Metric metric, datum1, datum2) except -1.0:
    """ Computes distance between two sequential data.

    A sequence of N-dimensional points is represented as a 2D array with
    shape (nb_points, nb_dimensions).

    Parameters
    ----------
    metric : `Metric` object
        Tells how to compute the distance between `datum1` and `datum2`.
    datum1 : 2D array
        Sequence of N-dimensional points.
    datum2 : 2D array
        Sequence of N-dimensional points.

    Returns
    -------
    double
        Distance between two data points.
    """
    shape1 = metric.feature.infer_shape(datum1)
    shape2 = metric.feature.infer_shape(datum2)

    if not metric.are_compatible(shape1, shape2):
        raise ValueError("Data features' shapes must be compatible!")

    datum1 = datum1 if datum1.flags.writeable and datum1.dtype is np.float32 else datum1.astype(np.float32)
    datum2 = datum2 if datum2.flags.writeable and datum2.dtype is np.float32 else datum2.astype(np.float32)

    cdef:
        Data2D features1 = np.empty(shape1, np.float32)
        Data2D features2 = np.empty(shape2, np.float32)

    metric.feature.c_extract(datum1, features1)
    metric.feature.c_extract(datum2, features2)
    return metric.c_dist(features1, features2)
