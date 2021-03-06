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
	#console.log "@data", this.data, "is", t.data 
	t

###
share.GetHospital = -> share.CurrentObjects.findOne()?.hospital

share.SetHospital = (hospital)-> 
	obj = indx: hospital
		hospital: hospital
		createOn: new Date

	share.CurrentObjects.update indx: obj.indx, 
		obj, 
		upsert: true
###	