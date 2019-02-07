public class OwlinAPITokenResponseWrapper {
    
    public String token;	
    
    public static OwlinAPITokenResponseWrapper parse(String json){
		return (OwlinAPITokenResponseWrapper) System.JSON.deserialize(json, OwlinAPITokenResponseWrapper.class);
	}
}