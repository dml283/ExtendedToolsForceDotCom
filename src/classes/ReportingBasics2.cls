/*
todo
: review switchCurrentLookupObject().  There has got to be a better way of switching and marking a field as accessible for query.  Maybe the objectfieldwrapper object needs to get smarter.
*/
public class ReportingBasics2 {
	
	public String currentLookupField {get;set;}
	public String currentChildObject {get;set;}
	public List<String> fieldNavigationList {
		get{
			if (fieldNavigationList == null){
				fieldNavigationList = new List<String>();
				fieldNavigationList.add('(' + objDetails.objectName + ')');
			} 
			return fieldNavigationList;
		}
		private set;
	}
	
	private Map<String, Schema.SObjectType> gd {
        get{
            if(gd == null) gd = Schema.getGlobalDescribe();
            return gd;
        }
        set;
    }
	 
	 public String selectedObject {
        get{
            if (selectedObject == null) {
            	List<String> tempList = new List<String> (gd.keySet());
            	tempList.sort();
            	selectedObject = tempList[0];
            }	
            return selectedObject;
        }
        set{
        	if (value == '' || value == null){
    			selectedObject = '';
    		}else if(value <> selectedObject) {
    			selectedObject = value;
    			objDetails = new ObjectFieldWrapper(selectedObject);
    			currentLookupObject = objDetails;
    			fieldNavigationList = null;
    		}
        }
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
   
    public void switchCurrentLookupObjectByField(){
    	//For the lookup field for the new current object, flag it as been accessed for query.  
    	currentLookupObject.getFieldObject(currentLookupField).isReferenceFieldQueried = true;
    	// Now switch the currentobject to the reference field's object
    	currentLookupObject = currentLookupObject.getFieldObject(currentLookupField).referenceObject;
    	fieldNavigationList.add( currentLookupField  + ' (' + currentLookupObject.objectName + ')'); 
    }
    
    public void switchCurrentLookupObjectByChildObject(){
    	//For the lookup field for the new current object, flag it as been accessed for query.  
    	objDetails.getChildObject(currentChildObject).selected = true;
    	// Now switch the currentobject to the reference field's object
    	currentLookupObject = objDetails.getChildObject(currentChildObject);
    	fieldNavigationList.add(currentLookupObject.childRelationshipName  + ' (' + currentLookupObject.objectName + ')'); 	
    }
    
    /*
    private void switchCurrentLookupObject(ObjectFieldWrapper targetObject, string switchInitiator){
    	currentLookupObject = targetObject;
    	fieldNavigationList.add(currentLookupObject.objectName + ' (' + switchInitiator + ')');
    }
    */

    public ObjectFieldWrapper currentLookupObject {
    	get{
    		if (currentLookupObject == null) currentLookupObject = objDetails;
    		return currentLookupObject;
    	}
    	set;
    }
    
   
    public ObjectFieldWrapper objDetails {
    	get{
    		if (objDetails == null) objDetails = new ObjectFieldWrapper(selectedObject); 
    		return objDetails;
    	}
    	set;
    }
    
    public String soqlQuery {get{return ObjectFieldWrapperHelper.soqlQuery(objDetails);}}
    
    public void Query(){
    	results = Database.Query(soqlQuery);
    	for(Sobject result : results){
    		//system.debug('======>Query Results : '+result.getSObjects('Contacts'));	
    	}	
    }
     
    private list<Sobject> results = new List<Sobject>();
        
}