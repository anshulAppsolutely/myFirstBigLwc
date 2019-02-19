/**
 * Created by anshul on 18/02/2019.
 * Class containing utility methods for testing
 */

@isTest
public class OwlinTestUtils {

    private static final Integer SIZE = 900000000;

    private static Map<String, User> usersByProfileName = new Map<String, User>();

    private static Map<String, Id> permissionSetIdsByName = new Map<String, Id>();

    private static User owlinAdminUser {
        get {
            if (owlinAdminUser == null) {
                owlinAdminUser = createUniqueUser('System Administrator');
                System.runAs(getSystemAdminUser()) {
                    insert owlinAdminUser;
                }
            }
            return owlinAdminUser;
        }
        set;
    }

    /**
     * Helper method to create a user (not insert it!) with the given profilename.
     *
     * @param profileName
     *
     * @return new User object
     */
    private static User createUser(String profileName) {
        User u = usersByProfileName.get(profileName);
        if (u == null) {
            System.runAs(getSystemAdminUserNotInserted()) {
            u = createUniqueUser(profileName);
            usersByProfileName.put(profileName, u);
                insert u;
            }
        }
        return u;
    }

    private static User createUniqueUser(String profileName) {
        Double d = math.random() * SIZE;
        Integer randomInt = d.intValue();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='appsolutely' + randomInt + '@appsolutely.nl');
        return u;
    }

    /**
     * Assigns a permission set with the given name to the user. In Testvisible context so this is not used outside of test context
     *
     * @param user
     * @param permissionSetName
     */
    private static void giveUserPermissionSet(String permissionSetName, User u) {
        Id permissionSetId = permissionSetIdsByName.get(permissionSetName);
        if (permissionSetId == null) {
            PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName LIMIT 1];
            permissionSetIdsByName.put(permissionSetName, permissionSet.Id);
            permissionSetId = permissionSet.Id;
        }
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permissionSetId);
        System.debug(permissionSetAssignment);
        insert permissionSetAssignment;
    }

    /**
     * Creates a user with the Standard profile
     *
     * @return
     */
    public static User getOwlinStandardUser() {
        return createUser('Standard User');
    }

    public static User getSystemAdminUser() {
        return createUser('System Administrator');
    }

    public static User getOwlinAdminUser() {
        return owlinAdminUser;
    }

    private static User getSystemAdminUserNotInserted() {
        return createUniqueUser('System Administrator');
    }

}