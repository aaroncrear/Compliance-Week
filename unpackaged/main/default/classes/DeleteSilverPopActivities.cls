global class DeleteSilverPopActivities implements Database.Batchable<sObject>, Database.Stateful {
    global Integer emailLinksDeleted = 0;
	global Integer activitiesDeleted = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID ' + ' from Account'
          //  '(SELECT ID, silverpop__Last_Clicked__c from silverpop__Email_Links__r)' +
           // 'FROM silverpop__Silverpop_Email_Activity__c '
        );
    }
    
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
     /*   List<silverpop__Silverpop_Email_Activity__c> activitiesToDelete = new List<silverpop__Silverpop_Email_Activity__c>();
        List<silverpop__Email_Link__c> emailLinksToDelete = new List<silverpop__Email_Link__c>();
        System.debug('scope.size = ' + scope.size());
        for(silverpop__Silverpop_Email_Activity__c sea: scope) {
            boolean yesDeleteEL = false;
            boolean noDeleteEL = false;
            if(sea.silverpop__Email_Links__r == null || sea.silverpop__Email_Links__r.size() < 1) {
                system.debug('No Email Links Found');
                activitiesToDelete.add(sea);
            }
            for(silverpop__Email_Link__c el: sea.silverpop__Email_Links__r) {
                System.debug('el ID = ' + el.id);
                if(el.silverpop__Last_Clicked__c == null) {
                    emailLinksToDelete.add(el);
                    yesDeleteEL = true;
                } else {
                   noDeleteEL = true; 
                }
            }
            System.debug('noDeleteEL = ' + noDeleteEL);
            System.debug('yesDeleteEL = ' + yesDeleteEL);
            if(!noDeleteEL && yesDeleteEL) {
                System.debug('adding SEA to delete ID = ' + sea.Id);
                activitiesToDelete.add(sea);
            } 
        }
        if(emailLinksToDelete.size() > 0) {
            System.debug('emailLinksToDelete.size = ' + emailLinksToDelete.size());
            emailLinksDeleted = emailLinksToDelete.size();
            delete emailLinksToDelete;
        }
        if(activitiesToDelete.size() > 0) {
            System.debug('activitiesToDelete.size = ' + activitiesToDelete.size());
            activitiesDeleted = activitiesToDelete.size();
            delete activitiesToDelete;
        }*/
        
    }
        
    global void finish(Database.BatchableContext bc){
   /*     System.debug(emailLinksDeleted + ' Email Links Deleted');
        System.debug(activitiesDeleted + ' Activites Deleted');
       // Get the ID of the AsyncApexJob representing this batch job
       // from Database.BatchableContext.
       // Query the AsyncApexJob object to retrieve the current job's information.
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email
          FROM AsyncApexJob WHERE Id =
          :BC.getJobId()];
       // Send an email to the Apex job's submitter notifying of job completion.
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'acrear@hat-trickconsulting.com','nathan@hat-trickconsulting.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Apex Sharing Recalculation ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures. ' + emailLinksDeleted + ' Email Links Deleted. ' + activitiesDeleted + ' Activites Links Deleted. ');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });              
        
        */
    } 
}