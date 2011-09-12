/*
Any stateless methods for the ObjectFieldWrapper class can be put here.

todos
: The soqlQuery method can be split into 2.  There is repition of logic of list<string>
*/
public  class ObjectFieldWrapperHelper {
	
	/* 
	Builds a proper soql query for any passed in ObjecFieldWrapper object.
	Gets all inner elements (fields, related object+fields and child objects+fields) for the base object.
	*/
	public static String soqlQuery (ObjectFieldWrapper baseObject){
			
    		List<String> baseSelectedFields = baseObject.getInnerSelectedFields();
    		Map<String, List<String>> childSelectedObjects =  baseObject.getChildObjectsAndInnerFields();
    		Boolean baseObjectSelected = false;
			Boolean firstFieldSelected = false;
			
			String soqlQuery = 'SELECT ';
    		for (String baseSelectedField : baseSelectedFields){
    			if (firstFieldSelected){
    				soqlQuery += ', ';
    			}else{
    				firstFieldSelected = true;
    			}
    			soqlQuery += ObjectFieldWrapperHelper.cleanString(baseSelectedField);
    			baseObjectSelected = true;
    		}
    		
    		Boolean childObjectSelected = false;
    		integer i = 0;
    		string childSoqlQueries = '';
    		for (String childSelectedObject : childSelectedObjects.keySet()){
				string innerSoqlQuery = '';
				if ((i == 0 && baseObjectSelected == true) || (i != 0)) innerSoqlQuery += ', ';
				innerSoqlQuery += '(SELECT ';
    			firstFieldSelected = false;
    			for (String childSelectedField : childSelectedObjects.get(childSelectedObject)){
	    			if (firstFieldSelected){
	    				innerSoqlQuery += ', ';
	    			}else{
	    				firstFieldSelected = true;
	    			}
	    			innerSoqlQuery += ObjectFieldWrapperHelper.cleanString(childSelectedField);
    			}
    			if (firstFieldSelected){
    				childSoqlQueries += innerSoqlQuery + ' FROM ' + ObjectFieldWrapperHelper.cleanString(childSelectedObject) + ')';
    				childObjectSelected = true;
    			}
    			i++;
    		}
    		
    		if (baseObjectSelected || childObjectSelected){
    			if(childObjectSelected)	soqlQuery += childSoqlQueries;
    			soqlQuery +=' FROM ' + baseObject.objectName;
    		}else{
    			soqlQuery = '';
    		}
    		return soqlQuery;
	}
	
	
	public static String cleanString(String s){
    	s = s.replace('[', '');
    	s = s.replace(']', '');
    	s = string.escapeSingleQuotes(s);
    	return s;
    }
}