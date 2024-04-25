({
    init: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getOrderSummaries");
        var actioncall = component.get("c.returnAccountId");
        var title = "Customer Orders";
        var ordList = [];
        
        actioncall.setParams({
            "caseId": recordId
        });
      
        actioncall.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var acId = response.getReturnValue();
                component.set("v.accountId",acId);
            }
        });
        
        $A.enqueueAction(actioncall);
        
        action.setParams({
            "caseId": recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.Reclength",title);
            var ordListLength = response.getReturnValue().length;
            if (state === "SUCCESS") {
                
                if(ordListLength<= 3){
                    component.set("v.Reclength",title + ' ' + '(' + response.getReturnValue().length + ')');
                    component.set("v.orderSummaries",response.getReturnValue());
                }else{
                    component.set("v.Reclength",title + ' ' + '(' + '3+' + ')');
                    for(var i=0; i<3; i++){
                        ordList.push(response.getReturnValue()[i]);
                    }
                    component.set("v.orderSummaries",ordList);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    navigate : function(component, event, helper) { 
        var recordId = component.get("v.recordId");
        var action = compennt.get("c.returnAccountId");
        action.setParams({
            "caseId": recordId
        });
        
        var urlEvent = $A.get("e.force:navigateToURL"); 
        let urlTest = 'https://firemountaingems--rspilot.sandbox.lightning.force.com/lightning/r/Account/001DK00000yBWXpYAO/related/OrderSummaries/view?ws=%2Flightning%2Fr%2FCase%2F500DK000008HrO2YAK%2Fview';
        urlEvent.setParams({ "url": 'https://firemountaingems--rspilot.sandbox.lightning.force.com/lightning/r/Account/001DK00000yBWXpYAO/related/OrderSummaries/view?ws=%2Flightning%2Fr%2FCase%2F500DK000008HrO2YAK%2Fview' }); 
        urlEvent.fire(); 
    },
    navigateToRelatedList: function(component,event,helper){
        var completeRelatedList = $A.get("e.force:navigateToRelatedList");
        completeRelatedList.setParams({
            "relatedListId": "OrderSummaries",
            "parentRecordId": component.get("v.accountId")
        });
        completeRelatedList.fire();
    },
   recordUpdated : function(component, event, helper) {
       
       console.log("test");
        //$A.get('e.force:refreshView').fire();
       var action = component.get('c.init');
        $A.enqueueAction(action);
       $A.get('e.force:refreshView').fire(); 

       console.log("final");
    }

})