#-------------------- subscriptions --------------------------------
Meteor.subscribe "bsckpisChannel"
Meteor.subscribe "teamsChannel"
Meteor.subscribe "hospitalsChannel"
Meteor.subscribe "currentObjects"




#------------------------ helpers ------------------------------------
fourPerspectives = ['财务','客户','学习成长','内部流程'] 

showAsEditMode = -> Session.get "showButtons"

logSet = (a, b) ->
	r = Session.set a, b
	share.consolelog "now #{a} is #{b}"
	r


isViewing = (viewName...)-> share.consolelog Session.get('currentView') in viewName


clientKPIObj = (e, t) ->
	getValue = (id) -> t.find(id).value
	indx:getValue "#title"
	perspective: getValue "#perspective"
	category: getValue "#category"
	title: getValue "#title"
	definition: getValue "#definition"
	type: getValue "#type" # the greater the better vs. the less the better vs. the closer the better
	mesure: getValue "#mesure" # how to score
	teams: getValue "#teams" # for which dept
	weight: 0


clientTeamObj = (o, e, t) ->
	getValue = (id) ->	t.find(id)?.value
	hospital= getValue 'input#hospital'
	team = getValue 'input#team'
	#share.consolelog "in clientTeamObj t.perspectives() is now #{t.perspectives()}"

	obj = { 
		indx: (hospital + "-" + team) 
		hospital: getValue "input#hospital"
		team: getValue "input#team" 
		category: getValue "input#category"
	}
	obj.perspectives = ( 
		# too complicated
		# to read back:
		#	for perspective in obj.BSCard
		#		perspective.perpective
		#		perspective.weight
		#		perspective.kpis
		#
		for perspective in fourPerspectives
			data = Session.get perspective
			p= {}
			p.perspective = data.perspective
			p.weight= getValue "input#weight#{perspective}"
			p.kpis= (
				for kpi in data.kpis when getValue("input#weight#{kpi.title}") > 0
					kpi.weight= getValue "input#weight#{kpi.title}"
					kpi 
				)
			p 
		)
	###	
		for perspective in fourPerspectives
			p = { 
				perspective: perspective
				kpis: share.KPIs.find(perspective: perspective).fetch()
			}
			Session.set perspective, p  # there must be more effecient way to get these
			p

		weightFinance: getValue "input#weight财务"
		weightClient: getValue "input#weight客户"
		weightIntern: getValue "input#weight内部流程"
		weightStudy: getValue "input#weight学习成长"
		financeKPIs: Session.get "financeKPIs" ? []
		clientKPIs: Session.get "clientKPIs" ? []
		internKPIs: Session.get "internKPIs" ? []
		studyKPIs: Session.get "studyKPIs" ? []
	###
	share.consolelog obj

viewDetail = (viewName, t)-> 
	Backbone.history.navigate '/' + viewName + '&' +  t.find('#' + viewName).value, true #decodeURI 

# the following doesn't work for unkown reason
#getHospital = -> Meteor.call "share.GetHospital"
#setHospital = (hospital)-> Meteor.call "share.SetHospital", hospital


getHospital = -> Session.get "hospital"
setHospital = (hospital)-> Session.set "hospital", hospital

#------------------------ router ------------------------------------
logSetCurrentView = (currentView)->
	logSet "currentView", currentView


