#include <Python.h>

static PyObject *RecError;

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

static PyMethodDef RecMethods[] = {
    {"system",  rec_system, METH_VARARGS, "Execute a shell command."},
    {NULL, NULL, 0, NULL}        /* Sentinel */
};

PyMODINIT_FUNC
initrec(void)
{
	/*
	 * when impoted this is executed
	 */
	(void) Py_InitModule("rec", RecMethods);
	
    PyObject *m;

    m = Py_InitModule("rec", RecMethods);
    if (m == NULL)
        return;

    RecError = PyErr_NewException("rec.error", NULL, NULL);
    Py_INCREF(RecError);
    PyModule_AddObject(m, "error", RecError);
}

