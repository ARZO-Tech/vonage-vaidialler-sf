@IsTest
public class VaiDiallerRetrieveRecordsTst {

    @IsTest
    static void testUpdateDialEntries() {
        VAID_Dial_List__c dialList = new VAID_Dial_List__c();
        dialList.Name = 'Test Dial List';
        dialList.VAID_Agent_Queue_ID__c = '00GHz000003yUl7MAE';
        insert dialList;

        List<VAID_Dial_Entry__c> entries = new List<VAID_Dial_Entry__c>();
        for (Integer i = 0; i < 5; i++) {
            VAID_Dial_Entry__c entry = new VAID_Dial_Entry__c();
            entry.VAID_Dial_List__c = dialList.Id;
            entry.Name = 'Test Dial Entry ' + i;
            entry.VAID_Dial_Status__c = 'Ready';
            entry.VAID_Phone_Number_Type__c = '1';
            entries.add(entry);
        }
        insert entries;

        VaidDiallerRetrieveRecords.UpdateRequest request = new VaidDiallerRetrieveRecords.UpdateRequest();
        request.dialListId = dialList.Id;
        request.priorityFilterEnabled = false;
        request.priorityFilter = 'Normal';
        request.phoneNumberFilterEnabled = false;
        request.phoneNumberFilter = '1';
        request.recoveryTypeFilterEnabled = false;
        request.recoveryTypeFilter = 'DEFAULT';
        request.prioritisationSortField = 'VAID_Prioritization_Score__c';
        request.prioritisationSortOrder = 'DESC';

        Test.startTest();
        List<VaidDiallerRetrieveRecords.UpdateResult> results = VaidDiallerRetrieveRecords.updateDialEntries(new List<VaidDiallerRetrieveRecords.UpdateRequest>{request});
        Test.stopTest();

        System.assertEquals(1, results.size(), 'There should be one result');
        System.assertEquals(3, results[0].updatedCount, 'All records should be updated');
        System.assertEquals('Records updated successfully', results[0].message, 'Message should be "Records updated successfully"');

        List<VAID_Dial_Entry__c> updatedEntries = [SELECT Id FROM VAID_Dial_Entry__c WHERE VAID_Dial_Status__c = 'Retrieved'];
        System.assertEquals(3, updatedEntries.size(), 'All records should be updated');
    }

    @IsTest
    static void testUpdateDialEntriesNoRecords() {
        VAID_Dial_List__c dialList = new VAID_Dial_List__c();
        dialList.Name = 'Test Dial List';
        dialList.VAID_Agent_Queue_ID__c = '00GHz000003yUl7MAE';
        insert dialList;

        VaidDiallerRetrieveRecords.UpdateRequest request = new VaidDiallerRetrieveRecords.UpdateRequest();
        request.dialListId = dialList.Id;
        request.priorityFilterEnabled = false;
        request.priorityFilter = 'Normal';
        request.phoneNumberFilterEnabled = false;
        request.phoneNumberFilter = '1';
        request.recoveryTypeFilterEnabled = false;
        request.recoveryTypeFilter = 'DEFAULT';
        request.prioritisationSortField = 'VAID_Prioritization_Score__c';
        request.prioritisationSortOrder = 'DESC';

        Test.startTest();
        List<VaidDiallerRetrieveRecords.UpdateResult> results = VaidDiallerRetrieveRecords.updateDialEntries(new List<VaidDiallerRetrieveRecords.UpdateRequest>{request});
        Test.stopTest();

        System.assertEquals(1, results.size(), 'There should be one result');
        System.assertEquals(0, results[0].updatedCount, 'No records should be updated');
        System.assertEquals('No records found to update', results[0].message, 'Message should be "No records found to update"');
    }

    @IsTest
    static void testUpdateDialEntriesException() {
        VAID_Dial_List__c dialList = new VAID_Dial_List__c();
        dialList.Name = 'Test Dial List';
        dialList.VAID_Agent_Queue_ID__c = '00GHz000003yUl7MAE';
        insert dialList;

        VaidDiallerRetrieveRecords.UpdateRequest request = new VaidDiallerRetrieveRecords.UpdateRequest();
        request.dialListId = dialList.Id;
        request.priorityFilterEnabled = false;
        request.priorityFilter = 'Normal';
        request.phoneNumberFilterEnabled = false;
        request.phoneNumberFilter = '1';
        request.recoveryTypeFilterEnabled = false;
        request.recoveryTypeFilter = 'DEFAULT';
        request.prioritisationSortField = 'VAID_Prioritization_Score__c';
        request.prioritisationSortOrder = 'DESC';

        Test.startTest();
        List<VaidDiallerRetrieveRecords.UpdateResult> results = VaidDiallerRetrieveRecords.updateDialEntries(new List<VaidDiallerRetrieveRecords.UpdateRequest>{request});
        Test.stopTest();

        System.assertEquals(1, results.size(), 'There should be one result');
        System.assertEquals(0, results[0].updatedCount, 'No records should be updated');
    }
}
