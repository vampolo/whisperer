from pyramid.view import view_config
#get all classes from the models to be used
from models import *

@view_config(name='addUser', context='whisperer.models.MyApp',
             renderer='json')
def add_user(request):
	username = request.GET.get('username')
	if not username:
		return dict()	
	session = DBSession()
	#if was in a form in a .pt context, for example: if 'form.submitted' in request.params: 
	#username = request.params['username']
	user_added = User(username)
	session.add(user_added)
	#necessary?
	session.commit()
	added_row = session.query(User).filter(User.id.in_([user_added.id])).all()
	return dict(added_user = added_row)        

@view_config(name='addItem', context='whisperer:models.Item',
             renderer='json')
@view_config(name='addMetadataValue', context='whisperer:models.Metadata',
             renderer='json')
@view_config(name='addItemMetadata', context='whisperer:models.ICMcell',
             renderer='json')
def add_completeItem(request):
	#booo... this is how i Should get?
	item_name = request.GET.get('item_name')
	metadata_name = request.GET.get('metadata_name')
	metadata_type = request.GET.get('metadata_type')
	metadata_lang = request.GET.get('metadata_lang')
	dataSet = request.GET.get('dataSet')
	if not item_name:
		return dict()
	#Adding in session like in docs.pylonsproject.org/projects/pyramid/dev/tutorials/wiki2/definingviews.html
	session = DBSession()
	item_added = Item(item_name, dataSet)
	metadata_added = Metadata(metadata_name, metadata_type, metadata_lang)
	session.add_all(item_added, metadata_added)
	#necessary to use the objects on the ICM?	
	session.commit()
	#session = DBSession()	
	ICMcell_added = ICMcell(item_added.id, metada_added.id)
	session.add(ICMcell_added)
	session.commit()	
	added_row = session.query(ICMcell).filter(ICMcell.id.in_([ICMcell_added.id])).all()
	return dict(ICMcell_added = added_row)        


#should act just as above...
@view_config(name='addRating', context='whisperer:models.URMcell',
             renderer='json')
def add_rating(request):
	#booo... this is how i Should get?
	userID = request.GET.get('user')
	itemID = request.GET.get('item')
	rating = request.GET.get('rating')
	if not rating:
		return dict()
	#Adding in session like in docs.pylonsproject.org/projects/pyramid/dev/tutorials/wiki2/definingviews.html
	session = DBSession()
	URMcell_added = URMcell(userID, itemID, rating)
	session.add(URMcell_added)
	session.commit()	
	added_row = session.query(URMcell).filter(URMcell.id.in_([URMcell_added.id])).all()
	return dict(URMcell_added = added_row)        


@view_config(name='getRecommendation', context='whisperer:models.User',
             renderer='json')            
def get_Recommendation(request):	
	userID = request.GET.get('user')
	if not userID:
		return dict()
	#here we should use the output of the algorithm, organize it and retrieve the TOP 10/x items...
	return dict()





""" 
def add_page(request):
    name = request.matchdict['pagename']
    if 'form.submitted' in request.params:
        session = DBSession()
        body = request.params['body']
        page = Page(name, body)
        session.add(page)
        return HTTPFound(location = route_url('view_page', request,
                                              pagename=name))
    save_url = route_url('add_page', request, pagename=name)
    page = Page('', '')
    return dict(page=page, save_url=save_url)
"""
