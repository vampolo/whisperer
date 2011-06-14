from pyramid.config import Configurator
from sqlalchemy import engine_from_config
from pyramid.events import subscriber
from pyramid.events import BeforeRender
from pyramid.renderers import get_renderer
import helpers
from models import appmaker

def main(global_config, **settings):
    	""" This function returns a WSGI application.
    	"""
    	engine = engine_from_config(settings, 'sqlalchemy.')
    	get_root = appmaker(engine)
    	config = Configurator(settings=settings, root_factory=get_root)
    	config.add_subscriber(add_renderer_globals, BeforeRender)
    	config.add_static_view('static', 'whisperer:static')
    	config.scan()
	return config.make_wsgi_app()

def add_renderer_globals(event):
	event.update({'base': get_renderer('templates/base.pt').implementation()})
	event.update({'h': helpers})
	


