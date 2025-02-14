trigger optimize2 on Account (before delete, before insert, before update) {
            List<Opportunity> opptysClosedLost = [select id, name, closedate, stagename from Opportunity where accountId IN :Trigger.newMap.keySet() and StageName='Closed - Lost'];
            List<Opportunity> opptysClosedWon =  [select id, name, closedate, stagename from Opportunity where accountId IN :Trigger.newMap.keySet() and StageName='Closed - Won'];
            
            
            for(Opportunity o: opptysClosedLost){
                if(trigger.newMap.containsKey(o.accountid)){
                    System.debug('Do more logic here...');
                }
                    
            }
    
            for(Opportunity o: opptysClosedWon){
                if(trigger.newMap.containsKey(o.accountid)){
                    System.debug('Do more logic here...');
				}
            }
            
}