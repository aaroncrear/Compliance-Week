/**
* Class to override Standard Salesforce's button Create Opli and Edit all Opli
* @created date: 10-Jan-2014
* @author: Sopha Pum
*/
public  class RedirectCreateEditAllOpliController {
	public String curOppRecType {get;set;}
	
	private String oppId;
	private Boolean isAddNew;
	private Boolean isSubscription;
	
	private String urlStandardAddProduct = '/p/opp/SelectSearch?addTo=#OPPID#&retURL=%2F#OPPID#&nooverride=1';
	private String urlStandardEditAllPro = '/oppitm/multilineitem.jsp?oppId=#OPPID#&retURL=%2F#OPPID#&nooverride=1';
	
	private String urlCustomAddProduct = '/apex/AddProducts?oppid=#OPPID#&isnew=#ISNEW#';
	
	public final static String OPP_SUBSCRIPTION = 'Subscriptions_Opportunity';
	
	public RedirectCreateEditAllOpliController(ApexPages.StandardController controller){
		isAddNew = Apexpages.currentPage().getParameters().get('addTo') != null;
		oppId = controller.getId();
		isSubscription = [Select RecordType.DeveloperName From Opportunity Where Id =: oppId].RecordType.DeveloperName == OPP_SUBSCRIPTION;
	}
	
	/**
	* Method redirect to custom link add product if opportunity is Xchange
	*/
	public Pagereference doRedirect(){
		
		//String urlRedirect = (isSubscription? urlCustomAddProduct: (isAddNew ? urlStandardAddProduct: urlStandardEditAllPro));
		String urlRedirect = urlCustomAddProduct;
		urlRedirect = urlRedirect.replace('#OPPID#', oppId);
		//urlRedirect = (isSubscription? urlRedirect.replace('#ISNEW#', isAddNew + ''): urlRedirect);
		urlRedirect = urlRedirect.replace('#ISNEW#', isAddNew + '');
		Pagereference page = new Pagereference(urlRedirect);
		page.setRedirect(true);
		return page;
	}
}