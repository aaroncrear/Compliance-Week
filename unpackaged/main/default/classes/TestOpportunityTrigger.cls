/**
 * Class to test trigger on opporunity to create Subscription_NEW__c for each product when an Opportunity is Closed Won and record type = 'Subscription'
 * Create date 31/12/2013
 */
@isTest(SeeAllData=true)
public class TestOpportunityTrigger {
    private static final String TYPE_SINGLE = 'Single';
    private static final String TYPE_MULTI = 'Multi';
    private static final String STAGE_CLOSEWON = 'Closed Won';
    private static final String FAMILY_SUBSCRIPTION = 'Subscriptions';
    private static final String RECORDTYPE_SUBSCRIPTION = 'Subscriptions_Opportunity';
    private static final String BUSINESSUNIT           = 'Compliance Week';
    private static final String STAGE_CLOSELOST        = 'Closed Lost';
    private static final String LOST_REASON            = 'Renewal Opportunity Expired';
    private static final String BUSINESSTYPE_RENEWAL   = 'Renewal';
    public static Map<String, Pricebook2> mapPriceBook ;
    static testMethod void myUnitTest() {
        Test.startTest();
            Account accRecord = new Account(Name = 'testAccount');
            insert accRecord;
            Product2 prod = new Product2(Name = 'testProduct', Min_Users__c = 1, Max_Users__c =1, Family = FAMILY_SUBSCRIPTION,Duration_Days__c = 90, IsActive = true);
            insert prod;
            Pricebook2 pb = new Pricebook2();
            if(mapPriceBook == null){
                mapPriceBook = new Map<String,Pricebook2>();
                pb = [Select p.IsStandard, p.Id From Pricebook2 p where IsStandard = true];
                mapPriceBook.put('PriceBookKey',pb);
            }else if(mapPriceBook.containsKey('PriceBookKey')){
                pb = mapPriceBook.get('PriceBookKey');
            }
            //Pricebook2 pb = [Select p.IsStandard, p.Id From Pricebook2 p where IsStandard = true];
            PricebookEntry pbe = new PricebookEntry(UnitPrice = 100,Pricebook2Id=pb.Id, Product2Id = prod.ID, IsActive = true);
            insert pbe;
            
            Contact con = new Contact(LastName = 'test', AccountId = accRecord.Id);
            insert con;
            
            RecordType reType = [select id from RecordType where DeveloperName =: RECORDTYPE_SUBSCRIPTION ];
            Opportunity opp = new Opportunity(Name = 'test Renewal 2013 Renewal', 
                                            StageName = 'Inquiry', 
                                            Probability = 100,
                                            RecordTypeId = reType.Id, 
                                            Origination__c = 'test',
                                            Lost_Reason__c = 'test',
                                            Duration__c = 'test',
                                            CloseDate = System.today()+7,
                                            Amount = 100,
                                            AccountId = accRecord.Id,
                                            Pricebook2Id = pb.Id,
                                            Business_Unit__c = 'test');
            insert opp;
            OpportunityLineItem oppLine = new OpportunityLineItem(UnitPrice = 100, Quantity = 1, PricebookEntryId = pbe.Id, OpportunityId = opp.Id, Contact__c = con.Id, ServiceDate=System.today());
            insert oppLine;
            Quote q = new Quote(Name = 'testQuote1', OpportunityId = opp.Id, ContactId = con.Id, Pricebook2Id = pb.id);
            insert q ;
            QuoteLineItem quoteLine = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pbe.Id ,UnitPrice = 100,Quantity = 1 ,ServiceDate = System.today());
            insert quoteLine;
            //sync quote
            opp.SyncedQuoteId = q.Id;
            update opp;
            //set contact to oppline
            OpportunityLineItem oppLineSelect = [select Subscription__c, Expiry_Date__c , OpportunityId, Contact__c, ServiceDate from OpportunityLineItem where OpportunityId =: opp.Id limit 1];
            oppLineSelect.Contact__c = con.Id;
            oppLineSelect.Renewal_Rate__c = 100;
        	oppLineSelect.Expiry_Date__c = system.today() +100;
            update oppLineSelect;
            //udpate opportunity to close won
            opp.Business_Unit__c = BUSINESSUNIT;
            opp.StageName = STAGE_CLOSEWON;
            update opp;
        //assert for each opportunity product with subscription that just create
        Set<String> sSubId = new Set<String>();
        for(OpportunityLineItem oppLines : [select id,Expiry_Date__c,UnitPrice,Renewal_Rate__c, Contact__c,ServiceDate, Subscription__r.Start_Date__c, 
                        Subscription__r.Expiration_Date__c, Subscription__r.Contact__c, Subscription__r.Amount__c, Subscription__r.Renewal_Rate__c, Subscription__c
                        from OpportunityLineItem where OpportunityId =: opp.Id]){
            // System.assertEquals(System.today()+90, oppLines.Subscription__r.Expiration_Date__c);
           // System.assertEquals(oppLines.Contact__c, oppLines.Subscription__r.Contact__c);
            //System.assertEquals(oppLines.ServiceDate, oppLines.Subscription__r.Start_Date__c);
            //System.assertEquals(oppLines.UnitPrice, oppLines.Subscription__r.Amount__c);
           // System.assertEquals(oppLines.Renewal_Rate__c, oppLines.Subscription__r.Renewal_Rate__c);
            sSubId.add(oppLines.Subscription__c);
        }
        //generate renwal opp
      /*  BatchCloneOpportunity.cloneOpportunity(opp.Id);
        BatchCloneOpportunity.isBatchInProcess('BatchCloneOpportunity');
        test.stopTest();
        
        //select subscription after clone
        Subscription_NEW__c sub = [Select s.Renewal_Opportunity__c, s.Recaptured__c, Recapture_Opportunity__c,Renewal_Rate__c,Type__c ,Minimum_Users__c  From Subscription_NEW__c s where id IN: sSubId];
        // when renewal opp is close won
        Opportunity renewalOpp = [select id,StageName, Amount,CloseDate,Lost_Reason__c from Opportunity where id =: sub.Renewal_Opportunity__c];
        renewalOpp.StageName = STAGE_CLOSEWON;
        update renewalOpp;
        sub.Minimum_Users__c = 5;
        update sub;
        renewalOpp.StageName = STAGE_CLOSEWON;
        update renewalOpp;
        sub.Minimum_Users__c = 0;
        update sub;
        renewalOpp.StageName = STAGE_CLOSEWON;
        update renewalOpp;
        //when renewal opp is close lose => create recapture opp
        renewalOpp.StageName = STAGE_CLOSELOST;
        renewalOpp.Lost_Reason__c = LOST_REASON;
        update renewalOpp;
        //assert recapture opp name
        Subscription_NEW__c sub1 = [Select s.Renewal_Opportunity__c, s.Recaptured__c, Recapture_Opportunity__c,Renewal_Rate__c,Type__c ,Minimum_Users__c,Name  From Subscription_NEW__c s where id IN: sSubId];
        Opportunity recaptureOpp = [select id,StageName,Name from Opportunity where id =: sub1.Recapture_Opportunity__c];
        System.assertEquals('testAccount - '+sub1.Name+' - Recapture',recaptureOpp.Name);
        //when recapture opp is close won
        recaptureOpp.StageName = STAGE_CLOSEWON;
        update recaptureOpp;
        sub.Minimum_Users__c = 5;
        update sub;
        recaptureOpp.StageName = STAGE_CLOSEWON;
        update recaptureOpp;
        sub.Minimum_Users__c = 1;
        update sub;
        recaptureOpp.StageName = STAGE_CLOSEWON;
        update recaptureOpp;
        */
    } 
}