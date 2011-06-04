def populate_database():
	'''
	populate database with fake data
	'''
	from random import randint
	
	session = DBSession()
	
	#create some users for first
	users = ['Andeia', 'Vincenzo', 'Leonardo', 'Paolo']
	items = ['film1', 'film2', 'film3', 'film4', 'film5']
	metadatas = [dict(name='primo metadato', type='boh', lang='eng'),
				 dict(name='secondo metadato', type='boh2', lang='eng'),
				 dict(name='metadato3', type='boh3', lang='eng'),
				 dict(name='metadato4', type='boh4', lang='eng'),
				 dict(name='metadato5', type='boh5', lang='eng')]
	
	
	for meta in metadatas:
		if not session.query(Metadata).filter(Metadata.name.in_([meta.get('name')])).all():
			metadata = Metadata(meta.get('name'), meta.get('type'), meta.get('lang'))
			session.add(metadata)
			session.flush()
	
	metadatas = session.query(Metadata).all()
	max_metadata = len(metadatas)-1

	for item in items:
		if not session.query(Item).filter(Item.name.in_([item])).all():			
			new_item = Item(item)
			new_item.metadatas.append(metadatas[randint(0,max_metadata)])
			session.add(new_item)
			session.flush()

	items = session.query(Item).all()
	max_item = len(items)-1
	
	for username in users:
		if not session.query(User).filter(User.name.in_([username])).all():
			user = User(username)
			user.ratings.append(Rating(user, items[randint(0, max_item)], randint(0,5)))
			session.add(user)
			session.flush()
	
	users = session.query(User).all()
	max_user = len(users)-1
	
	ratings = session.query(Rating).all()
	max_ratings = len(ratings)
