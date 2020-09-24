@isTest
private class PrintRunMemberTest {
	
	private static Publication__c p;
	private static Publication_Issue__c pi;
	private static Print_Run__c pr;
	  
	private static Contact[] lstContactA; // Contacts that Expiration_Date__c >= Publication_Date__c
	private static Contact[] lstContactB; // Contacts that Expiration_Date__c <  Publication_Date__c
	private static Contact[] lstContactAll; 
	private static Print_Run_Member__c[] lstPRM;
	
	private static void setupData(){
		p = new Publication__c(Name='test');
		insert p;
		pi = new Publication_Issue__c(Name = 'test', Publication_Date__c = System.today(), Publication__c = p.Id);
		insert pi;
		pr = new Print_Run__c(//Name = 'test', 
							  Publication_Issue__c = pi.Id, 
							  Type__c = PrintRunMember.PR_TYPE_DOMESTIC, 
							  Print_Run_Date__c = System.today());
		
		lstContactA = new List<Contact>(); 
		lstContactB = new List<Contact>();
		lstContactAll = new List<Contact>();
		 
		for(Integer i=0; i<200; i++){
			Contact a = new Contact(Send_Print_Magazine__c = true, LastName = 'test', Expiration_Date__c = System.today(), MailingCountryCode = PrintRunMember.COUNTRY_CODE_US);
			lstContactA.add(a);
			Contact b = new Contact(Send_Print_Magazine__c = true, LastName = 'test', Expiration_Date__c = System.today().addDays(-1), MailingCountryCode = PrintRunMember.COUNTRY_CODE_US);
			lstContactB.add(b);
		} 
		lstContactAll.addAll(lstContactA);
		lstContactAll.addAll(lstContactB);
		insert lstContactAll;
		 
	} 
	
	/* Test inserting Print_Run__c */
    static testMethod void testOnPrintRun() { 
        setupData();
        Test.startTest(); 
        insert pr;
        Test.stopTest();
        
        lstPRM = [Select Member__c From Print_Run_Member__c Where Print_Run__c = :pr.Id];
        // When inserting Print_Run__c, Print_Run_Member__c will be created (Contacts that Expiration_Date__c >= Publication_Date__c)
        System.assertEquals(lstPRM.size(), lstContactA.size());
       	
       	Map<String, Print_Run_Member__c> mapContactIdPRM = new Map<String, Print_Run_Member__c>();
       	for(Print_Run_Member__c prm : lstPRM){
       		mapContactIdPRM.put(prm.Member__c, prm);
       	} 
        
        for(Contact c : lstContactA){
        	// The created Print_Run_Member__c are the conjection between Print_Run__c and Contact
        	System.assert(mapContactIdPRM.get(c.Id) != null); 
        }
    }
    
    /* Test updating Publication_Issue__c */
    static testMethod void testOnPublicationIssue() {
        setupData();
        insert pr;
        
        Test.startTest(); 
        pi.Publication_Date__c = System.today().addDays(+1);
        Update pi;
        lstPRM = [Select Member__c From Print_Run_Member__c Where Print_Run__c = :pr.Id];
        // Print_Run_Member__c are deleted because no Contacts that Expiration_Date__c >= Publication_Date__c
        System.assertEquals(lstPRM.size(), 0);
        
        pi.Publication_Date__c = System.today().addDays(-1);
        Update pi;
        lstPRM = [Select Member__c From Print_Run_Member__c Where Print_Run__c = :pr.Id];
        // Print_Run_Member__c are created with all Contacts that Expiration_Date__c >= Publication_Date__c
        System.assertEquals(lstPRM.size(), lstContactAll.size());
        
        Map<String, Print_Run_Member__c> mapContactIdPRM = new Map<String, Print_Run_Member__c>();
       	for(Print_Run_Member__c prm : lstPRM){
       		mapContactIdPRM.put(prm.Member__c, prm);
       	} 
        for(Contact c : lstContactAll){
        	// The created Print_Run_Member__c are the conjection between Print_Run__c and Contact
        	System.assert(mapContactIdPRM.get(c.Id) != null); 
        }
        Test.stopTest(); 
    }
    
    /* Test inserting and updating Contact */
    static testMethod void testOnContact() {
        setupData();
        insert pr;
        
        Contact con = new Contact(Send_Print_Magazine__c = true, LastName = 'test', Expiration_Date__c = System.today(), MailingCountryCode = PrintRunMember.COUNTRY_CODE_US);
        
        Test.startTest(); 
        insert con; 
        lstPRM = [Select Print_Run__c From Print_Run_Member__c Where Member__c = :con.Id];
        // A Print_Run_Member__c is created for the Contat and Print_Run__c
        System.assertEquals(lstPRM.size(), 1);
        System.assertEquals(lstPRM[0].Print_Run__c, pr.Id);
        
		con.Expiration_Date__c = null;
		update con;
        lstPRM = [Select Print_Run__c From Print_Run_Member__c Where Member__c = :con.Id];
        // Print_Run_Member__c is deleted
        System.assertEquals(lstPRM.size(), 0); 
        Test.stopTest(); 
    }
    
