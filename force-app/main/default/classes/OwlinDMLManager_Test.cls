@isTest
private class OwlinDMLManager_Test {

    private static Map<String, Map<string, List<String>>> accessCreateMap = new Map<String, Map<String, List<String>>> {

            'Account' => new Map<String, List<String>> {
                    'Create' => new List<String> {
                            'Owlin_Entity_Id__c', 'Owlin_Link_Requested__c', 'Name'
                    }
            }
    };
        
    private static Map<String, Map<string, List<String>>> accessDeleteMap = new Map<String, Map<String, List<String>>> {

            'Account' => new Map<String, List<String>> {
                    'Delete' => new List<String> {
                            'Owlin_Entity_Id__c', 'Owlin_Link_Requested__c', 'Name'
                    }
            }
    };
        
    private static Map<String, Map<string, List<String>>> accessUpdateMap = new Map<String, Map<String, List<String>>> {

            'Account' => new Map<String, List<String>> {
                    'Update' => new List<String> {
                            'Owlin_Entity_Id__c', 'Owlin_Link_Requested__c', 'Name'
                    }
            }
    };
        
    private static Map<String, Map<string, List<String>>> accessReadMap = new Map<String, Map<String, List<String>>> {

            'Account' => new Map<String, List<String>> {
                    'Read' => new List<String> {
                            'Owlin_Entity_Id__c', 'Owlin_Link_Requested__c', 'Name'
                    }
            }
    };

    @isTest
    static void checkValidCreateTest()
    {
        system.runAs(OwlinTestUtils.getOwlinStandardUser()) {
            test.startTest();
            Boolean hasAccess = OwlinDMLManager.checkAccess(accessCreateMap);
            test.stopTest();
            System.assertNotEquals(null, hasAccess);
            System.assertEquals(true, hasAccess);
        }
        
    }
    
    @isTest
    static void checkValidReadTest()
    {
        system.runAs(OwlinTestUtils.getOwlinStandardUser()) {
            test.startTest();
            Boolean hasAccess = OwlinDMLManager.checkAccess(accessReadMap);
            test.stopTest();
            System.assertNotEquals(null, hasAccess);
            System.assertEquals(true, hasAccess);
        }
        
    }
    
    @isTest
    static void checkValidDeleteTest()
    {
        system.runAs(OwlinTestUtils.getOwlinStandardUser()) {
            test.startTest();
            Boolean hasAccess = OwlinDMLManager.checkAccess(accessDeleteMap);
            test.stopTest();
            System.assertNotEquals(null, hasAccess);
            System.assertEquals(true, hasAccess);
        }
        
    }

 	@isTest
    static void checkValidUpdateTest()
    {
        system.runAs(OwlinTestUtils.getOwlinStandardUser()) {
            test.startTest();
            Boolean hasAccess = OwlinDMLManager.checkAccess(accessUpdateMap);
            test.stopTest();
            System.assertNotEquals(null, hasAccess);
            System.assertEquals(true, hasAccess);
        }
        
    }

}