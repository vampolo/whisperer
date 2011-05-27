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
	if not session.query(User).filter(User.username.in_([username])).all():
		user_added = User(username)
		session.add(user_added)
		session.flush()
		transaction.commit()
		added_obj = session.query(User).filter(User.username.in_([username])).first()
		return dict(added_user_id = str(added_obj.id), added_user_name = str(added_obj.username))        
	return dict(message = 'Username already used, please insert another')
	
@view_config(name='addItem', context='whisperer.models.MyApp',
             renderer='json')
def add_Item(request):
	item_name = request.GET.get('item_name')
	dataSet = request.GET.get('dataSet')
	if not item_name:
		return dict()
	session = DBSession()
	if not session.query(Item).filter(Item.itemName.in_([item_name])).all():			
		item_added = Item(item_name, dataSet)
		session.add(item_added)
		session.flush()
		transaction.commit()
		added_item_obj = session.query(Item).filter(Item.itemName.in_([item_name])).first()
		return dict(added_item = str(added_item_obj.itemName), added_item_dataset = str(added_item_obj.dataSet))                			
	return dict(message = 'Item already exists, please insert another')	

@view_config(name='addinICM', context='whisperer.models.MyApp',
             renderer='json')
def add_Metadata_to_Item(request):
	item_name = request.GET.get('item_name')
	metadata_name = request.GET.get('metadata_name')
	metadata_type = request.GET.get('metadata_type')
	metadata_lang = request.GET.get('metadata_lang')
	if not item_name:
		return dict()
	session = DBSession()
	if not session.query(Item).filter(Item.itemName.in_([item_name])).all():
		return dict(warning='No item name matched! Please, add the item on the DB first')				
	if not session.query(Metadata).filter(Metadata.metaName.in_([metadata_name])).all():			
		metadata_added = Metadata(metadata_name, metadata_type, metadata_lang)
		session.add(metadata_added)
		session.flush()
		transaction.commit()
	#get objects to use in ICM
	added_item_obj = session.query(Item).filter(Item.itemName.in_([item_name])).first()
	added_metadata_obj = session.query(Metadata).filter(Metadata.metaName.in_([metadata_name])).first()	
	#Adds in ICM
	ICMcell_added = ICMcell(added_item_obj.id, added_metadata_obj.id)
	session.add(ICMcell_added)
	session.flush()
	transaction.commit()
	#Necessary to get again
	added_item_obj = session.query(Item).filter(Item.itemName.in_([item_name])).first()
	added_metadata_obj = session.query(Metadata).filter(Metadata.metaName.in_([metadata_name])).first()		
	added_cells_list = session.query(ICMcell).filter(ICMcell.itemId.in_([added_item_obj.id])).all()
	added_cell_obj = added_cells_list[-1]		
	return dict(ICM_itemID = str(added_cell_obj.itemId), ICM_metadataID = str(added_cell_obj.metadataId),
		added_metadata = str(added_metadata_obj.metaName))                			      			
	

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




