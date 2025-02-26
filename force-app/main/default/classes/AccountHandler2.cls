public with sharing class AccountHandler2 {
    const var1 = 34;

    public AccountHandler2() {
        List<Account> accToUpdate = [SELECT Id, Name FROM Account LIMIT 300];
        for(int i=0; i<300; i++){
            List<Account> accToUpdateNew = [SELECT Id, Name FROM Account LIMIT 10];
            accToUpdate[i].Name = accToUpdate[i].Name + ' ' + i;
            insert accToUpdate[i];
        }
    }

    public void idError(){
        Account test = new Account(Name='Bhanu');
        System.debug(test.id);
    }

    public void accountError(){
        
    }
}