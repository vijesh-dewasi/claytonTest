public class ClassHandler {
    public static List<String> students(id classId){
        if(classId==null)
            return null;
		List<String> studentsName = new List<String>();
        List<Student__c> students =  [SELECT name,LastName__c FROM Student__C WHERE class__c=:classID];
        for(Student__c s:students){
         	studentsName.add(s.Name+s.LastName__c);   
        }
        return studentsName;
    }
    
    //Create a function which returns a map where key is class and value is set of studentId in it.
   
    public static Map<Class__c,Set<id>> students(){
        
        Map<id,Class__c> classes = new  Map<id,Class__c>([SELECT id,name FROM Class__c]);
        
        Map<Class__c,Set<id>> result= new Map<Class__c,Set<id>>();
        
        List<Student__c> students =  [SELECT id,Class__c FROM Student__C];
        
        for(Student__c s : students){
            if(!result.containsKey(classes.get(s.Class__c))){
                 result.put(classes.get(s.Class__c),new Set<Id>());    
            }
            result.get(classes.get(s.Class__c)).add(s.Id);
        }
	 
        return result;
    }
    
    //Create a function which take two dates as argument and return number of working days between two
    //dates excluding both days. (Saturday and Sunday is non-working days)
    
    public static Integer getWeekDay(Date de){
        //Zeller’s Rule
        //k is  the day of the month.
        //m is the month number.
        //D is the last two digits of the year.
        //C is the first two digits of the year.
        Integer k = de.day();
        Integer m = de.month()-2;
        
        if(m==0 || m==-1)
           m+=12;
        Integer year = de.year();
        Integer D = math.mod(year,100);
        Integer C = year/100;
        Integer startWeekDay = k + ((13*m-1)/5) +D+ (D/4) +(C/4)-2*C;
        return startWeekDay;
    }
    
    public static Integer workDays(Date startDate,Date endDate){
        
        Integer ans=0;
        
        Integer daysBetwn  = startDate.daysBetween(endDate)-1;
        if(daysBetwn<0)
            daysBetwn*=-1;
        if(daysBetwn==0)
            return ans;
        
		Integer startWeekDay =  math.mod((getWeekDay(startDate)+1),7);
		Integer endWeekDay =    math.mod((getWeekDay(endDate)-1),7);
        
        if(daysBetwn>=7)
        ans=2*daysBetwn/7;
        
        Integer extraDays =  math.mod(daysBetwn,7);
        
        if(extraDays==0)
           return ans; 
        
        for(Integer i=0;i<extraDays;i++){
            if(math.mod(endweekDay-i,7)==0 || math.mod(endweekDay-i,7)==1)
                return ans++;
        }
        return ans;
    }
   
}