HOPERouter = Backbone.Router.extend
	routes: # ! this order matters ! stupid!!
		"": "main"
		"bsckpis": "bsckpis"
		"teams": "teams"
		"newKpiForm": "newKpiForm"
		"newTeamForm": "newTeamForm"
		#"hospitals": "hospitals" 
		":detail": "detail" # 查看single object, see below
		
	main: -> logSetCurrentView "main"
	bsckpis: ->	logSetCurrentView "bsckpis"	
	teams: -> logSetCurrentView "teams"
	newKpiForm: -> logSetCurrentView "newKpiForm"
	newTeamForm: -> logSetCurrentView "newTeamForm"
	#hospitals: -> logSetCurrentView "hospitals"
	detail: (detail) -> # detail is string formatted like 'view-detail'
		sp = detail.split '&'
		logSetCurrentView decodeURI sp[0] # this could be everything that contains details
		logSet "currentDetail",  decodeURI sp[1] # this leading to one detail of the viewed objected




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
	'click #teams': -> Backbone.history.navigate '/teams', true
	'click #newKpiForm': ->	Backbone.history.navigate '/newKpiForm', true
	'click #newTeamForm': -> Backbone.history.navigate '/newTeamForm', true
	'click #printable': -> Session.set "showButtons", not showAsEditMode()
	#'click #hospitals': -> Backbone.history.navigate '/hospitals', true 
	



#------------------------- bsckpis ---------------------------------------
Template.bsckpis.show = ->
	isViewing "bsckpis","perspective" ,"newKpiForm"

Template.bsckpis.showButtons = ->
	showAsEditMode()

Template.bsckpis.kpis = ->
	if isViewing "perspective"
		share.KPIs.find perspective: Session.get "currentDetail" 
	else
		share.consolelog share.KPIs.find {}, sort:{perspective: -1, category: -1, title: -1}

#------------------------- newKpiForm ----------------------------------
Template.newKpiForm.show = -> isViewing "newKpiForm","perspective" 


Template.newKpiForm.events
	'click #save': (e,t) -> 
		Meteor.call "kpi", #perspective, category, title, definition, type, mesure, teams
			clientKPIObj e,t
			(err, id)->
				viewDetail "perspective",t



#------------------------- kpi -------------------------------------------
Template.kpi.editting = ->
	Session.get "editting #{@._id}"

Template.kpi.showButtons =->
	showAsEditMode()


#------------------------- editKpiForm -----------------------------------
Template.editKpiForm.show = ->
	true #since this should display in place so don't use isViewing "editKpiForm"

Template.editKpiForm.events
	'click #save': (e,t) -> 
		Meteor.call "kpi", #perspective, category, title, definition, type, mesure, teams
			clientKPIObj e,t
			(err, id) ->
				share.consolelog "editKpiForm event save #{t.data._id}" # is known that share.._id here is undefined 
				Session.set "editting #{t.data._id}", false
		


#------------------------- viewKpiForm ----------------------------------
Template.viewKpiForm.showButtons = ->
	isViewing("bsckpis", "perspective") and showAsEditMode()

Template.viewKpiForm.events
	
	'click #editKpiForm':(e,t) ->
		share.consolelog "viewKpiForm event editKpiForm #{@._id}"
		Session.set "editting #{@._id}", true #"editting #{t.data._id}", true
	
	'click #removeKPI':	(e,t) ->
		share.consolelog "viewKpiForm event removeKPI #{@._id}"
		Meteor.call "removeKPI", @._id


	


#------------------------- teams ----------------------------------- 
Template.teams.show = ->
	isViewing "teams", "team", "category"  
	
Template.teams.showButtons = -> # 打印模式不显示按钮
	showAsEditMode()


Template.teams.teams = ->  # class 三级分级 type 公立等 title 医院名
	if isViewing "teams" 
		share.consolelog share.Teams.find hospital: getHospital() #, 
			#sort: { category: -1, team: -1}
	else if isViewing "category"
		share.Teams.find {hospital: getHospital(), category: Session.get 'currentDetail'}
	else if isViewing("team") 
		share.Teams.find indx: "#{getHospital()}-#{Session.get 'currentDetail'}"


Template.teams.hospital = ->
	getHospital()

Template.teams.events
	'keypress input#hospital': (e,t)->
		if e.keyCode is 13
			share.consolelog setHospital e.target.value





#------------------------- newTeamForm -----------------------------
Template.newTeamForm.show = ->
	isViewing "newTeamForm" #,"teams" 

Template.newTeamForm.hospital = ->
	Session.get "hospital"

