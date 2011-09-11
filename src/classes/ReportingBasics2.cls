public class ReportingBasics2 {
	
	public ReportingBasics2(){
		getObjectDetails();
	}
	
	private Map<String, Schema.SObjectType> gd {
        get{
            if(gd == null) gd = Schema.getGlobalDescribe();
            return gd;
        }
        set;
    }
	 
	 public String SelectedObject {
        get{
            if (SelectedObject == null) {
            	List<String> tempList = new List<String> (gd.keySet());
            	tempList.sort();
            	SelectedObject = tempList[0];
            }	
            return SelectedObject;
        }
        set;
    }
	
	public List<SelectOption> getGlobalDescribeSelect(){
        List<string> gd_list = new List<string>(gd.keyset());
        gd_list.sort();
        List<SelectOption> options = new List<SelectOption>();    
        For(String s : gd_list){
            options.add(new SelectOption(s,s));
        }
            
        return options;
    }
    
    public void getObjectDetails(){
    	objDetails = new ObjectFieldWrapper(SelectedObject);
    }
    
    public String currentLookupField {
    	get;
    	set{
    		if (value == '' || value == null){
    			currentLookupField = '';
    		}else{
    			currentLookupField = value;
    		}
    	}
    }
    public Boolean showRelatedObjectFieldList {get;set;}
    public ObjectFieldWrapper currentLookupObject {get;set;}
    
    
    public void assignCurrentLookupField(){
    	currentLookupObject = objDetails.getFieldObject(currentLookupField).referenceObject;
    	objDetails.getFieldObject(currentLookupField).isReferenceFieldQueried = true;
    } 
    
    public ObjectFieldWrapper objDetails {get;set;}
    
    public void Query(){
    	results = Database.Query(objDetails.soqlQuery);
    	for(Sobject result : results){
    		//system.debug('======>Query Results : '+result.getSObjects('Contacts'));	
    	}	
    }
    
    
    private list<Sobject> results = new List<Sobject>();
    
       
}