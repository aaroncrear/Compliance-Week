/**
* Class Test unit for AddProductsController
* @created date: 15-Jan-2014
* @author: Sopha Pum
*/
@isTest(seeAllData=true)
private class TestAddProductController {
	
	private static Opportunity opp;
	
	private static void initData(){
		
			Account account = new Account(Name='TestAccount', Phone='1234');
			insert account;

			Product2 pro = new Product2(IsActive=true, Name = 'Test Product', Family='Test Family');
			insert pro;
			
			Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true limit 1];
			Pricebook2 pb = [select id from Pricebook2 where Name='Standard Price Book'];
			
    		PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pro.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        	insert standardPrice;
        
        	//PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = pro.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
    		//insert pbe;
    	
            List<RecordType>  recordTypes = [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where SobjectType = 'Opportunity' and DeveloperName = 'Subscriptions_Opportunity'];
            
			Opportunity o = new Opportunity();
			o.Name='test';
			o.StageName = 'Open';
			o.Amount = 1234.5;
			o.CloseDate = System.today();
			o.AccountId=account.Id;
			o.RecordTypeId = recordTypes[0].Id;
			o.Pricebook2Id = pb.Id;
			insert o;
			
			opp = o;
			
	}
	
	private static testMethod void initTestRedirectPage(){
		
		Test.startTest();
			initData();
			
			//Redirect Page
			Apexpages.currentPage().getParameters().put('addTo', opp.Id);
			Apexpages.Standardcontroller stdctrl = new Apexpages.Standardcontroller(opp);
			RedirectCreateEditAllOpliController redirectCtrl = new RedirectCreateEditAllOpliController(stdctrl);
			
			Pagereference pageRediect = redirectCtrl.doRedirect();
			System.assertEquals('/apex/AddProducts?isnew=true&oppid=' + String.valueOf(opp.Id).substring(0,15), pageRediect.getUrl());
		Test.stopTest();
	}
	
	private static testMethod void initTestAddProductPage(){
		
		Test.startTest();
			initData();
			
			Apexpages.currentPage().getParameters().put('isnew', 'true');
			Apexpages.currentPage().getParameters().put('oppId', opp.Id);
			
			AddProductsController ctrl = new AddProductsController();
			//Test Search
				// Search Error
				ctrl.keyBusinessUnit = '';
				ctrl.doSearch();
				System.assert(ctrl.lstProResults == null, 'No key word to search.');
				
				ctrl.keyProductName = 'xxxxxxxxxxxxxx';
				ctrl.doSearch();
				System.assert(ctrl.isEmptyPro, 'No product found');
				
				//Search Completed
				ctrl.keyProductName = 'Test Product';
				ctrl.keyProductFamily = 'Test Family';
				ctrl.doSearch();
				System.assertEquals(1, ctrl.lstProResults.size(), 'a Product found.');
				
				
			//Test Add Product
				ctrl.position = 0;
				ctrl.addProduct();
				
				ctrl.position = 0;
				ctrl.removeProduct();
				
				ctrl.position = 0;
				ctrl.addProduct();
				
				ctrl.goNext();
				ctrl.goPrevious();
				
				//Test Save Error
				ctrl.lstOppPros.get(0).oppPro.Quantity = 0;
				ctrl.lstOppPros.get(0).oppPro.UnitPrice = 0;
				ctrl.doSave();
				
				ctrl.lstOppPros.get(0).oppPro.Quantity = 1;
				ctrl.lstOppPros.get(0).oppPro.UnitPrice = 10;
				ctrl.doSave();
				
				List<OpportunityLineItem> lstOpli = [Select Id, UnitPrice From OpportunityLineItem Where OpportunityId =: opp.Id];
				System.assertEquals(1, lstOpli.size(), 'an Opportunity Product is created');
				System.assertEquals(lstOpli.get(0).UnitPrice, 10);
				
			//Test Edit
				Apexpages.currentPage().getParameters().put('isnew', 'false');
				Apexpages.currentPage().getParameters().put('oppId', opp.Id);
				
				ctrl = new AddProductsController();
				ctrl.doSave();
				
				List<SelectOption> proFam = ctrl.productFamily;
				List<SelectOption> ProBus = ctrl.productBusinessUnit;
		Test.stopTest();
	}
}