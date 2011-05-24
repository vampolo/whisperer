#include <Python.h>
#include <libAlg.h>
#include <numpy/ndarraytypes.h>
//for PyArray_OBJECT
#include <numpy/old_defines.h>
//for PyArray_SBYTE PyArray_BYTE
#include <numpy/oldnumeric.h>

static PyObject *RecError;

/*****************************************************************************/
/** Handling strided arrays
 * 
 * got from https://github.com/pv/pythoncall/blob/master/pythoncall.c
 **/

struct _stride
{
    /** Number of dimensions */
    int nd;
    /** Positions at each dimension */
    char **c;
    /** End positions for each dimension */
    char **end;
    /** Offsets of end positions for each dimension */
    long *end_offset;
    /** Strides for each dimension */
    const int* strides;
};
typedef struct _stride stride_t;

/** Initialize stepping through a strided array */
int stride_init(char* addr, int nd, const int* dims,
                const int* strides, stride_t *s)
{
    int i;
    s->nd = nd;
    s->c = mxCalloc(nd, sizeof(char*));
    s->end = mxCalloc(nd, sizeof(char*));
    s->end_offset = mxCalloc(nd, sizeof(long));
    s->strides = strides;
    for (i = 0; i < nd; ++i) {
        s->c[i] = addr;
        s->end_offset[i] = strides[i]*dims[i];
        s->end[i] = addr + s->end_offset[i];
        if (dims[i] < 0) {
            return;
        } else if (dims[i] == 0) {
            return 0;
        }
    }
    return 1;
}

/** Step the first index by one, wrapping around if necessary */
int stride_step(stride_t* s)
{
    int i, j;
    s->c[0] += s->strides[0];
    for (i = 0; i < s->nd; ++i) {
        if (s->c[i] != s->end[i])
            break;
        else if (i+1 == s->nd)
            return 0;
        else {
            s->c[i+1] += s->strides[i+1];
        }
    }
    for (j = i-1; j >= 0; --j) {
        s->c[j] = s->c[j+1];
        s->end[j] = s->c[j+1] + s->end_offset[j];
    }
    return 1;
}

/** Return the current position */
char* stride_pos(stride_t* s)
{
    return s->c[0];
}

/**
 * Copy a strided array to a continuous one. Elements in source and destination
 * arrays must be of the same size -- no conversion is done here.
 *
 * :param from: Pointer where to copy from
 * :param nd: Number of array dimensions
 * :param dims: Size of each array dimensions
 * :type dims: int[nd]
 * :param strides: Strides for each dimension. Can be also negative.
 * :type strides: int[nd]
 * :param to: Pointer where to copy to
 * :param to2:
 *     Pointer where to copy an element immediately following the previous one.
 * :param tstride:
 *     Size of the elements in `to` (and `to2`). Must be the same as the
 *     size of elements in `from`!
 */
void copy_to_contiguous(char *from, int nd, int *dims, int *strides,
                        char *to, char* to2, int tstride)
{
    char *p, *p2, *r;
    stride_t s;

    if (!stride_init(from, nd, dims, strides, &s)) return;
    
    p = to;
    p2 = to2;

    do {
        r = stride_pos(&s);
        
        memcpy(p, r, tstride);
        p += tstride;

        if (p2) {
            memcpy(p2, r + tstride, tstride);
            p2 += tstride;
        }
    } while (stride_step(&s));
}

/**
 * Copy a continuous array to a strided one. Elements in source and destination
 * arrays must be of the same size -- no conversion is done here.
 *
 * :param to: Pointer where to copy from
 * :param nd: Number of array dimensions
 * :param dims: Size of each array dimensions
 * :type dims: int[nd]
 * :param strides: Strides for each dimension. Can be also negative.
 * :type strides: int[nd]
 * :param from: Pointer where to copy to
 * :param from2:
 *     Pointer where from copy an element immediately following the previous
 *     one.
 * :param tstride:
 *     Size of the elements in `to` (and `to2`). Must be the same as the
 *     size of elements in `from`!
 */
void copy_from_contiguous(char *to, int nd, int *dims, int *strides,
                          char *from, char* from2, int tstride)
{
    char *p, *p2, *r;
    stride_t s;

    if (!stride_init(to, nd, dims, strides, &s)) return;

    p = from;
    p2 = from2;
    
    do {
        r = stride_pos(&s);
        
        memcpy(r, p, tstride);
        p += tstride;

        if (p2) {
            memcpy(r + tstride, p2, tstride);
            p2 += tstride;
        }
    } while (stride_step(&s));
}

