@IsTest
public class AccountHandlerTest {
    
	@IsTest
    static void testContactIDFiller(){
        
	    Account a = new Account(Name='Test Account');
        insert a;
        
        Contact c = new Contact(FirstName='vijesh',LastName='dewasi',AccountId=a.Id);
        insert c;
      
        Contact c1 = new Contact(FirstName='dev',LastName='test');
        insert c1;
        
        Test.startTest();
        AccountHandler.contactIDFiller(a.Id,c.Id);
        AccountHandler.contactIDFiller(a.Id,c1.Id);
        Test.stopTest();
		Account updatedA = [SELECT id,ContactIDs__c FROM  Account WHERE ID =:a.Id limit 1];                        
        System.assertEquals(c.Id+','+c1.Id+',',updatedA.ContactIDs__c);
               
    }

}