/**
 * Created by anshulagrawal.
 * this class is responsible to check permission on a object and its field
 *
 */

public with sharing class OwlinDMLManager {

    public static Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

    public OwlinDMLManager() {

    }
    
    public static Boolean checkAccess(Map<String, Map<String, List<String>>> accessMapByObjectName) {
        Set<String> objectNameSet = accessMapByObjectName.keySet();

        for (String objectName : objectNameSet) {
            if (!checkAccess(accessMapByObjectName, objectName)) {
                return false;
            }
        }

        return true;
    }

    public static Boolean checkAccess(Map<String, Map<String, List<String>>> accessMapByObjectName, String objectName) {
        if (String.isBlank(objectName) || !accessMapByObjectName.containsKey(objectName)) {
            return false;
        }

        Map<String, List<String>> fieldNameListByAccess = accessMapByObjectName.get(objectName);
        Set<String> accessSet = fieldNameListByAccess.keySet();

        for (String access : accessSet) {
            List<String> fieldNameList = fieldNameListByAccess.get(access);

            if (access == 'Create') {
                checkCreate(objectName, fieldNameList);
            } else if (access == 'Read') {
                checkRead(objectName, fieldNameList);
            } else if (access == 'Update') {
                checkUpdate(objectName, fieldNameList);
            } else if (access == 'Delete') {
                checkDelete(objectName);
            } else {
                throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{access}));
            }
        }

        return true;
    }

    private static void checkCreate(String objectName, List<String> fieldNameList) {
        SObjectType mSObjectType = getSObjectTypeByObjectName(objectName);

        if (!mSObjectType.getDescribe().isCreateable()) {
            throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{'Create', objectName}));
        }

        for (String fieldName : fieldNameList) {
            Schema.SObjectField mSObjectField = getSObjectFieldByFieldNameAndSObjectType(fieldName, mSObjectType);

            if (!mSobjectField.getDescribe().isCreateable()) {
                throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{'Create', fieldName, objectName}));
            }
        }
    }

    private static void checkRead(String objectName, List<String> fieldNameList) {
        SObjectType mSObjectType = getSObjectTypeByObjectName(objectName);

        if (!mSObjectType.getDescribe().isAccessible()) {
            throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{'Read', objectName}));
        }

        for (String fieldName : fieldNameList) {
            Schema.SObjectField mSObjectField = getSObjectFieldByFieldNameAndSObjectType(fieldName, mSObjectType);

            if (!mSobjectField.getDescribe().isAccessible()) {
                throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{'Read', fieldName, objectName}));
            }
        }
    }

    private static void checkUpdate(String objectName, List<String> fieldNameList) {
        SObjectType mSObjectType = getSObjectTypeByObjectName(objectName);

        if (!mSObjectType.getDescribe().isUpdateable()) {
            throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{'Update', objectName}));
        }

        for (String fieldName : fieldNameList) {
            Schema.SObjectField mSObjectField = getSObjectFieldByFieldNameAndSObjectType(fieldName, mSObjectType);

            if (!mSobjectField.getDescribe().isUpdateable()) {
                throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{'Update', fieldName, objectName}));
            }
        }
    }

    private static void checkDelete(String objectName) {
        SObjectType mSObjectType = getSObjectTypeByObjectName(objectName);

        if (!mSObjectType.getDescribe().isDeletable()) {
            throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{'Delete', objectName}));
        }
    }

    private static SObjectType getSObjectTypeByObjectName(String objectName) {
        if (!globalDescribe.containsKey(objectName)) {
            throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{objectName}));
        }

        return globalDescribe.get(objectName);
    }

    private static SObjectField getSObjectFieldByFieldNameAndSObjectType(String fieldName, SObjectType mSObjectType) {
        Schema.DescribeSObjectResult mDescribeSObjectResult = mSObjectType.getDescribe();
        Map<String, Schema.SObjectField> mSObjectFieldByFieldName = mDescribeSObjectResult.fields.getMap();

        if (!mSObjectFieldByFieldName.containsKey(fieldName)) {
            throw new DmlException(String.format(Label.Owlin_Permission_Error, new List<String>{fieldName, mDescribeSObjectResult.getName()}));
        }

        return mSobjectFieldByFieldName.get(fieldName);
    }
}