from pyramid.view import view_config
#get all classes from the models to be used
from models import *

@view_config(name='single_model', context='whisperer.models.MyApp',
             renderer='templates/model.pt')
def admin(request):
	return dict()

def view_root(context, request):
    return {'items':list(context), 'project':'whisperer'}

def view_model(context, request):
    return {'item':context, 'project':'whisperer'}
    
