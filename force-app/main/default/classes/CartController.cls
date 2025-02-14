public with sharing class CartController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> getOrders(Integer recordsPerPage,Integer pageNo,String sortDirection,String sortedBy){
        	if(recordsPerPage<=0 || pageNo<=0)
				throw new IllegalArgumentException('record per page and pageNo cant be negative');
        	
            if(sortDirection.toLowerCase()!='asc' && sortDirection.toLowerCase()!='desc')
                throw new IllegalArgumentException('record per page and pageNo cant be negative');
        
        	Integer offSet = recordsPerPage*(pageNo-1);
        	String queryString = 'SELECT id,name,Status__c,OrderTotal__c FROM purchaseOrder__c ORDER BY '+sortedBy+' '+sortDirection+' LIMIT '+recordsPerPage+' OFFSET '+offSet;
            List<sObject> sobjList = Database.query(queryString);
            return  sobjList;
			//return [SELECT id,name,Status__c,OrderTotal__c FROM purchaseOrder__c ORDER BY :sortedBy :sortDirection LIMIT :recordsPerPage OFFSET :offSet];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getProducts(Integer recordsPerPage,Integer pageNo,String sortDirection,String sortedBy,String searchTerm){
        	
        	if(recordsPerPage<=0 || pageNo<=0)
				throw new IllegalArgumentException('record per page and pageNo cant be negative');
        	
            if(sortDirection.toLowerCase()!='asc' && sortDirection.toLowerCase()!='desc')
                throw new IllegalArgumentException('record per page and pageNo cant be negative');
        	
        	String lowerSortedBy = sortedBy.toLowerCase();
        	List<String> validSortBy = new List<String>{
			'name','id','productcode','price__c','quantity__c'
            };
        
       	 	if(!validSortBy.contains(lowerSortedBy))
                throw new IllegalArgumentException('invaild sortBy');
			
        	System.debug('search term '+ searchTerm);
        	Integer offSet = recordsPerPage*(pageNo-1);
        	String queryString = 'SELECT id,name,ProductCode,price__c,Quantity__c FROM Product2 ORDER BY '+sortedBy+' '+sortDirection+' LIMIT '+recordsPerPage+' OFFSET '+offSet;
        	if(searchTerm!=null && searchTerm!='')
        	queryString ='SELECT id,name,ProductCode,price__c,Quantity__c FROM Product2 WHERE name LIKE \''+'%'+searchTerm+'%'+'\' ORDER BY '+sortedBy+' '+sortDirection+' LIMIT '+recordsPerPage+' OFFSET '+offSet;
            List<sObject> sobjList = Database.query(queryString);
            return  sobjList;
			//return [SELECT id,name,Status__c,OrderTotal__c FROM purchaseOrder__c ORDER BY :sortedBy :sortDirection LIMIT :recordsPerPage OFFSET :offSet];
    }
    
    @AuraEnabled(cacheable=true)
    public static Integer orderRecordCount(){
		    AggregateResult[] result =  [SELECT count(id) FROM purchaseOrder__c];
        	return (Integer)result[0].get('expr0');
    }
    
     @AuraEnabled(cacheable=true)
    public static Integer productRecordCount(String searchTerm){
        	System.debug('search term '+ searchTerm);
        	String query = 'SELECT count(id) FROM Product2';
        	if(searchTerm!='' && searchTerm!=null)
                query = 'SELECT count(id) FROM Product2 WHERE name LIKE \''+'%'+ searchTerm+'%'+'\'';
		    AggregateResult[] result =  Database.query(query);
        	return (Integer)result[0].get('expr0');
    }
    
    @AuraEnabled
    public static List<Product2> products(List<Id> idList){
		return [SELECT id,name,ProductCode,price__c,Quantity__c FROM Product2 WHERE id IN :idList];
    }
}