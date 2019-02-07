/**
 * this class is used to generate wrapper to request callout
 */

public class OwlinAPITokenRequestWrapper {

    public String email;	//string
    public String password;	//string
    public String expire;	//30d


    public static OwlinAPITokenRequestWrapper parse(String json){
        return (OwlinAPITokenRequestWrapper) System.JSON.deserialize(json, OwlinAPITokenRequestWrapper.class);
    }

}