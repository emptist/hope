#-------------------- subscriptions --------------------------------
Meteor.subscribe "bsckpisChannel"
Meteor.subscribe "departmentsChannel"
Meteor.subscribe "hospitalsChannel"



#------------------------ helpers ------------------------------------ 
showAsEditMode = -> Session.get "showButtons"
share.showAsEditMode = showAsEditMode

share.logSet = (a, b) ->
	r = Session.set a, b
	share.consolelog "now #{a} is #{b}"
	r


share.isViewing = (viewName...)-> share.consolelog Session.get('currentView') in viewName


share.getKpiObj = (e, t) ->
	getValue = (id) -> t.find(id).value
	indx:getValue "#title"
	perspective: getValue "#perspective"
	category: getValue "#category"
	title: getValue "#title"
	definition: getValue "#definition"
	type: getValue "#type" # the greater the better vs. the less the better vs. the closer the better
	mesure: getValue "#mesure" # how to score
	depts: getValue "#depts" # for which dept


share.getDepartmentObj = (e, t) ->
	getValue = (id) ->	t.find(id).value
	indx: (getValue "input#hospital") + '-' +(getValue "input#department" )
	hospital: getValue "input#hospital"
	department: getValue "input#department" 
	category: getValue "input#category"
	departmentKPIs: []#getValue "ul#departmentKPIsTmp" # we should geKPIhe bsc object here


share.viewDetail = (viewName, t)-> 
	Backbone.history.navigate '/' + viewName + '&' +  t.find('#' + viewName).value, true #decodeURI 




#------------------------ router ------------------------------------
logSetCurrentView = (currentView)->
	share.logSet "currentView", currentView


HOPERouter = Backbone.Router.extend
	routes: # ! this order matters ! stupid!!
		"": "main"
		"bsckpis": "bsckpis"
		"departments": "departments"
		"newKpiForm": "newKpiForm"
		"newDepartmentForm": "newDepartmentForm"
		#"hospitals": "hospitals" 
		":detail": "detail" # 查看single object, see below
		
	main: -> logSetCurrentView "main"
	bsckpis: ->	logSetCurrentView "bsckpis"	
	departments: -> logSetCurrentView "departments"
	newKpiForm: -> logSetCurrentView "newKpiForm"
	newDepartmentForm: -> logSetCurrentView "newDepartmentForm"
	#hospitals: -> logSetCurrentView "hospitals"
	detail: (detail) -> # detail is string formatted like 'view-detail'
		sp = detail.split '&'
		logSetCurrentView decodeURI sp[0] # this could be everything that contains details
		share.logSet "currentDetail",  decodeURI sp[1] # this leading to one detail of the viewed objected




#------------------------ do initiatings here -----------------------
Meteor.startup -> # 开始
	new HOPERouter
	Session.set "showButtons",true
	Backbone.history.start pushState: true




#------------------------ Template.main------------------------------- 
Template.main.adminLoggedIn = -> share.adminLoggedIn()

Template.main.events 
	'click a[href^= "/"]': (e,t) ->  # means (a.href)a[href] ="/"
		# Note: Backbone.history.navigate decodeURI e.currentTarget.pathname will not work!
		Backbone.history.navigate e.currentTarget.pathname, true
		e.preventDefault()




#------------------------- Template.header -----------------------------
Template.header.currentMode = -> 
	share.consolelog if showAsEditMode() is true then "打印模式" else "編輯模式"


Template.header.showButtons = -> showAsEditMode()


Template.header.adminLoggedIn = -> share.adminLoggedIn()


Template.header.events
	'click #bsckpis': -> Backbone.history.navigate '/bsckpis', true 
	'click #departments': -> Backbone.history.navigate '/departments', true
	'click #newKpiForm': ->	Backbone.history.navigate '/newKpiForm', true
	'click #newDepartmentForm': -> Backbone.history.navigate '/newDepartmentForm', true
	'click #printable': -> Session.set "showButtons", not showAsEditMode()
	#'click #hospitals': -> Backbone.history.navigate '/hospitals', true 
	



#------------------------- bsckpis ---------------------------------------
Template.bsckpis.show = ->
	share.isViewing("bsckpis","perspective") #or share.isViewing "perspective"

Template.bsckpis.showButtons = ->
	showAsEditMode()

Template.bsckpis.kpis = ->
	if share.isViewing "perspective"
		share.KPIs.find perspective: Session.get "currentDetail" 
	else
		share.consolelog share.KPIs.find {}, sort:{perspective: -1, category: -1, title: -1}

#------------------------- newKpiForm ----------------------------------
Template.newKpiForm.show = -> share.isViewing "newKpiForm" 


Template.newKpiForm.events
	'click #save': (e,t) -> 
		Meteor.call "kpi", #perspective, category, title, definition, type, mesure, depts
			share.getKpiObj e,t
			(err, id)->
				share.viewDetail "perspective",t



#------------------------- kpi -------------------------------------------
Template.kpi.editting = ->
	Session.get "editting #{@._id}"



#------------------------- editKpiForm -----------------------------------
Template.editKpiForm.show = ->
	true #since this should display in place so don't use share.isViewing "editKpiForm"

Template.editKpiForm.events
	'click #save': (e,t) -> 
		Meteor.call "kpi", #perspective, category, title, definition, type, mesure, depts
			share.getKpiObj e,t
			(err, id) ->
				share.consolelog "editKpiForm event save #{t.data._id}" # is known that share.._id here is undefined 
				Session.set "editting #{t.data._id}", false
		


#------------------------- viewKpiForm ----------------------------------
Template.viewKpiForm.showButtons =->
	showAsEditMode()

Template.viewKpiForm.events
	
	'click #editKpiForm':(e,t) ->
		share.consolelog "viewKpiForm event editKpiForm #{@._id}"
		Session.set "editting #{@._id}", true #"editting #{t.data._id}", true
	
	'click #removeKPI':	(e,t) ->
		share.consolelog "viewKpiForm event removeKPI #{@._id}"
		Meteor.call "removeKPI", @._id
	


#------------------------- departments ----------------------------------- 
#------------------------- newDepartmentForm -----------------------------

