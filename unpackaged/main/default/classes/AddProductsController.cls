/**
* Class custom add product
* @created date: 10-Jan-2014
* @author Sopha Pum
*/
public class AddProductsController {
	public String keyProductName 	{get;set;}
	public String keyProductFamily 	{get;set;}
	public String keyBusinessUnit	{get;set;}
	public Boolean isSearched 		{get;set;}
	public Boolean isAddPro 		{get;set;}
	public Integer position			{get;set;}
	public List<ProductResult> lstProResults {get;set;}
	public List<OppProduct> lstMainOppPros {get;set;}
	public List<OppProduct> lstOppPros {get;set;}
	public Opportunity opp			{get;set;}
	public Boolean isAddedPro		{get;set;}
	public Boolean isEmptyPro		{get;set;}
	public Boolean showType1		{get;set;}
	public Boolean showType2		{get;set;}
	
	public final static String ERR_NO_KEY_SEARCH = 'You have to input Produt Name, Product Family, or Business Unit to search the Product.';
	public final static String ERR_TOO_MANY_RESULT = 'This search has produced too many results, please refine your search';
	public final static String ERR_EMPTY_RESULT = 'No records to display.';
	public final static String ERR_EMPTY_VALUE = 'You must enter a value';
	
	private final static Integer MAX_RESULT_SEARCH = 200;
	private final static Integer MAX_ADD_PRODUCT = 199;
	private Set<String> proFamilyOptionSubscription = new Set<String>{'Subscriptions'};
	private Set<String> proFamilyOptionOtherSubscript = new Set<String>{'Online', 'Event', 'Print'};
	
	private String oppPbId;
	//private String oppcurrency;
	private Boolean hasTop;
	
	private List<OpportunityLineItem> lstOpli2Del = new List<OpportunityLineItem>();
	private Map<String, OpportunityLineItem> mapOldOppPros = new Map<String, OpportunityLineItem>();
	
	private String queryPro = 'Select Id, ProductCode, Name, Family, Business_Unit__c From Product2 Where IsActive = true ';
	
	public AddProductsController(){
		isAddPro = Apexpages.currentPage().getParameters().get('isnew') == 'true';
		String oppId = Apexpages.currentPage().getParameters().get('oppId');
		
		if(oppId == null || oppId == '') return;
		
		oppId = (oppId != null && oppId != ''? String.escapeSingleQuotes(oppId): '');
		
		//get Opportunity
		List<Opportunity> lstOpps = [Select Id, Name, OwnerId, Business_Unit__c, Pricebook2Id From Opportunity Where id=: oppId];
		List<Pricebook2> lstDefualtPricebook = [Select Id From Pricebook2 Where Name = 'Standard Price Book' limit 1];
		
		oppPbId = (lstOpps.isEmpty() ? lstDefualtPricebook.get(0).ID: (lstOpps.get(0).Pricebook2Id == null ? lstDefualtPricebook.get(0).ID:lstOpps.get(0).Pricebook2Id));
		opp = lstOpps.get(0);
		//oppcurrency = lstOpps.isEmpty()? oppcurrency : opp.CurrencyIsoCode;
		
		//the Business Unit drop down search option be defaulted to Business Unit field on the Opportunity
		keyBusinessUnit = opp.Business_Unit__c;
		
		pageNum = 1;
		numbtn = new Set<Integer>();
		lstMainOppPros = new  List<OppProduct>();
		
		if(isAddPro){
			initProduct();
		}else{
			handleEdit();
		}
	}
	
	private void initProduct(){
		isSearched = false;
		isAddedPro = false;
		isEmptyPro = false;
	}
	
	private void handleEdit(){
		Integer i = 0;
		
		for(OpportunityLineItem opli: [Select Id, PricebookEntryId, UnitPrice, Quantity, OpportunityId, PricebookEntry.Product2.Name, 
											PricebookEntry.Product2.Family, ServiceDate, Renewal_Rate__c, Expiry_Date__c, Contact__c
											From OpportunityLineItem Where OpportunityId =: opp.Id]){
									
			Boolean isOptionSubscription = proFamilyOptionSubscription.contains(opli.PricebookEntry.Product2.Family);
						
			lstMainOppPros.add(new OppProduct(i, opli.PricebookEntry.Product2.Name, opli, isOptionSubscription));		
			mapOldOppPros.put(opli.Id, opli.clone());					
			i++;			
		}
		gotoPage();
		isAddedPro = true;
	}
	
