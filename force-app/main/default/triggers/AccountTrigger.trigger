trigger AccountTrigger on Account (before update) {
    
    for(Account a:trigger.new){
		a.UpdateCount__c+=1;
    }
}