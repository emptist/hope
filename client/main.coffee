# subscriptions
Meteor.subscribe "bsckpisChannel"
Meteor.subscribe "hospitalsChannel"

#------------------------ helpers ------------------------------------ 
showAsEditMode = -> # was causing exeptions when put outside server & client folders
	Session.get "showButtons"
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
	Backbone.history.navigate '/' + viewName + '&' + decodeURI t.find('#' + viewName).value, true 

#------------------------ router ------------------------------------
logSetCurrentView = (currentView)->
	share.logSet "currentView", currentView

HOPERouter = Backbone.Router.extend
	routes: # ! this order matters ! stupid!!
		"": "main"
		"bsckpis": "bsckpis"
		"newKpiForm": "newKpiForm"
		"departments": "departments"
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
	'click a[href^= "/" ]': (e,t) ->  # means (a.href)a[href] ="/"
		Backbone.history.navigate decodeURI e.currentTarget.pathname, true
		e.preventDefault()

#------------------------- Template.header -----------------------------
Template.header.currentMode = -> share.consolelog if showAsEditMode() is true then "打印模式" else "編輯模式"
Template.header.showButtons = -> showAsEditMode()
Template.header.adminLoggedIn = -> share.adminLoggedIn()
Template.header.events
	'click #bsckpis': -> Backbone.history.navigate '/bsckpis', true 
	'click #departments': -> Backbone.history.navigate '/departments', true
	'click #newKpiForm': ->	Backbone.history.navigate '/newKpiForm', true
	'click #newDepartmentForm': -> Backbone.history.navigate '/newDepartmentForm', true
	'click #printable': -> Session.set "showButtons", not showAsEditMode()
	#'click #hospitals': -> Backbone.history.navigate '/hospitals', true 
	
