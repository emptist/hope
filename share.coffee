share.KPIs = new Meteor.Collection "bsckpis" # expose this for debugging
share.Hospitals= new Meteor.Collection "hospitals"
share.Departments= new Meteor.Collection "departments"
	
@Departments = share.Departments  # for browser console watching

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
	console.log t
	t	