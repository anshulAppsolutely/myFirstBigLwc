@isTest
private class OwlinConfigSetupController_Test {
    
    private static testMethod void testFull() {
        Test.startTest();
        PageReference curPage = Page.OwlinConfigSetup;
        Test.setCurrentPage(curPage);
        OwlinConfigSetupController con = new OwlinConfigSetupController();
        //
        // Check initial situation
        System.assertEquals(0, con.configurations.size(), 'Expected zero config records');
        System.assertEquals(null, con.editingRow, 'Expected no row in edit mode');
        //
        // Create new row
        con.newConfig();
        System.assertNotEquals(null, con.editingRow, 'Expected edit mode');
        con.editingRow.Name = 'testOwlin';
        con.saveConfig();
        System.assertEquals(1, ApexPages.getMessages().size(), 'Expected error message, no primary');
        con.editingRow.Is_Primary__c = true;
        con.saveConfig();
        System.assertEquals(1, ApexPages.getMessages().size(), 'Expected error message, Required fields not filled');
        con.editingRow.Is_Primary__c = true;
        con.editingRow.Endpoint__c = 'test endpoint';
        con.editingRow.Email__c = 'test@test.com';
        con.editingRow.Password__c = 'test password';
        con.saveConfig();
        System.assertEquals(null, con.editingRow, 'Expected no record in edit mode anymore');
        System.assertEquals(1, con.configurations.size(), 'Expected 1 config record');
        //
        // Now edit the row
        curPage = Page.OwlinConfigSetup;
        curPage.getParameters().put('editId', con.configurations[0].Name);
        Test.setCurrentPage(curPage);
        con = new OwlinConfigSetupController();
        System.assertNotEquals(null, con.editingRow, 'Expected row in edit mode');
        System.assertEquals('testOwlin', con.editingRow.Name, 'Expected "testOwlin" in edit mode');
        // Clone now
        con.cloneConfig();
        System.assertEquals('testOwlin*',con.editingRow.Name, 'Expected "testOwlin*" as clone name');
        con.editingRow.Email__c = 'test2@test.com';
        con.editingRow.Password__c = 'test password2';
        con.saveConfig();
        System.assertEquals(2, con.configurations.size(), 'Expected 2 config records');
        //
        // Verify the * config is the new primary
        for(Configuration_Settings__c c : con.configurations) {
            if(c.Name == 'testOwlin*') {
                System.assertEquals(true, c.Is_Primary__c, 'Expected testOwlin* as primary');
            }
            if(c.Name == 'testOwlin') {
                System.assertEquals(false, c.Is_Primary__c, 'Expected testOwlin as non primary');
            }
        }
        
        //system.debug('error message 1'+ApexPages.getMessages());
        //
        // Now edit the clone
        curPage = Page.OwlinConfigSetup;
        curPage.getParameters().put('editId', 'testOwlin*');
        Test.setCurrentPage(curPage);
        con = new OwlinConfigSetupController();
        //
        // Delete should give error since it's deleting the primary
        con.deleteConfig();
        //system.debug('error message 2'+ApexPages.getMessages());
        System.assertEquals(2, ApexPages.getMessages().size(), 'Expected error message, deleting primary');
        con.cancelConfig();
        System.assertEquals(null, con.editingRow, 'Expected no row in edit mode anymore after cancel');
        //
        // Select the non primary conf
        curPage = Page.OwlinConfigSetup;
        curPage.getParameters().put('editId', 'testOwlin');
        Test.setCurrentPage(curPage);
        con = new OwlinConfigSetupController();
        //
        // Delete allowed now
        con.deleteConfig();
        System.assertEquals(null, con.editingRow, 'Expected no row in edit mode anymore after deleting');
        System.assertEquals(1, con.configurations.size(), 'Expected 1 config record again, after deletion');
        System.assertEquals('testOwlin*', con.configurations[0].Name, 'Expected only "testOwlin*" config record');
        System.assertEquals(true, con.configurations[0].Is_Primary__c, 'Expected "test*" config record to be primary');
        Test.stopTest();
    }
}