trigger TeacherTrigger on Teach__c (before insert,before update) {
		for(Teach__c t: trigger.new){
            if(t.subject__c=='Hindi' || (trigger.isUpdate && trigger.oldMap.get(t.id).subject__c=='Hindi')){
				t.addError('Hindi teachers can updated and inserted');
            }
        }
}