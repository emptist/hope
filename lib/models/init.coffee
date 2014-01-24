share.KPIs = new Meteor.Collection "bsckpis" # expose this for debugging
share.Hospitals = new Meteor.Collection "hospitals"
share.Teams= new Meteor.Collection "teams"
#share.CurrentObjects = new Meteor.Collection "currentObjects"
share.Tasks = new Meteor.Collection "tasks"

@Teams = share.Teams  # for browser console watching

