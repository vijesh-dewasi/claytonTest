public with sharing class AccountListController {
    @AuraEnabled(cacheable=true)
    public static List<Account> accs(){
			return [SELECT id,name,type,phone FROM Account LIMIT 50 ];
    }
    
    
}