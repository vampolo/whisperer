from pyramid.view import view_config
#get all classes from the models to be used
from models import *
from whisperer import Whisperer

@view_config(context='whisperer.models.MyApp',
             renderer='templates/base.pt')
def admin(request):
	return dict()

@view_config(name='single_model', context='whisperer.models.MyApp',
             renderer='templates/model.pt')
def single_model(context, request):
    return {'items':list(context), 'project':'whisperer'}
    