    /* Test new requirements (Print Run Type and Address):
     *   - If the Print Run Type = Domestic, only United States Contacts should be added as Print Run Members.
     *   - If Print Run Type = International, all others should be added, excluding COUNTRY_CODE_US
     *   - If no address exists, the contact can't be added.
     */
    static testMethod void testNewRequirements_TypeAndAdress() {
        setupData();
        pr.Type__c = PrintRunMember.PR_TYPE_DOMESTIC;
        insert pr;
        
        Contact con1 = new Contact(Send_Print_Magazine__c = true, LastName = 'a', Expiration_Date__c = System.today(), MailingCountryCode = PrintRunMember.COUNTRY_CODE_US);
        Contact con2 = new Contact(Send_Print_Magazine__c = true, LastName = 'b', Expiration_Date__c = System.today(), MailingCountryCode = 'GB');
        
        Test.startTest(); 
        insert (new List<Contact>{con1, con2}); 
        lstPRM = [Select Member__c From Print_Run_Member__c Where Member__c = :con1.Id Or Member__c = :con2.Id];
        // Print Run Type = Domestic, only United States Contacts should be added as Print Run Members
        System.assertEquals(lstPRM.size(), 1);
        System.assertEquals(lstPRM[0].Member__c, con1.Id);
        
        
		pr.Type__c = PrintRunMember.PR_TYPE_INTERNATIONAL;
		update pr;
        lstPRM = [Select Member__c From Print_Run_Member__c Where Member__c = :con1.Id Or Member__c = :con2.Id];
        // Print Run Type = International, all others should be added, excluding COUNTRY_CODE_US
        System.assertEquals(lstPRM.size(), 1);
        System.assertEquals(lstPRM[0].Member__c, con2.Id);
        
        con1.MailingCountryCode = null;
        con2.MailingCountryCode = null;
        update (new List<Contact>{con1, con2}); 
        lstPRM = [Select Member__c From Print_Run_Member__c Where Member__c = :con1.Id Or Member__c = :con2.Id];
        // If no address exists, the contact can't be added.
        System.assertEquals(lstPRM.size(), 0);
        
        Test.stopTest(); 
    }
    
    /* Test new requirements (Print Run Date):
     *   When a Print Run Date has passed:
	 *  	- members should not be added or removed. 
	 *		- even if the contact, publication issue, or print run is edited, do nothing on members
     */
    static testMethod void testNewRequirements_PrintRunDate() {
    	setupData();
        insert pr;
        lstPRM = [Select Member__c From Print_Run_Member__c Where Print_Run__c = :pr.Id]; 
        System.assertEquals(lstPRM.size(), lstContactA.size());
        
        //modify the Print Run to passed date.
        pr.Print_Run_Date__c = System.today().addDays(-1);
        update pr;
        
        Test.startTest();
        // Condition: Contact Expiration Date >= Publication Date
        // Now set to unmatch this condition (the logic will remove all members, but Print Run Date has passed, so the members will be not removed)
        pi.Publication_Date__c = lstContactA[0].Expiration_Date__c.addDays(1);
        update pi;
        lstPRM = [Select Member__c From Print_Run_Member__c Where Print_Run__c = :pr.Id]; 
        // Members are still remaining.
        System.assertEquals(lstPRM.size(), lstContactA.size());
        
        Test.stopTest(); 
    }
    
     /* Test new requirements (Send_Print_Magazine__c):
     *   - Create Print_Run_Member__c if Send_Print_Magazine__c = true. 
     */
    static testMethod void testNewRequirements_Send_Print_Magazine() {
        setupData();  
        insert pr;
        
        Contact con1 = new Contact(Send_Print_Magazine__c = true, LastName = 'a', Expiration_Date__c = System.today(), MailingCountryCode = PrintRunMember.COUNTRY_CODE_US);
        Contact con2 = new Contact(Send_Print_Magazine__c = false, LastName = 'b', Expiration_Date__c = System.today(), MailingCountryCode = PrintRunMember.COUNTRY_CODE_US);
        
        Test.startTest(); 
        insert (new List<Contact>{con1, con2}); 
        // Create Print_Run_Member__c for con1 only
        lstPRM = [Select Member__c From Print_Run_Member__c Where Member__c = :con1.Id Or Member__c = :con2.Id];
        System.assertEquals(lstPRM.size(), 1);
        System.assertEquals(lstPRM[0].Member__c, con1.Id);
        
        con1.Send_Print_Magazine__c = false;
        con2.Send_Print_Magazine__c = true;
        update (new List<Contact>{con1, con2});
        // Print_Run_Member__c for con1 will be delete, and con2 will be created
        lstPRM = [Select Member__c From Print_Run_Member__c Where Member__c = :con1.Id Or Member__c = :con2.Id];
        System.assertEquals(lstPRM.size(), 1);
        System.assertEquals(lstPRM[0].Member__c, con2.Id);
        
        Test.stopTest();
    }
}