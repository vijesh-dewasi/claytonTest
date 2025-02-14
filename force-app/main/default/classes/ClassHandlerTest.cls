@IsTest
public class ClassHandlerTest {
    @IsTest
    static void studentsTest(){
        
        Class__c c = new Class__c(Name='testclass');
        insert c;
        
        Student__c s = new Student__c(LastName__c='bacha',Name='test',Sex__c='Male',Class__c=c.id);
        insert s;
        
        Test.startTest();
        List<String> studentsList = ClassHandler.students(c.id);
        Test.stopTest();
        System.assertEquals(studentsList.get(0),'testbacha');
    }
 
   
    @IsTest
    static void workDays(){
        	Date stDate = Date.newInstance(2024,5,17);
        	Date enDate = Date.newInstance(2024,5,28);
			System.assertEquals(2,ClassHandler.workDays(stDate,enDate));
    }    
}