from pyramid.view import view_config
#get all classes from the models to be used
from models import *

@view_config(name='add', context='whisperer.models.User',
             renderer='json')
def add_user(request):
	name = request.POST.get('name')
	if not name:
		return dict(error = 'no name provided')	
	session = DBSession()
	if not session.query(User).filter(User.name.in_([name])).all():
		user_added = User(name=name)
		session.add(user_added)
		session.flush()
		return dict(name=user_added.name, id=user_added.id)        
	return dict(error = 'Username already used, please insert another')
	
@view_config(name='add', context='whisperer.models.Item',
             renderer='json')
def add_Item(request):
	name = request.POST.get('name')
	if not name:
		return dict(error = 'no name provided')
	session = DBSession()
	if not session.query(Item).filter(Item.name.in_([name])).all():			
		item_added = Item(name=name)
		session.add(item_added)
		session.flush()
		return dict(name = item_added.name, id = item_added.id)                			
	return dict(message = 'Item already exists, please insert another')	

@view_config(name='add', context='whisperer.models.Metadata',
             renderer='json')
def add_Metadata_to_Item(context, request):
	name = request.POST.get('name')
	mtype = request.POST.get('type')
	lang = request.POST.get('lang')
	if not name or not mtype or not lang:
		return dict(error = 'parameters missing')
	session = DBSession()
	try:
		metadata = session.query(Metadata).filter(Metadata.name == name).one()
	except NoResultFound:			
		metadata = Metadata(name = name, type = mtype, lang =lang)
		session.add(metadata)
		session.flush()
	metadata.items.append(context.__parent__)
	return dict(item_id = context.__parent__.id, id = metadata.id,
		name = metadata.name, type = metadata.type, lang = metadata.lang)                			      			
	

@view_config(name='addRating', context='whisperer.models.MyApp',
             renderer='json')
def add_rating(request):
	userID = request.GET.get('user')
	itemID = request.GET.get('item')
	rating = request.GET.get('rating')
	if not rating:
		return dict()
	session = DBSession()
	URMcell_added = URMcell(userID, itemID, rating)
	session.add(URMcell_added)
	session.flush()
	transaction.commit()
	#To retrieve the last,  we must get all the list the get the last element
	added_cells_list = session.query(URMcell).filter(URMcell.itemId.in_([itemID])).all()
	added_cell_obj = added_cells_list[-1]		
	return dict(URMcell_added_user = str(added_cell_obj.userId), URMcell_added_item = str(added_cell_obj.itemId), 
		rating = str(rating))           

@view_config(name='getRecommendation', context='whisperer:models.User',
             renderer='json')            
def get_Recommendation(request):	
	userID = request.GET.get('user')
	if not userID:
		return dict()
	#here we should use the output of the algorithm, organize it and retrieve the TOP 10/x items...
	return dict()




