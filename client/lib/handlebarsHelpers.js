Handlebars.registerHelper('getActionName',function(obj){
  return obj['action'];
});

Handlebars.registerHelper('getActionText',function(obj){
  return obj['actionText'];
});

Handlebars.registerHelper('getTarget',function(obj){
  return obj['_id'];
});
