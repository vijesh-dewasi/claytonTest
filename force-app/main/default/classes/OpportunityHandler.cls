public class OpportunityHandler {
   public static void checkandFillManager(List<Opportunity>opps){
       for(Opportunity op : opps){
           if(op.BillToContact__c==null || op.Manager__c!=null){
			continue;
           }
           op.Manager__c=op.BillToContact__r.AccountId;
       }
       update opps;
   }
}