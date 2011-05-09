from pyramid.config import Configurator
from whisperer.resources import Root

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(root_factory=Root, settings=settings)
    config.add_view('whisperer.views.my_view',
                    context='whisperer:resources.Root',
                    renderer='whisperer:templates/mytemplate.pt')
    config.add_static_view('static', 'whisperer:static')
    return config.make_wsgi_app()

