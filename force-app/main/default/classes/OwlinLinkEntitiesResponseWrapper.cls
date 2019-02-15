/**
 * this class is used to handle response generated after linking entities to owlin
 */


public class OwlinLinkEntitiesResponseWrapper {

    public matches[] matches;
    public Integer base_filter_library_size;	//2801

    public class matches {
        public Integer score;	//18
        public String title;	//Vodafone India Ltd
        public String filter_id;	//acfb5d84-d838-447a-938d-58480bc1c54d
        public String original_id;	//0019E00000uB55lQAC
    }
    public static OwlinLinkEntitiesResponseWrapper parse(String json){
        return (OwlinLinkEntitiesResponseWrapper) System.JSON.deserialize(json, OwlinLinkEntitiesResponseWrapper.class);
    }

}