/*****************************************************************************/
/** Type conversion: Python -> Matlab
 **/

mxArray *mx_from_py(PyObject* obj);
mxArray *mx_from_py_unknown(PyObject* obj);

/** Convert Python integer to Matlab integer
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_int(PyObject* obj)
{
    mxArray *r;
    int dims[1] = { 1 };
    r = mxCreateNumericArray(1, dims, mxINT32_CLASS, mxREAL);
    *((long*)mxGetData(r)) = PyInt_AS_LONG(obj);
    return r;
}

/** Convert Python bool to Matlab bool
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_bool(PyObject* obj)
{
    mxArray *r;
    int dims[1] = { 1 };
    r = mxCreateNumericArray(1, dims, mxLOGICAL_CLASS, mxREAL);
    if (PyObject_Compare(obj, Py_True) == 0) {
        *((char*)mxGetData(r)) = 1;
    } else {
        *((char*)mxGetData(r)) = 0;
    }
    return r;
}

/** Convert Python float to Matlab double
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_float(PyObject* obj)
{
   mxArray *r;
   int dims[1] = { 1 };
   r = mxCreateNumericArray(1, dims, mxDOUBLE_CLASS, mxREAL);
   *((double*)mxGetData(r)) = PyFloat_AS_DOUBLE(obj);
   return r;
}

/** Convert Python complex to Matlab double complex
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_complex(PyObject* obj)
{
    Py_complex c;
    mxArray *r;
    int dims[1] = { 1 };
    c = PyComplex_AsCComplex(obj);
    r = mxCreateNumericArray(1, dims, mxDOUBLE_CLASS, mxCOMPLEX);
    *mxGetPr(r) = c.real;
    *mxGetPi(r) = c.imag;
    return r;
}

/** Convert Python sequence to 1D Matlab cell array
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_sequence(PyObject* obj)
{
    mxArray *r;
    int dims[1];
    int k;
    dims[0] = PySequence_Size(obj);
    r = mxCreateCellArray(1, dims);
    for (k = 0; k < dims[0]; ++k) {
        PyObject *o;
        o = PySequence_GetItem(obj, k);
        if (o == NULL) {
            PyErr_Clear();
        } else {
            mxSetCell(r, k, mx_from_py(o));
            Py_DECREF(o);
        }
    }
    return r;
}

/** Convert Python string to Matlab char array
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_string(PyObject* obj)
{
    mxArray *r;
    int dims[2];
    char *buf;
    int len;
    mxChar* p;

    PyString_AsStringAndSize(obj, &buf, &len);
    dims[0] = 1;
    dims[1] = len;
    r = mxCreateCharArray(2, dims);
    p = mxGetData(r);
    for (; len > 0; --len) {
        *p = *buf;
        ++p; ++buf;
    }
    return r;
}

/**
 * Dump a __repr__ of the given object to warnings. Useful for debugging.
 * :param msg: Text to show before the dump
 * :param obj: The object whose __repr__ to dump [borrow reference]
 */
void dump_repr(const char *msg, PyObject* obj)
{
    char *buf;
    PyObject *repr = PyObject_Repr(obj);
    buf = PyString_AsString(repr);
    Py_DECREF(repr);
}

/**
 * Convert Python dict to 1x1 Matlab struct array.
 *
 * :param obj: Object to convert [Borrow reference]
 *
 * :note: If keys are not strings, their __repr__ is used instead!
 *        Fields that fail to convert to strings are silently skipped.
 *        Also, strings are chopped off at \x00 characters.
 */
