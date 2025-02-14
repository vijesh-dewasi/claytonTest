trigger accountTestTrigger on Account (before insert, before update) {

                List<Contact> contacts = [select id, salutation, firstname, lastname, email from Contact where accountId IN :trigger.new];
                
    			for(Contact c: contacts) {
                    System.debug('Contact Id[' + c.Id + '], FirstName[' + c.firstname + '],LastName[' + c.lastname +']');
                    c.Description=c.salutation + ' ' + c.firstName + ' ' + c.lastname;
                   
                }
    
                update contacts;
}