from pyramid.config import Configurator
from sqlalchemy import engine_from_config

from whisperer.models import appmaker

def main(global_config, **settings):
    	""" This function returns a WSGI application.
    	"""
    	engine = engine_from_config(settings, 'sqlalchemy.')
    	get_root = appmaker(engine)
    	config = Configurator(settings=settings, root_factory=get_root)
    	config.add_static_view('static', 'whisperer:static')
    	config.add_view('whisperer.views.view_root', context='whisperer.models.MyApp', renderer="templates/root.pt")
        config.add_view('whisperer.views.view_model', context='whisperer.models.MyModel', renderer="templates/model.pt")
    	config.scan()
   	return config.make_wsgi_app()