mxArray *mx_from_py_dict(PyObject* obj)
{
    mxArray *r;
    int dims[1] = { 1 };
    PyObject *items;
    int nitems;
    int k;
    char *buf;
    int len;
    char **fieldnames;
    PyObject *repr = NULL;
    
    items = PyDict_Items(obj);
    if (!items) goto error;

    nitems = PyList_Size(items);
    fieldnames = mxCalloc(nitems, sizeof(char*));

    for (k = 0; k < nitems; ++k) {
        PyObject *o;
        
        o = PyList_GetItem(items, k);
        if (o == NULL) goto error;

        o = PyTuple_GetItem(o, 0);
        if (o == NULL) goto error;

        if (PyString_Check(o)) {
            PyString_AsStringAndSize(o, &buf, &len);
        } else {
            repr = PyObject_Repr(o);
            if (repr == NULL)
                continue; /* ... FIXME */
            buf = PyString_AsString(repr);
            len = strlen(buf);
        }

        fieldnames[k] = mxCalloc(len + 1, sizeof(char));
        memcpy(fieldnames[k], buf, len);
        fieldnames[k][len] = '\0';

        if (repr) {
            Py_DECREF(repr);
            repr = NULL;
        }
    }

    r = mxCreateStructArray(1, dims, nitems, (const char**)fieldnames);
    if (!r) goto error;

    for (k = 0; k < nitems; ++k) {
        PyObject *o;
        o = PyList_GetItem(items, k);
        if (o == NULL) goto error;

        o = PyTuple_GetItem(o, 1);
        if (o == NULL) goto error;

        mxSetFieldByNumber(r, 0, k, mx_from_py(o));
    }

    Py_DECREF(items);
    
    return r;

 error:
    PyErr_Clear();
    if (items) {
        Py_DECREF(items);
    }
    return mx_from_py_unknown(obj);
}

/**
 * Convert unknown python object to empty cell array.
 * Also send a warning with __repr__ of `obj` shown.
 *
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_unknown(PyObject* obj)
{
    int dims[1] = { 0 };
    char *buf;

    PyObject *type = PyObject_Type(obj);
    PyObject *repr = PyObject_Repr(type);
    buf = PyString_AsString(repr);
 
    Py_DECREF(repr);
    Py_DECREF(type);
    
    return mxCreateCellArray(1, dims);
}

#if defined(NUMERIC) || defined(NUMARRAY) || defined(NUMPY)
/** Convert a numeric Python object array to a Matlab cell array
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_arrayobject_object(PyArrayObject* obj)
{
    stride_t s;
    unsigned long index;
    PyObject **r;
    mxArray *arr;
    
    arr = mxCreateCellArray(obj->nd, (int*)obj->dimensions);
    if (!stride_init(obj->data, obj->nd, obj->dimensions, obj->strides, &s))
        return arr;

    index = 0;
    do {
        r = (PyObject**)stride_pos(&s);
        mxSetCell(arr, index, mx_from_py(*r));
        ++index;
    } while (stride_step(&s));

    return arr;
}

/** Convert a numeric Python array to Matlab array of the same data type
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_arrayobject(PyObject* obj_)
{
    PyArrayObject *obj = (PyArrayObject*)obj_;
    mxArray *r;
    mxClassID class;
    mxComplexity complexity;
    int stride;
    char *p;
    char *ip, *rp;
    int k, dim;
    int dummy_dim[2];

    switch (obj->descr->type_num) {
    case PyArray_CHAR:
    case PyArray_UBYTE:
        class=mxUINT8_CLASS;  complexity=mxREAL;
        break;
#ifdef NUMPY
    case NPY_BYTE:
#else
    case PyArray_SBYTE:
#endif
        class=mxINT8_CLASS;   complexity=mxREAL;
        break;
    case PyArray_SHORT:
        class=mxINT16_CLASS;  complexity=mxREAL;
        break;
    case PyArray_USHORT:
        class=mxUINT16_CLASS; complexity=mxREAL;
        break;
#if LP64
    case PyArray_LONG:
        class=mxINT64_CLASS; complexity=mxREAL;
        break;
#else
    case PyArray_LONG:
#endif
    case PyArray_INT:
        class=mxINT32_CLASS;  complexity=mxREAL;
        break;
    case PyArray_UINT:
        class=mxUINT32_CLASS;  complexity=mxREAL;
        break;
    case PyArray_FLOAT:
        class=mxSINGLE_CLASS; complexity=mxREAL;
        break;
    case PyArray_DOUBLE:
        class=mxDOUBLE_CLASS; complexity=mxREAL;
        break;
    case PyArray_CFLOAT:
        class=mxSINGLE_CLASS; complexity=mxCOMPLEX;
        break;
    case PyArray_CDOUBLE:
        class=mxDOUBLE_CLASS; complexity=mxCOMPLEX;
        break;
    case PyArray_OBJECT:
        return mx_from_py_arrayobject_object(obj);
#ifdef NUMPY
    case PyArray_STRING:
        /* 0d-string arrays */
        if (obj->nd == 0) {
            mxChar *cp;
            int len;
            char buf[1024];
            
            dummy_dim[0] = 1;
            dummy_dim[1] = obj->descr->elsize;
            
            r = mxCreateCharArray(2, dummy_dim);

            cp = mxGetData(r);
            p = obj->data;

            for (len = dummy_dim[1]; len > 0; --len) {
                *cp = *p;
                ++cp; ++p;
            }
            return r;
        } else {
            return mx_from_py_unknown(obj_);
        }
        break;
