public  with sharing class VaidDiallerRetrieveRecords {
    @InvocableMethod(label='Update Dial Entries' description='Updates Dial Entries based on criteria')
    public static List<UpdateResult> updateDialEntries(List<UpdateRequest> requests) {
        List<UpdateResult> results = new List<UpdateResult>();
        System.debug('Starting updateDialEntries:::');

        String noRecordsFoundMessage = 'No records found to update';
        String recordsUpdatedMessage = 'Records updated successfully';


        // Handle bulk requests
        for (UpdateRequest request : requests) {

            System.debug('Request::: ' + request);

            try {
                String queryString = constructQueryString(request);
                System.debug('Query String::: ' + queryString);

                // first query to get ordered by records
                List<VAID_Dial_Entry__c> entriesToUpdate = Database.query(queryString);
                System.debug('Entries to Update::: ' + entriesToUpdate.size());
                    
                
                if (!entriesToUpdate.isEmpty()) {
                    // Second query to lock the records
                    Set<Id> entryIds = new Set<Id>();
                    for (VAID_Dial_Entry__c entry : entriesToUpdate) {
                        entryIds.add(entry.Id);
                    }
                    entriesToUpdate = [SELECT Id FROM VAID_Dial_Entry__c WHERE Id IN :entryIds FOR UPDATE];

                    for (VAID_Dial_Entry__c entry : entriesToUpdate) {
                        entry.VAID_Dial_Status__c = 'Retrieved';
                    }    
    
                    Database.SaveResult[] saveResults = Database.update(entriesToUpdate, true);
                    Integer updatedCount = 0;
                    for (Database.SaveResult sr : saveResults) {
                        if (sr.isSuccess()) {
                            updatedCount++;
                        }
                    }
                    System.debug('Save Result::: ' + saveResults);
                    results.add(new UpdateResult(updatedCount, recordsUpdatedMessage));

                } else {
                    System.debug('Save Result::: ' + noRecordsFoundMessage);
                    results.add(new UpdateResult(0, noRecordsFoundMessage));
                }

            } catch (Exception e) {
                System.debug('Exception::: ' + e.getMessage());
                results.add(new UpdateResult(0, e.getMessage()));
                
            }
        }
        return results;
    }

    private static String constructQueryString(UpdateRequest request) {
        Id dialListId = request.dialListId;
        Boolean priorityFilterEnabled = request.priorityFilterEnabled;
        Boolean phoneNumberFilterEnabled = request.phoneNumberFilterEnabled;
        Boolean recoveryTypeFilterEnabled = request.recoveryTypeFilterEnabled;
        String prioritisationSortField = request.prioritisationSortField;
        String prioritisationSortOrder = request.prioritisationSortOrder;
        String priorityFilter = request.priorityFilter;
        String phoneNumberFilter = request.phoneNumberFilter;
        String recoveryTypeFilter = request.recoveryTypeFilter;
        Integer concurrentDials = request.concurrentDials;

        String queryString = 'SELECT Id FROM VAID_Dial_Entry__c WHERE VAID_Is_Dialable__c = true AND VAID_Dial_List__c = \'' + dialListId + '\'';
        
        if (priorityFilterEnabled && priorityFilter != null) {
            queryString += ' AND VAID_Recovery_Flow__r.Priority__c = ' + priorityFilter;
        }
        if (phoneNumberFilterEnabled && phoneNumberFilter != null) {
            queryString += ' AND VAID_Phone_Number_Type__c = ' + phoneNumberFilter;
        }
        if (recoveryTypeFilterEnabled && recoveryTypeFilter != null) {
            queryString += ' AND Recovery_Type__c = ' + recoveryTypeFilter;
        }

        // Add Order By Clauses

        queryString += ' ORDER BY VAID_Phone_Number_Type__c';

        if ( prioritisationSortField != null & prioritisationSortOrder != null) {
            if (prioritisationSortOrder == 'ASC') {
                queryString += ', ' + prioritisationSortField +  ' ASC';
            } else if (prioritisationSortOrder == 'DESC') {
                queryString += ', ' + prioritisationSortField +  ' DESC';
            } else {
                queryString += ', VAID_Prioritization_Score__c DESC';
            }
        }

        queryString += ', VAID_Next_Contact_Time__c';
            
        // Add Limit Clause for number of concurrent dials per second
        if (concurrentDials != null && concurrentDials <= 3) {
            queryString += ' LIMIT ' + concurrentDials;
        } else {
            // Max of 3 concurrent dialers per second
            queryString += ' LIMIT 3';
        }

        return queryString;
    }    

    public class UpdateRequest {
        @InvocableVariable(required=true label='Dial List Id')
        public String dialListId;
        
        @InvocableVariable(required=true label='Priority Filter Enabled')
        public Boolean priorityFilterEnabled;
        
        @InvocableVariable(required=false label='Priority Filter')
        public String priorityFilter;
        
        @InvocableVariable(required=true label='Phone Number Filter Enabled')
        public Boolean phoneNumberFilterEnabled;
        
        @InvocableVariable(required=false label='Phone Number Filter')
        public String phoneNumberFilter;
        
        @InvocableVariable(required=true label='Recovery Type Filter Enabled')
        public Boolean recoveryTypeFilterEnabled;
        
        @InvocableVariable(required=false label='Recovery Type Filter')
        public String recoveryTypeFilter;
        
        @InvocableVariable(required=true label='Prioritisation Sort Field' description='Pass in API Name of the field to sort by from the VAID_Dial_Entry__c object. Default is VAID_Prioritization_Score__c')
        public String prioritisationSortField;
        
        @InvocableVariable(required=true label='Prioritisation Sort Order' description='Valid Options are ASC or DESC')
        public String prioritisationSortOrder;

        @InvocableVariable(required=false label='Concurrent Dials' description='Number of concurrent dials. Current max is 3')
        public Integer concurrentDials;
    }

    public class UpdateResult {
        @InvocableVariable(description='Number of records updated')
        public Integer updatedCount;
        
        @InvocableVariable(description='Result message')
        public String message;
        
        public UpdateResult(Integer updatedCount, String message) {
            this.updatedCount = updatedCount;
            this.message = message;
        }
    }

}
