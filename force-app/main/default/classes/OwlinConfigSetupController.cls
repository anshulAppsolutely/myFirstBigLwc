/**
 * Created by anshulagrawal.
 * this class is used to setup configuration for email, password & endpoint and update custom settings
 * configuration for Owlin
 */

public with sharing class OwlinConfigSetupController {

    //constructor to initialize and set up values
    public OwlinConfigSetupController() {
        //System.Debug('## CONSTRUCTOR: '+ApexPages.currentPage().getParameters());
        // When edit was clicked the page will do a full reload
        if (ApexPages.currentPage().getParameters().containsKey('editId')) {
            String configId = String.escapeSingleQuotes(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('editId'), 'UTF-8'));
            //system.debug('configid >>' + configId);
            this.editingRow = Configuration_Settings__c.getInstance(configid);
        }
    }

    /**
     * get all the existing configuration for the set up screens
     */
    public List<Configuration_Settings__c> configurations {
        get {
            if(configurations==null) {
                configurations = Configuration_Settings__c.getAll().values();
            }
            return configurations;
        }
        set;
    }

    /**
     * this variable contains record to modify or create
     */
    public Configuration_Settings__c editingRow {
        get; set;
    }

    /**
     * creates a new instance for new config and sets it for editing row
     *
     * @return
     */
    public PageReference newConfig() {
        try {
            Configuration_Settings__c newConf = (Configuration_Settings__c) Configuration_Settings__c.sObjectType.newSObject(null, true);
            // Brings user to the edit component
            newConf.Endpoint__c = Label.url_OwlinBackend;
            this.editingRow = newConf;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    /**
     * this is used to cancel and go back to config setup
     *
     * @return
     */
    public PageReference cancelConfig() {
        try{
            //
            // Brings user back to the list
            this.editingRow = null;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }

    /**  
     * this is used to save the already existing config or new config
     *
     * @return
     */
    public PageReference saveConfig() {
        Boolean isUpdatable = false;
        Schema.sObjectType objType = Schema.getGlobalDescribe().get('Configuration_Settings__c');
        Schema.DescribeSObjectResult objDesc = objType.getDescribe();
        if(objDesc.isUpdateable() && objDesc.isCreateable()) {
            isUpdatable = true;
        }
        try {
            if(editingRow.Is_Primary__c && isUpdatable) {
                upsert editingRow;
                unPrimaryExcept(editingRow);
            } else {
                List<Configuration_Settings__c> configurationList = [SELECT Id, Is_Primary__c FROM Configuration_Settings__c WHERE Is_Primary__c = true AND Id <>:editingRow.Id];
                if(configurationList == null || configurationList.size() == 0) {
                    // This is not allowed, a minimum of 1 primary record must be present.
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Error_PrimaryConfig);
                    ApexPages.addMessage(msg);
                    return null;
                } else if(isUpdatable) {
                    upsert editingRow;
                }
            }
            // Init rows
            this.configurations = null;
            // Brings user back to the list
            this.editingRow = null;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }

        return null;
    }

    /**
     * use to delete the existing configuration
     *
     * @return
     */
    public PageReference deleteConfig() {
        try {
            if(editingRow.Is_Primary__c) {
                List<Configuration_Settings__c> configurationList = [SELECT Id, Is_Primary__c FROM Configuration_Settings__c WHERE Is_Primary__c = true AND Id <>:editingRow.Id];
                if(configurationList == null || configurationList.size() == 0) {
                    // This is not allowed, a minimum of 1 primary record must be present.
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Error_PrimaryConfigDelete);
                    ApexPages.addMessage(msg);
                    return null;
                } else {
                    delete editingRow;
                }
            } else {
                delete editingRow;
            }
            // Init rows
            this.configurations = null;
            // Brings user back to the list
            this.editingRow = null;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }

        return null;
    }

    /**
     * use to clone a existing configuration
     *
     * @return
     */
    public PageReference cloneConfig() {
        try {
            Configuration_Settings__c newConf = this.editingRow.clone(false);
            newConf.Name = newConf.Name+'*';
            // Init rows
            this.configurations = null;
            // Brings user to the clone
            this.editingRow = newConf;
        }
        catch (Exception e) {
            ApexPages.addMessages(e);
        }

        return null;
    }

    /**
     * Sets primary flag to false for all except the param
     *
     * @param conf
     */
    private void unPrimaryExcept(Configuration_Settings__c conf) {
        List<Configuration_Settings__c> otherConfs = [SELECT Id, Is_Primary__c FROM Configuration_Settings__c WHERE Id <> :conf.Id];
        for(Configuration_Settings__c unPrimaryConf : otherConfs) {
            unPrimaryConf.Is_Primary__c = false;
        }
        update otherConfs;
    }

}