#endif
    default:
        return mx_from_py_unknown(obj_);
    }

    if (obj->nd == 0) {
        /* array scalar */
        dummy_dim[0] = 1;
        r = mxCreateNumericArray(1, dummy_dim, class, complexity);
        if (complexity == mxCOMPLEX) {
            memcpy(mxGetData(r),
                   obj->data, obj->descr->elsize/2);
            memcpy(mxGetImagData(r),
                   obj->data+obj->descr->elsize/2, obj->descr->elsize/2);
        } else {
            memcpy(mxGetData(r), obj->data, obj->descr->elsize);
        }
        return r;
    } else {
        r = mxCreateNumericArray(obj->nd, obj->dimensions, class, complexity);
    }

    stride = mxGetElementSize(r);

    if (complexity == mxCOMPLEX) {
        copy_to_contiguous(obj->data, obj->nd, obj->dimensions, obj->strides,
                           mxGetData(r), mxGetImagData(r), stride);
    } else {
        copy_to_contiguous(obj->data, obj->nd, obj->dimensions, obj->strides,
                           mxGetData(r), NULL, stride);
    }

    return r;
}
#endif

/** Convert Python none to an empty cell array
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py_none(PyObject* obj)
{
    int dims[1] = { 0 };
    return mxCreateCellArray(1, dims);
}

/**
 * Convert a Python object to a Matlab object.
 * 
 * Supports the following types:
 * - int, float, bool, dict, string, complex, sequence, None
 * - Numeric, NumArray or Numpy arrays
 *
 * :param obj: Object to convert [Borrow reference]
 */
mxArray *mx_from_py(PyObject* obj)
{
    if (PyInt_Check(obj))
        return mx_from_py_int(obj);
    else if (PyFloat_Check(obj))
        return mx_from_py_float(obj);
    else if (PyBool_Check(obj))
        return mx_from_py_bool(obj);
    else if (PyDict_Check(obj))
        return mx_from_py_dict(obj);
    else if (PyString_Check(obj))
        return mx_from_py_string(obj);
#if defined(NUMERIC) || defined(NUMARRAY) || defined(NUMPY)
    else if (PyArray_Check(obj))
        return mx_from_py_arrayobject(obj);
#endif
    else if (PyComplex_Check(obj))
        return mx_from_py_complex(obj);
    else if (PySequence_Check(obj))
        return mx_from_py_sequence(obj);
    else if (PyObject_Compare(obj, Py_None) == 0)
        return mx_from_py_none(obj);
    else
        return mx_from_py_unknown(obj);
}


/*****************************************************************************/
/** Type conversion: Matlab -> Python
 **/

PyObject *py_from_mx(const mxArray* arr);
PyObject *py_from_mx_unknown(const mxArray* arr);

int mx_is_string(const mxArray *a)
{
    return mxIsChar(a) && mxGetM(a) == 1;
}
char *string_from_mx(const mxArray* a, unsigned int *buflen, char* errmsg)
{
    char *buf;

    *buflen = mxGetM(a) * mxGetN(a) + 1;
    buf = mxCalloc(*buflen, sizeof(char));
    
    return buf;
}

int mx_is_scalar(const mxArray *a)
{
    int nd;
    const int *dims;
    nd = mxGetNumberOfDimensions(a);
    dims = mxGetDimensions(a);

    return (nd == 1 && dims[0] == 1)
        || (nd == 2 && dims[0] == 1 && dims[1] == 1);
}


