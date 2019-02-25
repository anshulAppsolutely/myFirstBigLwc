/**
 * this class is used to generate wrapper to request callout to link entities to owlin
 */

public class OwlinLinkEntitiesRequestWrapper {

    public entities[] entities;
    public class entities {
        public String id;	//string
        public String name;	//string
        public String domain;	//string
    }
    public static OwlinLinkEntitiesRequestWrapper parse(String json){
        return (OwlinLinkEntitiesRequestWrapper) System.JSON.deserialize(json, OwlinLinkEntitiesRequestWrapper.class);
    }

}