/**
 * Class to test VisualforceEmailController
 * @author : SUY Sreymol
 * @createddate : 13-Jan-2014
 */
 @isTest(SeeAllData=true)
public class TestVisualforceEmailController {
	private static User u;
	private static Opportunity opp;
	private static OpportunityLineItem oli;
	
	/**
	 * Set up data for testing
	 */
	static void setupdData() {
		String proId = [Select Id From Profile Where Name = 'System Administrator' limit 1].Id;
		u = new User(alias = 'u2', email = 'VisualforceEmailController@test.com', emailencodingkey = 'UTF-8', 
                            FirstName = 'VisualforceEmailController' , lastname = 'User', languagelocalekey = 'en_US',
                            localesidkey = 'en_US', profileid = proId, timezonesidkey = 'America/Los_Angeles', CommunityNickname = 'VE',
                            isActive = true, username = 'VisualforceEmailController@test.com');
        insert u;
        
        Account acc = new Account(Name = 'Account EV');
        insert acc;
        
    	Contact con = new Contact(AccountId = acc.Id, LastName = 'Contact VE', Email = 'sendemail@developer.com');
        insert con;
        
        Pricebook2 pb2Standard = new Pricebook2();
        if(TestOpportunityTrigger.mapPriceBook == null){
        	TestOpportunityTrigger.mapPriceBook = new Map<String,Pricebook2>();
        	pb2Standard = [Select p.IsStandard, p.Id From Pricebook2 p where IsStandard = true];
        	TestOpportunityTrigger.mapPriceBook.put('PriceBookKey',pb2Standard);
        }else if(TestOpportunityTrigger.mapPriceBook.containsKey('PriceBookKey')){ 
        	pb2Standard = TestOpportunityTrigger.mapPriceBook.get('PriceBookKey');
        }
            
        //PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard = true limit 1];
        
        RecordType rt = [Select r.SobjectType, r.Name, r.Id, r.DeveloperName From RecordType r Where SobjectType = 'Product2' and DeveloperName = 'Subscription' limit 1];
        Product2 p2 = new Product2(Name = 'Test Product', isActive = true, Family = 'Subscriptions', RecordTypeId = rt.Id,Duration_Days__c=30);
		insert p2;
		
		PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb2Standard.Id, Product2Id = p2.Id, UnitPrice = 99, isActive = true);
		insert pbe;
        
        opp = new Opportunity(Business_Unit__c ='Renewal', Name = 'Opp EV', OwnerId = u.Id, Pricebook2Id = pb2Standard.Id, StageName = 'Inquiry', Expiration_Date__c = system.today().addDays(10), CloseDate = system.today(), AccountId = acc.Id);
        insert opp;
        
		Quote q = new Quote(Name = 'testQuote ', OpportunityId = opp.Id, ContactId = con.Id, Pricebook2Id = pb2Standard.id);
        insert q ;
        
        QuoteLineItem quoteLine = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pbe.Id ,UnitPrice = 100,Quantity = 1 ,ServiceDate = System.today());
        insert quoteLine;
        
        opp.SyncedQuoteId = q.Id;
        update opp;
        
        oli = new OpportunityLineItem(PriceBookEntryId = pbe.Id, OpportunityId = opp.Id, Quantity = 1, TotalPrice = 99, Contact__c = con.Id, Expiry_Date__c = system.today().addDays(10), ServiceDate = system.today(), Renewal_Rate__c = 10);
		insert oli;
		
	}
	
	/** 
	 * Test method
	 */ 
	
	static testmethod void testVisualforceEmailController() {
		
		setupdData();
        system.runAs(u) {
       		Test.startTest();
        		
        	
        		PageReference aPage = Page.VisualforceEmailPage;
        		aPage.getParameters().put('id', oli.Id);
        		// In case decline
        		aPage.getParameters().put('action', 'decline');
        		Test.setCurrentPage(aPage);
        		VisualforceEmailController controller = new VisualforceEmailController();
        		controller.updateOppAndCreateTask();
        		system.assertEquals(VisualforceEmailController.CLOSED_LOST_OPP, [select StageName From Opportunity Where Id = : opp.Id limit 1].StageName, 'If person clicks on decline, update Opportunity stage to Closed Lost.');
        		system.assertEquals(u.Id, [Select OwnerId From Task Where OwnerId =: opp.OwnerId].OwnerId, 'If person clicks on decline, create a task.');
        		// In case Accept
        		opp.StageName = 'Defaulted';
        		update opp;
        		aPage.getParameters().put('action', 'accept');
        		Test.setCurrentPage(aPage);
        		controller = new VisualforceEmailController();
        		controller.updateOppAndCreateTask();
        		system.assertEquals(VisualforceEmailController.CLOSED_WON_OPP, [select StageName From Opportunity Where Id = : opp.Id limit 1].StageName, 'If person clicks on decline, update Opportunity stage to Closed Won.');
        		system.assertEquals(1, [Select OwnerId From Task Where OwnerId =: opp.OwnerId].size(), 'If person clicks on accept, not create a task.');
        		// To test send email
        		VisualforceEmailController.sendMail(opp.Id);
        		//system.assertEquals(opp.Id,  [select WhatId from Task Where WhatId = : opp.Id].WhatId, 'After email have been send, create a task.');
        	Test.stopTest();
        }
	}
}