#define PY_OBJECT_ARRAY_FROM_MX(arr, obj, index, mxcall)        \
do {                                                            \
    int nd;                                                     \
    const int *dims;                                            \
    int *i;                                                     \
    stride_t s;                                                 \
    PyObject **r;                                               \
    PyArrayObject *obj_;                                        \
                                                                \
    nd = mxGetNumberOfDimensions(arr);                          \
    dims = mxGetDimensions(arr);                                \
                                                                \
    /* non-multidimensional arrays => lists */                  \
    if (nd == 1 || (nd == 2 && dims[0] == 1)) {                 \
        obj = PyList_New(nd == 1 ? dims[0] : dims[1]);          \
        for (index = 0; index < PyList_Size(obj); ++index) {    \
            mxArray *a;                                         \
            a = mxcall;                                         \
            PyList_SET_ITEM(obj, index, py_from_mx(a));         \
        }                                                       \
        break;                                                  \
    } else if (nd == 2 && (dims[0] == 0 || dims[1] == 0)) {     \
        obj = PyList_New(0);                                    \
        break;                                                  \
    }                                                           \
                                                                \
    /* multidimensional arrays => obj.arrays */                 \
    obj = PyArray_FromDims(nd, (int*)dims, PyArray_OBJECT);     \
    if (!obj)                                                   \
        goto _objarray_error;                                   \
    obj_ = (PyArrayObject*)obj;                                 \
    if (!stride_init(obj_->data, obj_->nd, obj_->dimensions,    \
                     obj_->strides, &s))                        \
        break;                                                  \
                                                                \
    index = 0;                                                  \
    do {                                                        \
        mxArray *a;                                             \
                                                                \
        r = (PyObject**)stride_pos(&s);                         \
                                                                \
        a = mxcall;                                             \
        if (a) {                                                \
            *r = py_from_mx(a);                                 \
        } else {                                                \
            *r = Py_None;                                       \
            Py_INCREF(Py_None);                                 \
        }                                                       \
                                                                \
        ++index;                                                \
    } while (stride_step(&s));                                  \
    break;                                                      \
 _objarray_error:                                               \
    if (obj) Py_DECREF(obj);                                    \
    obj = py_from_mx_unknown(arr);                              \
} while (0)



/** Matlab cell array to Numeric/numpy object arrays */
PyObject *py_from_mx_cell(const mxArray *arr)
{
    PyObject *obj = NULL;
    unsigned long index;

    PY_OBJECT_ARRAY_FROM_MX(arr, obj, index, mxGetCell(arr, index));
    return obj;
}

/** Matlab numeric array to Python numeric array */
PyObject *py_from_mx_numeric(const mxArray* arr)
{
    int nd;
    const int *dims;
    int *i;
    PyArrayObject *obj = NULL;
    int type = -1;

    switch (mxGetClassID(arr)) {
    case mxDOUBLE_CLASS:
        type = mxIsComplex(arr) ? PyArray_CDOUBLE : PyArray_DOUBLE;
        break;
    case mxSINGLE_CLASS:
        type = mxIsComplex(arr) ? PyArray_CFLOAT : PyArray_FLOAT;
        break;
    case mxINT8_CLASS:
    case mxINT16_CLASS:
    case mxINT32_CLASS:
    case mxINT64_CLASS:
        if (mxIsComplex(arr)) return py_from_mx_unknown(arr);
        switch (mxGetElementSize(arr)) {
#ifdef NUMPY
        case 1: type = PyArray_BYTE; break;
#else
        case 1: type = PyArray_SBYTE; break;
#endif
        case 2: type = PyArray_SHORT; break;
        case 4: type = PyArray_INT; break;
        default: return py_from_mx_unknown(arr);
        }
        break;
    case mxCHAR_CLASS:
    case mxLOGICAL_CLASS:
    case mxUINT8_CLASS:
    case mxUINT16_CLASS:
    case mxUINT32_CLASS:
    case mxUINT64_CLASS:
        if (mxIsComplex(arr)) return py_from_mx_unknown(arr);
        switch (mxGetElementSize(arr)) {
        case 1: type = PyArray_UBYTE; break;
        case 2: type = PyArray_USHORT; break;
        case 4: type = PyArray_UINT; break;
        default: return py_from_mx_unknown(arr);
        }
        break;
    default:
        return py_from_mx_unknown(arr);
    }

    nd = mxGetNumberOfDimensions(arr);
    dims = mxGetDimensions(arr);
    obj = (PyArrayObject*)PyArray_FromDims(nd, (int*)dims, type);
    if (!obj)
        goto error;

    if (mxIsComplex(arr)) {
        copy_from_contiguous(obj->data, obj->nd, obj->dimensions, obj->strides,
                             mxGetData(arr), mxGetImagData(arr),
                             mxGetElementSize(arr));
    } else {
        copy_from_contiguous(obj->data, obj->nd, obj->dimensions, obj->strides,
                             mxGetData(arr), NULL, mxGetElementSize(arr));
    }

    return (PyObject*)obj;

 error:
    if (obj) Py_DECREF(obj);
    return py_from_mx_unknown(arr);
}

