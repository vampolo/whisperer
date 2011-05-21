#include <Python.h>
#include <libAlg.h>

static PyObject *RecError;


//just testing function
static PyObject *
rec_system(PyObject *self, PyObject *args)
{
    const char *command;
    int sts;

    if (!PyArg_ParseTuple(args, "s", &command))
        return NULL;
    sts = system(command);
    if (sts < 0) {
        PyErr_SetString(RecError, "System command failed");
        return NULL;
    }
    return PyLong_FromLong(sts);
}

//[model, recList] = full_flowLSA (urmTraining, icm, 5);
static PyObject * full_flowLSA(PyObject *self, PyObject *args){
	
	Py_INCREF(Py_None);
	return Py_None; 
}

static PyMethodDef RecMethods[] = {
    {"system",  rec_system, METH_VARARGS, "Execute a shell command."},
    {"full_flowLSA",  full_flowLSA, METH_VARARGS, "flowLSA model creation"},
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

