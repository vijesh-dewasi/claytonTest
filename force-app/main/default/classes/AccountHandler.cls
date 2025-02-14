public class AccountHandler {
    public static void contactIDFiller(id accountId,id contactID){
        
        if(accountId==null || contactId==null)
         return;            
        
        Account a = [SELECT id,ContactIDs__c FROM account WHERE id=:accountId LIMIT 1];
        
        if(a==null)
           return;
		        
        if(a.ContactIDs__c==null){
            string value = '';
            Contact[] cons = [SELECT id FROM contact WHERE AccountId=:accountId];
           	
            for(Contact c :cons){
               value=c.id;
               value+=',';    
            }
			a.ContactIDs__c=value; 
            
        }
        else{
            a.ContactIDs__c+=contactID;
            a.ContactIDs__c+=',';
        }
       		update a;
    }
}