/** Matlab char array to Python string etc. */
PyObject *py_from_mx_char(const mxArray* arr)
{
    char *buf;
    int buflen;
    PyObject *obj;

    buf = string_from_mx(arr, &buflen, "");
    obj = PyString_FromStringAndSize(buf, buflen-1); /* chop trailing \x00 */
    
    return obj;
}

/** Matlab 1x1 struct array to Python dict */
PyObject *py_from_mx_struct(const mxArray* arr)
{
    int nfields;
    int field_number;
    PyObject *obj;

    nfields = mxGetNumberOfFields(arr);

    obj = PyDict_New();

    for (field_number = 0; field_number < nfields; ++field_number) {
        const char *name;
        
        name = mxGetFieldNameByNumber(arr, field_number);

        if (mx_is_scalar(arr)) {
            mxArray *a;
            a = mxGetFieldByNumber(arr, 0, field_number);
            PyDict_SetItemString(obj, name, py_from_mx(a));
        } else {
            unsigned long index;
            PyObject* o;
            PY_OBJECT_ARRAY_FROM_MX(
                arr, o, index, mxGetFieldByNumber(arr, index, field_number));
            PyDict_SetItemString(obj, name, (PyObject*)o);
        }
    }
    
    return obj;
}

/** Matlab unknown array to Python array */
PyObject *py_from_mx_unknown(const mxArray* arr)
{
    Py_INCREF(Py_None);
    return Py_None;
}

/** Matlab object to Python object */
PyObject *py_from_mx(const mxArray* arr)
{

    if (mxIsCell(arr))
        return py_from_mx_cell(arr);
    else if (mx_is_string(arr))
        return py_from_mx_char(arr);
    else if (mxIsNumeric(arr) || mxIsLogical(arr))
        return py_from_mx_numeric(arr);
    else if (mxIsStruct(arr))
        return py_from_mx_struct(arr);
    else
        return py_from_mx_unknown(arr);
}

/*
 * Python module functions
 * 
 */
//[model, recList] = full_flowLSA (urmTraining, icm, 5); in matlab
//mlfFull_flowLSA(int nargout, mxArray** model, mxArray** recList, mxArray* urm, mxArray* icm, mxArray* userIndex);
//rec.full_flowLSA([(1,2,3), (1,3,4), (1,3,4)], [(1,3), (2,4)], 5)
static PyObject * full_flowLSA(PyObject *self, PyObject *args){
	mxArray** model, **recList;
	mxArray *urm, *icm, *userIndex;
	PyObject *py_urm;
	PyObject *py_icm;
	PyObject *user_id;
	
	if (!PyArg_ParseTuple(args, "OOO", &py_urm, &py_icm, &user_id))
        return NULL;
    
    
    //urm = mx_from_py(py_urm);
    //printf("value of urm: %s", mxArrayToString(urm));
    //icm = mx_from_py(py_icm);
    //printf("value of icm: %s", mxArrayToString(icm));
    //userIndex = mx_from_py(user_id);
    //printf("value of userIndex: %s", mxArrayToString(userIndex));
    //mlfFull_flowLSA(2, model, recList, urm, icm, userIndex);
   
	Py_INCREF(Py_None);
	return Py_None; 
}

static PyObject *hello(PyObject *self, PyObject *args){
	mlfHello();
	
	mxArray *a1, *a, *a2;
	PyObject *py_a1, *py_a2;
	
	if (!PyArg_ParseTuple(args, "OO", &py_a1, &py_a2))
        return NULL;
	
	
	a1 = mx_from_py(py_a1);
	printf("value of urm: %s", mxArrayToString(a1));
	a2 = mx_from_py(py_a2);
	printf("value of urm: %s", mxArrayToString(a2));
	mlfAddmatrix(1, a, a1, a2);	
	printf("value of urm: %s", mxArrayToString(a));

	Py_INCREF(Py_None);
	return Py_None;
}

static PyMethodDef RecMethods[] = {
    {"full_flowLSA",  full_flowLSA, METH_VARARGS, "flowLSA model creation"},
    {"hello", hello, METH_VARARGS, "hello world function" },
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

PyMODINIT_FUNC
initrec(void)
{	
    PyObject *m;

    m = Py_InitModule("rec", RecMethods);
    if (m == NULL)
        return;
	
	libAlgInitialize();
	
    RecError = PyErr_NewException("rec.error", NULL, NULL);
    Py_INCREF(RecError);
    PyModule_AddObject(m, "error", RecError);
}

