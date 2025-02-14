public class InActiveOppMailer{
    public void sendMailsToInActiveOpps( Integer days){
        if(days<0){
            days*=-1;
		}
        DateTime nowLessDays =  Datetime.now();
        nowLessDays.addDays(-1*days);
        
        List<Opportunity> opps = [SELECT id,name,OwnerId,LastModifiedDate FROM Opportunity WHERE LastModifiedDate<:nowLessDays];
        List<id>owners = new List<id>();
        
        for(Opportunity opp : opps){
            owners.add(opp.ownerId);
        }
        Map<id,User> ownerMap = new Map<id,user>([SELECT id,Email FROM User WHERE id IN :owners]);
        
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
            
        for(Opportunity opp : opps){
          
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String[] toAddresses = new String[] {ownerMap.get(opp.OwnerId).Email}; 
             
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('Salesforce Support');
            mail.setSubject('your opportunity needs to reviewed');
            mail.setPlainTextBody('Your opportunity'+opp.Name+ 'was last modified'+opp.LastModifiedDate+'please look into it');
            mails.add(mail);
        }
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage[] toSend = new Messaging.SingleEmailMessage[]{mails[0],mails[1]};
        Messaging.sendEmail(toSend);
    }
}