public class SobjectHandler {
     //Create a class which show the list of sobjects exists in org.
    public static void sObjectList(){
        
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String name: gd.keyset()){
            System.debug(name);
        }
        
    }
}