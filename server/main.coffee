Meteor.publish "bsckpisChannel" , -> 
	share.KPIs.find()


###
Meteor.publish "teamsChannel" , (hospital)-> 
	share.Teams.find hospital: hospital
###


Meteor.publish "teamsChannel" , ()-> 
	share.Teams.find()


Meteor.publish "tasksChannel" , ()-> 
	share.Tasks.find()


Meteor.publish "hospitalsChannel" , -> 
	share.Hospitals.find()

Meteor.publish "currentObjects" , -> 
	share.CurrentObjects.find()


removeFrom = (collection, id)->
		if share.adminLoggedIn
			collection.remove _id: id

upsertTo = (collection, obj)-> 
	# each obj should have an indx; return Mongodb object _id
	if share.adminLoggedIn
		obj.createdOn = new Date
		share.consolelog collection.update indx: obj.indx ,
			obj, 
			upsert: true

insertInto = (collection, obj)->
		if share.adminLoggedIn
			obj.createdOn = new Date
			collection.insert obj



Meteor.methods
	removeKPI: (id)-> removeFrom share.KPIs, id 
	removeTeam: (id)-> removeFrom share.Teams, id
	removeTask: (id)-> removeFrom share.Tasks, id
	#removeHospital: (id)-> removeFrom share.Hospitals, id 
	
	kpi: (obj)-> upsertTo share.KPIs, obj
	team: (obj)-> upsertTo share.Teams, obj
	task: (obj)-> upsertTo share.Tasks, obj

	#hospital: (obj)-> upsertTo share.Hospitals, obj
		
			