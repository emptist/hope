#-------------------- subscriptions --------------------------------
# the following doesn't work for unkown reason
#getHospital = -> Meteor.call "share.GetHospital"
#setHospital = (hospital)-> Meteor.call "share.SetHospital", hospital


getHospital = ->
	Session.get "hospital"

setHospital = (hospital)->
	Session.set "hospital", hospital

setTeam = (team)->
	Session.set "team", team

setEditting = (self) ->
	Session.set "editting #{self._id}", true # in fact it's @_id

setEdittingFalse = (t)->
	#Session.set "editting #{@._id}", false # <-- I haven't tried if this works
	Session.set "editting #{t.data._id}", false

#Meteor.subscribe "teamsChannel", getHospital()
Meteor.subscribe "teamsChannel"
Meteor.subscribe "bsckpisChannel"
Meteor.subscribe "tasksChannel"
Meteor.subscribe "hospitalsChannel"
#Meteor.subscribe "currentObjects"




#------------------------ helpers ------------------------------------
fourPerspectives = ['财务','客户','学习成长','内部流程']
logCreated = (self)-> #console.log "created:", self.data
logRendered = (self)->console.log "rendered:", self.data
logDestroyed = (self)->console.log "destroyed:", self.data

showAsEditMode = -> Session.get "showButtons"

logSet = (a, b) ->
	r = Session.set a, b
	share.consolelog "now #{a} is #{b}"
	r


isViewing = (viewName...)-> share.consolelog Session.get('currentView') in viewName
share.isViewing = isViewing


clientKPIObj = (e, t) ->
	getValue = (id) -> t.find(id).value.trim() #.replace(/^\s+|\s+$/g,'')
	indx:getValue "#title"
	perspective: getValue "#perspective"
	category: getValue "#category"
	title: getValue "#title"
	definition: getValue "#definition"
	type: getValue "#type" # the greater the better vs. the less the better vs. the closer the better
	mesure: getValue "#mesure" # how to score
	teams: getValue "#teams" # for which dept
	deptCategory: getValue "#deptCategory" # for which dept category
	remarker: getValue "#remarker"
	kpiSource: getValue "#kpiSource"
	weight: 0
	suitable: false


clientTeamObj = (o, e, t) ->
	getValue = (id) ->	t.find(id)?.value.trim() #replace(/^\s+|\s+$/g,'')
	hospital= getValue '#hospital'
	team = getValue '#team'
	#share.consolelog "in clientTeamObj t.perspectives() is now #{t.perspectives()}"

	obj = {
		indx: (hospital + "-" + team)
		hospital: getValue "#hospital"
		team: getValue "#team"
		department: getValue "#department"
		category: getValue "#category"
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
Template.main.helpers
	adminLoggedIn: -> share.adminLoggedIn()
	showButtons:  -> showAsEditMode()

Template.main.events
	'click a[href^= "/"]': (e,t) ->  # means (a.href)a[href] ="/"
		# Note: Backbone.history.navigate decodeURI e.currentTarget.pathname will not work!
		Backbone.history.navigate e.currentTarget.pathname, true
		e.preventDefault()
