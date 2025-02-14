global class ScheduledOppMailer implements Schedulable {
   global void execute(SchedulableContext SC) {
            InActiveOppMailer m = new InActiveOppMailer();
            m.sendMailsToInActiveOpps(2);
   }
}