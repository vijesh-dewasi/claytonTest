trigger ClassTrigger on Class__c (before delete) {
    
    List<Id>classes = new List<Id>(); 
    for(Class__c c: trigger.new){
    	    classes.add(c.id);
	}
    AggregateResult[] femaleCount = [SELECT Class__c,Count(id) cnt FROM Student__c WHERE Sex__c='Female' AND id IN :classes GROUP BY Class__c HAVING Count(id)>1]; 
    Map<id,Integer> classCount = new Map<Id,Integer>();
    
    for(AggregateResult a: femaleCount){
		classCount.put((id)a.get('Class__c'),(integer)a.get('cnt'));
    }
    
    for(Class__C c: trigger.new){
        if(classCount.containsKey(c.id)){
			c.addError('more that 1 female in class cant delete');
        }
    }
   
}