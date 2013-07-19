Handlebars.registerHelper('getFirstKey',function(obj){
    return _.keys(obj)[0];
});

Handlebars.registerHelper('getActionText',function(obj){
    var key = _.keys(obj)[0];
    return obj[key]['text'];
});
