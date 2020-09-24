/* TODO: Create/Delete Print_Run_Member__c
 * 
 * Author: Bunhor
 * Created Date: 30-Dec-2013
 */ 
public with sharing class PrintRunMember {
   
  public static final String PR_TYPE_DOMESTIC = 'Domestic';
  public static final String PR_TYPE_INTERNATIONAL = 'International';
  public static final String COUNTRY_CODE_US = 'US';
  
  /* Called from trigger after update on Print_Run__c 
   * Param1: Trigger.old
   * Param2: Trigger.new
   */
  public static void createOnPrintRunUpdate(List<Print_Run__c> oldPRs, List<Print_Run__c> newPRs){
    Map<String, Print_Run__c> mapPR = new Map<String, Print_Run__c>();
    for(Print_Run__c pr : newPRs){ 
      mapPR.put(pr.Id, pr); 
    }
    for(Print_Run__c pr : oldPRs){ 
      if(pr.Type__c == mapPR.get(pr.Id).Type__c){
        mapPR.remove(pr.Id);
      }
    }
    createOnPrintRunInsert(mapPR.values(), null);
  }
   
  /* Called from trigger after insert on Print_Run__c 
   * Param1: lstPR is inserting Print_Run__c
   * Param2: mapPI is null (not null if called from other methods of this class)
   */
  public static void createOnPrintRunInsert(List<Print_Run__c> lstPR_param, Map<String, Publication_Issue__c> mapPI){
     
    /*  When a Print Run Date has passed:
      - members should not be added or removed. 
      - even if the contact, publication issue, or print run is edited, do nothing on members
    */ 
    List<Print_Run__c> lstPR = new List<Print_Run__c>();
    for(Print_Run__c pr : lstPR_param){
      if(pr.Print_Run_Date__c != null && pr.Print_Run_Date__c >= System.today()){
        lstPR.add(pr);
      }
    }
    
    if(mapPI == null){
      Set<String> setPIId = new Set<String>();
      for(Print_Run__c pr : lstPR){
        setPIId.add(pr.Publication_Issue__c);
      } 
      mapPI = new Map<String, Publication_Issue__c>([Select Id, Publication_Date__c 
                                   From Publication_Issue__c 
                                   Where Id In :setPIId
                                   And Publication_Date__c != NULL]);
    }                                                 
    Map<String, Publication_Issue__c> mapPRIdPI = new Map<String, Publication_Issue__c>(); 
    Map<String, Print_Run__c> mapPR = new Map<String, Print_Run__c>(); 
    
    for(Print_Run__c pr : lstPR){
      Publication_Issue__c pi = mapPI.get(pr.Publication_Issue__c);
      if( pi != NULL && pi.Publication_Date__c != null && pr.Type__c != null){
        mapPRIdPI.put(pr.Id, pi);
        mapPR.put(pr.Id, pr);
      } 
    }
     
    create(mapPRIdPI, mapPR);
  }
  
  /* Called from trigger after update on Publication_Issue__c 
   * Param1: Trigger.old
   * Param2: Trigger.new
   */
  public static void createOnPublicationIssue(Publication_Issue__c[] oldPIs, Publication_Issue__c[] newPIs){
    Map<String, Publication_Issue__c> mapPI = new Map<String, Publication_Issue__c>();
    for(Publication_Issue__c pi : newPIs){
      if(pi.Publication_Date__c != NUll)
      mapPI.put(pi.Id, pi); 
    }
    
    Set<String> setPIID = new Set<String>();
    for(Publication_Issue__c pi : oldPIs){
      if(mapPI.get(pi.Id) != NULL && pi.Publication_Date__c != mapPI.get(pi.Id).Publication_Date__c) 
      setPIID.add(pi.Id);      
    } 
     
    createOnPrintRunInsert(getPRs(setPIID), mapPI);
  }
   
  /* Called from trigger after insert/update on Contact 
   * Param1: Trigger.old
   * Param2: Trigger.new
   */
  public static void createOnContact(List<Contact> lstOldCon, List<Contact> lstNewCon){
    
    Map<String, Contact> mapContact = new Map<String, Contact>();
    for(Contact con : lstNewCon){ 
      mapContact.put(con.Id, con); 
    }
    
    List<Date> lstDate = new List<Date>();                                                 
    
    // CASE: updating-------------------
    if(lstOldCon != null){    
      Set<String> sContactId = new Set<String>();//use for deleting Print_Run_Member__c
      for(Contact con : lstOldCon){  
        if( con.Send_Print_Magazine__c == true  && mapContact.get(con.Id).Send_Print_Magazine__c == true ){ 
          
          if( (con.Expiration_Date__c != mapContact.get(con.Id).Expiration_Date__c) || 
            (con.MailingCountryCode != mapContact.get(con.Id).MailingCountryCode ) ){    
              lstDate.add(con.Expiration_Date__c); 
              lstDate.add(mapContact.get(con.Id).Expiration_Date__c); 
          }
        
        // Case updating Send_Print_Magazine__c == true
        }else if( con.Send_Print_Magazine__c == false  && mapContact.get(con.Id).Send_Print_Magazine__c == true ){
          lstDate.add(mapContact.get(con.Id).Expiration_Date__c); 
        
        // Case updating Send_Print_Magazine__c == false
        }else if( con.Send_Print_Magazine__c == true  && mapContact.get(con.Id).Send_Print_Magazine__c == false ){
          sContactId.add(con.Id);
        }
      }
      // Deleting Print_Run_Member__c
      Print_Run_Member__c[] lstPR4delete = [Select Id From Print_Run_Member__c Where Member__c In :sContactId];
      delete lstPR4delete;
    
    // CASE: inserting------------------    
    }else{    
      for(Contact con : mapContact.values()){
        if(con.MailingCountryCode != NULL && con.Send_Print_Magazine__c == true){
          lstDate.add(con.Expiration_Date__c);
        } 
      }
    }  
     
      
    Date newestDate = getDate(lstDate, dateType.NEWEST);
    if(newestDate == null) return;
    
    Map<String, Publication_Issue__c> mapPI = new Map<String, Publication_Issue__c>([Select Id, Publication_Date__c 
                                                               From Publication_Issue__c 
                                               Where Publication_Date__c <= :newestDate 
                                                               And Publication_Date__c != NULL ]); 
    createOnPrintRunInsert(getPRs(mapPI.keySet()), mapPI); 
  }
  
  /* Called from other methods of this class (Logic class for inserting and removing Print_Run_Member__c)
   * Param1: mapPRIdPublicationDate (Print_Run__c.Id > Publication_Issue__c.Publication_Date__c)
   *-------------------------------------------------------------------------------------------*/  
  private static void create(Map<String, Publication_Issue__c> mapPRIdPI, Map<String, Print_Run__c> mapPR){ 
    
    if(mapPRIdPI.isEmpty()) return;
    
    List<Date> lstDate = new List<Date>();
    for(Publication_Issue__c pi : mapPRIdPI.values()){
      lstDate.add(pi.Publication_Date__c);
    } 
    Date oldestDate = getDate(lstDate, dateType.OLDEST); 
    
    Contact[] lstContact = [Select Id, Expiration_Date__c, MailingCountryCode 
                From Contact 
                Where Expiration_Date__c >= :oldestDate 
                And Expiration_Date__c != NULL 
                And MailingCountryCode != NULL 
                And Send_Print_Magazine__c = true]; 
    
    //if(lstContact.isEmpty()) return; 
                
    Map<String, Print_Run_Member__c> mapPRM = getMapPRM([Select Print_Run__c, Member__c 
                               From Print_Run_Member__c 
                               Where Print_Run__c in : mapPRIdPI.keySet()] ); 
                              
    Print_Run_Member__c[] lstInsertingPRM = new List<Print_Run_Member__c>(); 
    
    Set<String> setKey = new Set<String>();
    for(String PRId : mapPRIdPI.keySet()){ 
      for(Contact con : getContacts(lstContact, mapPRIdPI.get(PRId).Publication_Date__c, mapPR.get(PRId).Type__c) ){
        Print_Run_Member__c newPRM = new Print_Run_Member__c(Member__c = con.Id, Print_Run__c = PRId);
        if(mapPRM.get(getKey(newPRM))==null){
          lstInsertingPRM.add(newPRM);
        }
        setKey.add(getKey(newPRM)); 
      }
    }
    for(String key : setKey){
      mapPRM.remove(key);
    } 
    delete mapPRM.values(); 
    insert lstInsertingPRM; 
  }
    
  //---------------- Utility Methods------------------------------------
  
  /* TODO: Getting Contacts that Contact Expiration Date >= Publication Date */ 
  private static List<Contact> getContacts(List<Contact> lstContact, Date PublicationDate, String prType){
    Contact[] theList = new List<Contact>();
    for(Contact con : lstContact){
      if( con.Expiration_Date__c >= PublicationDate && 
        (   (prType == PR_TYPE_INTERNATIONAL && con.MailingCountryCode != COUNTRY_CODE_US) || 
            (prType == PR_TYPE_DOMESTIC && con.MailingCountryCode == COUNTRY_CODE_US)         )   ){
        
        theList.add(con); 
      }
    }
    return theList;
  }
  
  /* TODO: Getting Map Print_Run_Member__c from List */ 
  private static Map<String, Print_Run_Member__c> getMapPRM(List<Print_Run_Member__c> lstPRM){
    Map<String, Print_Run_Member__c> theMap = new Map<String, Print_Run_Member__c>();
    for(Print_Run_Member__c prm : lstPRM){
      theMap.put(getKey(prm), prm);
    }
    return theMap;
  }
  
  /* TODO: Getting a key for Map */ 
  private static String getKey(Print_Run_Member__c prm){ 
    return ('' + prm.Print_Run__c + prm.Member__c);
  }
    
  /* TODO: Getting a newest or oldest date */ 
  private static Date getDate(List<Date> lstDate, dateType type){ 
    List<Date> lstTem = new List<Date>();
    for(Date d :lstDate){
      if(d != null) lstTem.add(d);
    }
    lstTem.sort(); 
    if(lstTem.isEmpty()) return null;
    return (type==dateType.OLDEST? lstTem[0] : lstTem[lstTem.size()-1]);
  } 
  private enum dateType {NEWEST, OLDEST} 
  
  /* TODO: Getting List of Print_Run__c for Publication_Issue__c*/ 
  private static Print_Run__c[] getPRs(Set<String> setPIId){ 
    
    return [Select Id, Publication_Issue__c, Type__c, Print_Run_Date__c 
        From Print_Run__c 
        Where Publication_Issue__c In :setPIId
          And Type__c != null
          And Print_Run_Date__c != null
          And Print_Run_Date__c >= :System.today()];
  }
  
}