from pyramid.view import view_config
#get all classes from the models to be used
from models import *
from whisperer import Whisperer
import tasks

@view_config(context='whisperer.models.MyApp',
             renderer='templates/base.pt')
def admin(request):
	return dict()

@view_config(name='create',
			 context='whisperer.models.MyApp',
             renderer='json')
def admin(context, request):
	for algname in Whisperer.get_algnames():
		tasks.gen_model(algname)
	return dict()

@view_config(context='whisperer.models.Algorithm',
             renderer='templates/model.pt')
def single_model(context, request):
    return dict()

@view_config(name='create',
			 context='whisperer.models.Algorithm',
             renderer='json')
def create_model(context, request):
	tasks.gen_model(context.name)
	return dict(test='success')
    