	/**
	* Method to display error message
	*/
	private void displayError(String val){
		Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, val);
		Apexpages.addMessage(msg);
	}
	
	/**
	* Method add product
	*/
	public Pagereference addProduct(){
		
		//limit add product
		if(lstMainOppPros.size() >= MAX_ADD_PRODUCT){
			displayError('You can add only 200 Products per transaction.');
			return null;
		}
		
		ProductResult proRes = lstProResults.get(position);
		
		//The Business Unit/ Service Line/ Revenue Strem will default from the Product but this may be changed by the user.
		//ServiceLine = Product Family
		//Revenue Owner will default to Opportunity Owner
		OpportunityLineItem opli = new OpportunityLineItem(	
															UnitPrice 			= proRes.pbe.UnitPrice, 
															Quantity 			= 1, 
															OpportunityId 		= opp.Id
															
															);
		
		Boolean isOptionSubscription = proFamilyOptionSubscription.contains(proRes.pro.Family);
		lstMainOppPros.add(new OppProduct(lstMainOppPros.size(), proRes.pro.Name, opli, proRes.pbe, isOptionSubscription));
		isAddedPro = true;
		gotoPage();
		return null;
	}
	
	/**
	* Method remove product
	*/
	public Pagereference removeProduct(){
		Integer i = 0;
		for(OppProduct opli: lstMainOppPros){
			if(opli.index == position){
				
				OppProduct oppProDel = lstMainOppPros.get(i);
				if(oppProDel.oppPro.Id != null) lstOpli2Del.add(oppProDel.oppPro);
		
				lstMainOppPros.remove(i);
				break;
			}
			i++;
		}
		
		
		isAddedPro = !lstMainOppPros.isEmpty();
		gotoPage();
		return null;
	}
	
	//Block Pagination
	private final static Integer MAXRECORD = 15;
	
	public Boolean hasNext {get;set;}
	public Integer pageNum {get;set;}
	public String disNumOfRecPerPage {get;set;}
	public Set<Integer> numBtn {get;set;}
	
	private Decimal getMaxPage(){
		Decimal d = lstMainOppPros.size()/Decimal.valueOf(MAXRECORD);
		return d.round(System.Roundingmode.CEILING);
	}
	
	private Integer getStartIndexRec(Integer pageNumber){
		return (pageNumber * MAXRECORD) - MAXRECORD;
	}
	
	private void setListToDisplay(Integer indexStart , List<OppProduct> lRec){
		if(indexStart < 0) indexStart = 0;
		lstOppPros = new List<OppProduct>();
		
		Integer lastNumOfRec = lRec.size();
		Integer indexRec =  indexStart + 1;
		Integer lastRecPerPage = indexStart + MAXRECORD;

		if(lastRecPerPage > lastNumOfRec) lastRecPerPage = lastNumOfRec;
		disNumOfRecPerPage = 'Record ' + indexRec + ' - ' + lastRecPerPage + ' of ' + lastNumOfRec;
		for(Integer i = indexStart; i< (indexStart + MAXRECORD); i++){
			if(lRec.size() <= i) break;
			lstOppPros.add(lRec.get(i));
		}   
	}
	
	public Pagereference gotoPage(){
		numbtn = new Set<Integer>();
		
		for(Integer i=1; i<=Integer.valueOf(getMaxPage()); i++ ){
			numbtn.add(i);
		}
		if(pageNum > Integer.valueOf(getMaxPage())) pageNum = Integer.valueOf(getMaxPage());
		
		hasNext = (pageNum != Integer.valueOf(getMaxPage()) && Integer.valueOf(getMaxPage()) > 1);
		
		setListToDisplay(getStartIndexRec(pageNum), lstMainOppPros);
		return null;
	}
	
	//go next page
	public Pagereference goNext(){
		pageNum++;
		if(pageNum >= getMaxPage()){
			pageNum = Integer.valueOf(getMaxPage());
		}
		gotoPage();
		return null;
	}
	
	//go previous Page
	public Pagereference goPrevious(){
		pageNum--;
		if(pageNum <= 1){
			pageNum = 1;
		}
		gotoPage();
		return null;
	}
	
	/**
	* Method Search Product by Name or Family
	*/
	public Pagereference doSearch(){
		if((keyProductFamily == null || keyProductFamily == '') && (keyProductName == null || keyProductName == '') && (keyBusinessUnit == null || keyBusinessUnit == '')){
			displayError(ERR_NO_KEY_SEARCH);
			return null;
		}
		
		lstProResults = new List<ProductResult>();
		
		keyProductFamily = (keyProductFamily == null ? '': keyProductFamily);
		keyProductName = (keyProductName == null? '' : keyProductName);
		keyBusinessUnit = (keyBusinessUnit == null? '': keyBusinessUnit);
		
		String conditionProName = (keyProductName == ''? '' : ' Name like \'%' + String.escapeSingleQuotes(keyProductName) + '%\'');
		String conditionProFami = (keyProductFamily == '' ? '': ' Family=:keyProductFamily');
		String conditionBusiUnit= (keyBusinessUnit == '' ? '' : ' Business_Unit__c=:keyBusinessUnit');
		
		String condition = (conditionProName == '' ? '' : ' AND ' + conditionProName);
		condition += (conditionProFami == ''? '' : ' AND ' + conditionProFami);
		condition += (conditionBusiUnit == ''? '' : ' AND ' + conditionBusiUnit);
		condition += ' order by Name limit 1000';
		
		List<Product2> lstPros = Database.query(queryPro + condition);
		
		//If there are too many result, alert msg to search again
		if(lstPros.size() > MAX_RESULT_SEARCH){
			displayError(ERR_TOO_MANY_RESULT);
			return null;
		}
		 
		isSearched = true;
		
		//If there aren't any result
		if(lstPros.isEmpty()){
			isEmptyPro = true;
			displayError(ERR_EMPTY_RESULT);
			return null;
		}
		isEmptyPro = false;
		
		//get Pricebook that match Product's Pricebook
		Set<String> sPriceBookMatchOpp = new Set<String>();
		for(PricebookEntry pbe: [Select Product2Id, Pricebook2Id 
									From PricebookEntry 
									Where Product2Id in: lstPros 
										AND IsActive = true
										AND Pricebook2Id =: oppPbId]){
			
			sPriceBookMatchOpp.add(pbe.Product2Id + '_' + pbe.Pricebook2Id);								
		}
		 
		//get PricebookEntry that matched Product
		Map<String, PricebookEntry> mapPricebookEntries = new Map<String, PricebookEntry>();//<product id, pbe>
		 
		for(PricebookEntry pbe: [Select Id, UnitPrice, Product2Id, Pricebook2Id
									From PricebookEntry 
									Where IsActive = true 
										//	AND CurrencyIsoCode =: oppcurrency
											AND Product2Id in: lstPros
											])	{
			
			 
			String orgKey = pbe.Product2Id + '_' + pbe.Pricebook2Id;
			if(!sPriceBookMatchOpp.contains(orgKey))	{
				pbe = new PricebookEntry(
										//CurrencyIsoCode = oppcurrency,
										IsActive = true,
										Product2Id = pbe.Product2Id,
										UseStandardPrice = false,
										Pricebook2Id = oppPbId,
										UnitPrice = pbe.UnitPrice);
			}	
			if(!mapPricebookEntries.containsKey(pbe.Product2Id) || sPriceBookMatchOpp.contains(orgKey)){
				mapPricebookEntries.put(pbe.Product2Id, pbe);	
			}
		}
		 
		Integer i = 0;
		for(Product2 pro: lstPros){
			
			//If product isnt have pricebookEntry, remove it from search result
			if(!mapPricebookEntries.containsKey(pro.Id)) continue;
			lstProResults.add(new ProductResult(i, pro, mapPricebookEntries.get(pro.Id)));
			i++;
		}
		if(lstProResults.isEmpty()){
			isEmptyPro = true;
			displayError(ERR_EMPTY_RESULT);
			return null;
		}
		
		return null;
	}
	
	/**
	* Method Save Opportunity Product
	*/
	public Pagereference doSave(){
		List<OpportunityLineItem> lstOplis = new List<OpportunityLineItem>();
		List<PricebookEntry> lstPbes = new List<PricebookEntry>();
		
		//check Pricebook Entry is existed or not
		//If not, create a new one
		for(OppProduct opli: lstMainOppPros){
          System.debug('IN OppProduct For Loop');
			if(isAddPro && opli.pbe != null && opli.pbe.Id == null) {
				lstPbes.add(opli.pbe);
                System.debug('Adding OppProduct');
			}
		}
		System.debug('=================================' + lstPbes);
		if(!lstPbes.isEmpty()){
			insert lstPbes;
		}
		
		for(OppProduct opli: lstMainOppPros){
            System.debug('IN OppProduct 2 For Loop');
            
            
			if(opli.oppPro.PricebookEntryId == null){
				opli.oppPro.PricebookEntryId = opli.pbe.id;
                System.debug('Adding PricebookEntryId in null if');
			}
			lstOplis.add(opli.oppPro);
            System.debug('Adding PricebookEntryId');
		}
		
		//Check Opportunity Product to delete RS
		//mapOldOppPros
		
		if(!lstOplis.isEmpty()){
            System.debug('in IF !lstOplis.isEmpty()');
			try{
				Boolean isPass = isPassValidation(lstOplis);
				if(isPass){
					
					
					//delete opp product
					if(!lstOpli2Del.isEmpty()){
						delete lstOpli2Del;
                        System.debug('Deleting lstOpli2Del');
					}
					
					upsert lstOplis;
                    System.debug('upsert lstOpli2Del');
				}else{
					return null;
				}
			}catch(Exception ex){
				displayError(ex.getMessage());
				return null;
			}
		}
		
		
		return doCancel();
	}
	

	
	/**
	* Method to validate Opportunity Product before save
	*/
	private Boolean isPassValidation(List<OpportunityLineItem> lstOplis){
		Boolean isPass = !lstOplis.isEmpty();
		
		
		for(OpportunityLineItem opli: lstOplis){
			
			//check SalesPrice
			if(opli.UnitPrice == null || opli.UnitPrice == 0){
				opli.UnitPrice.addError(ERR_EMPTY_VALUE);
				isPass = false;
			}
			
			
		}
		return isPass;
		
	}

	public Pagereference doCancel(){
		return new Pagereference('/' + opp.Id);
	}
	
	public List<SelectOption> productFamily {
        get {
            List<SelectOption> options = new List<SelectOption>();
             options.add(new SelectOption('', '-- None --'));
            Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                if(f.isActive())
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }      
            return options;
        }
        private set;
    }
    
    public List<SelectOption> productBusinessUnit {
        get {
            List<SelectOption> options = new List<SelectOption>();
             options.add(new SelectOption('', '-- None --'));
            Schema.DescribeFieldResult fieldResult = Product2.Business_Unit__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple) {
                if(f.isActive())
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }      
            return options;
        }
        private set;
    }
    
    class ProductResult{
    	public Product2 pro {get;set;}
    	public Integer index {get;set;}
    	public PricebookEntry pbe {get;set;}
    	
    	public ProductResult(Integer index, Product2 pro, PricebookEntry pbe){
    		this.index = index;
    		this.pro = pro;
    		this.pbe = pbe;
    	}
    	
    }
    
    class OppProduct{
    	
    	public String proName {get;set;}
    	public OpportunityLineItem oppPro {get;set;}
    	public PricebookEntry pbe {get;set;}
    	public Integer index {get;set;}
    	public Boolean isOptionSubscription {get;set;}
    	
    	public OppProduct(Integer index, String proName, OpportunityLineItem oppPro, PricebookEntry pbe, Boolean isOptionSubscription){
    		this.proName = proName;
    		this.oppPro = oppPro;
    		this.pbe = pbe;
    		this.index = index;
    		this.isOptionSubscription = isOptionSubscription;
    	}
    	
    	public OppProduct(Integer index, String proName, OpportunityLineItem oppPro, Boolean isOptionSubscription){
    		this.proName = proName;
    		this.oppPro = oppPro;
    		this.index = index;
    		this.isOptionSubscription = isOptionSubscription;
    	}
    }
    
}