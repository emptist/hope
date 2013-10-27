share.KPIs = new Meteor.Collection "bsckpis" # expose this for debugging
share.Hospitals = new Meteor.Collection "hospitals"
share.Teams= new Meteor.Collection "teams"
share.CurrentObjects = new Meteor.Collection "currentObjects"


@Teams = share.Teams  # for browser console watching

currentUserEmail = ->
	Meteor.user()?.emails?[0].address

# supadmin is admin for the whole service of all hospitals
supadmins = ['j@k.com']
admins = ['j@k.com','h@l.com','y@u.com']

share.supadminLoggedIn = -> 
	currentUserEmail() in supadmins

share.adminLoggedIn = -> 
	currentUserEmail() in admins

share.consolelog = (t)->
	console.log "in this as #{(v for v of this)[0..2]}:  #{t} as object #{(e for e of t)[0..2]}" 
	t

share.GetHospital = -> share.CurrentObjects.findOne()?.hospital

share.SetHospital = (hospital)-> 
	obj = indx: hospital
		hospital: hospital
		createOn: new Date

	share.CurrentObjects.update indx: obj.indx, 
		obj, 
		upsert: true	