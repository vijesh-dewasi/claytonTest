trigger accountLimitsExample on Account (after delete, after insert, after update) {

                System.debug('Total Number of SOQL Queries allowed in this Apex code context: ' + Limits.getLimitQueries());
                
                System.debug('Total Number of records that can be queried in this Apex code context: ' + Limits.getLimitQueryRows());
                
                System.debug('Total Number of DML statements allowed in this Apex code context: ' + Limits.getLimitDMLStatements());
                
                System.debug('Total Number of CPU usage time (in ms) allowed in this Apex code context: ' + Limits.getLimitCpuTime());
                
                
                List<Opportunity> opptys = [select id, description, name, accountid, closedate, stagename from Opportunity where accountId IN:  Trigger.newMap.keySet()];
      
                System.debug('1. Number of Queries used in this Apex code so far: ' + Limits.getQueries());
                
                System.debug('2. Number of rows queried in this Apex code so far: ' + Limits.getQueryRows());
                
                System.debug('3. Number of DML statements used so far: ' + Limits.getDMLStatements());
                
                System.debug('4. Amount of CPU time (in ms) used so far: ' + Limits.getCpuTime());
                
    			if(opptys.size()==0)
                    System.debug('no opportunities to update here');
    		    
                if(opptys.size()>Limits.getLimitDMLStatements()) {
				   // Logic to avoid governor limits - addError 
				   opptys[0].addError('cant perform the operation due to dml limits');                               
                }   
                else
                {
                    
                    System.debug('Continue processing. Not going to hit DML governor limits');
                    
                    System.debug('Going to update ' + opptys.size() + ' opportunities and governor limits will allow ' + Limits.getLimitDMLStatements());
                
                    for(Account a : Trigger.new){
                    
                            System.debug('Number of DML statements used so far: ' + Limits.getDMLStatements());
                        
                            
                            for(Opportunity o: opptys){
                            
                                    if (o.accountid == a.id)
                                    
                                    o.description = 'testing';
                            
                            }
                    
                    }
                
                    update opptys;
                    
                    System.debug('Final number of DML statements used so far: ' + Limits.getDMLStatements());
                    
                    System.debug('Final heap size: ' + Limits.getHeapSize());
                
                }

}