Template.newTeamForm.perspectives = -> 
	for perspective in fourPerspectives
		p = { 
			perspective: perspective
			kpis: share.KPIs.find(perspective: perspective).fetch()
		}
		Session.set perspective, p  # there must be more effecient way to get these
		p

Template.newTeamForm.events
	'keypress input#hospital': (e,t)->
		if e.keyCode is 13
			share.consolelog setHospital e.target.value

	'click #save': (e,t) -> 
		share.consolelog t.find( "input#team").value
		Meteor.call "team", 
			share.consolelog clientTeamObj this, e, t
			(err, id)->
				#Session.set "currentView", "hospital"
				share.consolelog viewDetail "team", t

	'keypress input#hospital': (e,t)->
		if e.keyCode is 13
			share.consolelog setHospital e.target.value




#-------------------------- editTeamForm -----------------------------
Template.editTeamForm.show = ->
	isViewing "teams","team",

Template.editTeamForm.moreperspectives = ->
	#@.perspectives
	getPerspective = (perspective, perspectives)->
		(p for p in perspectives when p.perspective is perspective)[0] 

	#getPWeight = (perspective, perspectives)->
	#	getPerpective(perspective, perspectives).weight

	getKPIWeight = (kpi, thiskpis) ->
		(k.weight for k in thiskpis when k.title is kpi.title)[0] ? 0

	for perspective in fourPerspectives
		thisPps = getPerspective(perspective, @.perspectives)
		thisKpis = thisPps.kpis
		p = { 
			perspective: perspective
			weight: thisPps.weight
			kpis: share.KPIs.find(perspective: perspective).fetch()
		}

		for kpi in p.kpis 
			kpi.weight = getKPIWeight(kpi, thisKpis) #find out the specific perspective weight

		Session.set perspective, p  # there must be more effecient way to get these
		p
	

Template.editTeamForm.events
	'keypress input#hospital': (e,t)->
		if e.keyCode is 13
			share.consolelog setHospital e.target.value
	
	'click #save': (e,t) -> 
		Meteor.call "team", 
			clientTeamObj this, e, t
			(err, id) ->
				share.consolelog "editTeamForm event save #{t.data._id}" # is known that share.._id here is undefined 
				Session.set "editting #{t.data._id}", false
###				Session.set "editTeamKPIForm #{t.data._id}", false
				
	
	'click #editTeamKPIForm': (e,t) ->
		Session.set "editTeamKPIForm #{t.data._id}", true	
###






#------------------------- team ------------------------------------
Template.team.editting = ->
	share.consolelog Session.get "editting #{@._id}" #these should be combined to one

Template.team.show = ->
	true




#--------------------------- viewTeamForm -------------------------------
Template.viewTeamForm.showButtons = ->
	showAsEditMode()

Template.viewTeamForm.showKpiForm = ->
	showAsEditMode()

#Template.viewTeamForm.perspectives = ->
#	this.bscs.perspectives 

Template.viewTeamForm.events
	'click #editTeamForm':(e,t) ->
		share.consolelog "viewTeamForm event editTeamForm #{@._id}"
		Session.set "editting #{@._id}", true #"editting #{t.data._id}", true
	
	'click #removeTeam':	(e,t) ->
		share.consolelog "viewTeamForm event removeTeam #{@._id}"
		Meteor.call "removeTeam", @._id

	#'click .kpi': Session.set "isViewing #{@._id}"




###------------------------- editTeamKPIForm ---------------------------------
Template.editTeamKPIForm.show = ->
	Session.get "editTeamKPIForm #{@._id}"

Template.editTeamKPIForm.events
	'keypress input#weightFinance': (e,t)->
			if e.keyCode is 13
				this.weightFinance = e.target.value
	'keypress input#weightClient': (e,t)->
			if e.keyCode is 13
				this.weightClient = e.target.value
	'keypress input#weightIntern': (e,t)->
			if e.keyCode is 13
				this.weightIntern = e.target.value
	'keypress input#weightStudy': (e,t)->
			if e.keyCode is 13
				share.consolelog this.weightStudy = e.target.value
###