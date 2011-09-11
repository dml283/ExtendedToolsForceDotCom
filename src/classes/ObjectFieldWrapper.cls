/*
Represents metadata for any object.
1. 0-n fields for the base object.
2. 0-n child objects for the base object
3. 0-n fields for the child objects

Trying to lazy load as much as possible. 

TODOs
:  In inner field class, handle reference object for multiple objects i.e whatID.
*/

public class ObjectFieldWrapper {
	public string objectName {get;set;}
	public Boolean selected {get;set;}

	public ObjectFieldWrapper(String objectName){
	   //todo:  double check that objectname is valid.  Throw custom exception if not.
		this.objectName = objectName;
		this.selected = false;
	}
	
	private Schema.SObjectType objectToken { 
		get{
			if (objectToken == null) objectToken = Schema.getGlobalDescribe().get(objectName);
			return objectToken;
		}
		set;
	}
	
	// Build the soql query based on all child members of this object
	public String soqlQuery {
		get{
			soqlQuery = 'Select ';
    		List<String> baseSelectedFields = getInnerSelectedFields();
    		List<String> childSelectedObjects =  getChildObjectsAndInnerFields();
    		Boolean baseObjectSelected = false;
			Boolean firstFieldSelected = false;
			
    		for (String baseSelectedField : baseSelectedFields){
    			if (firstFieldSelected){
    				soqlQuery += ', ';
    			}else{
    				firstFieldSelected = true;
    			}
    			soqlQuery += ObjectFieldWrapperHelper.cleanString(baseSelectedField);
    			baseObjectSelected = True;
    		}
    		
    		for (Integer i = 0 ; i < childSelectedObjects.size(); i++){
				if ((i == 0 && baseObjectSelected == True) || (i != 0)) soqlQuery += ', ';
    			soqlQuery += '(SELECT id FROM ' + ObjectFieldWrapperHelper.cleanString(childSelectedObjects[i]) + ')';
    		}
    		soqlQuery += ' FROM ' + objectName;
    		return soqlQuery;
		}
		set;
	}
	
	public List<String> getInnerSelectedFields(){
			List<String> innerFieldNames = new list<String>();
			for (Field innerField : fields){
				if(innerField.selected){
					innerfieldNames.add(innerField.fieldName);
				}
				if(innerField.isReferenceField && innerField.isReferenceFieldQueried){
					for (String innerfieldRelatedField : innerField.getRelatedSelectedFields()){
						innerFieldNames.add(innerfieldRelatedField);
					}
				}
			}
			return innerFieldNames;
		}
		
	public List<String> getChildObjectsAndInnerFields(){
		List<String> childObjectNames = new list<String>();
		for (ObjectFieldWrapper childObject : childObjects){
			if(childObject.selected){
				childObjectNames.add(childObject.objectName);
			}
		}
		return childObjectNames;
	}
		
	//  All the fields for this object
	public List<Field> fields {
		get{
			if (fields == null){
				Map<String, Schema.SObjectField> fieldsSchema = objectToken.getDescribe().fields.getMap();
				List<String> fieldNames = new List<String>(fieldsSchema.keySet());
				fieldNames.sort();
				fields = new List<Field>();
				for (String fieldName : fieldNames){
					fields.add(new Field(fieldsSchema.get(fieldName)));
				}
			}
			return fields;
		}
		set;
	}
	
	public Field getFieldObject(String fieldName){
		Field tmp; 
		for (Field f : Fields){
			if(f.fieldName == fieldName){
				tmp = f;
				break;
			}
		}
		return tmp;
	} 
		
	// All the childobjects for this object
	public List<ObjectFieldWrapper> childObjects {
		get{
			if (childObjects == null){
				childObjects = new List<ObjectFieldWrapper>();
				List<String> childObjectNames = new List<String>();
				for(Schema.ChildRelationship cr : objectToken.getDescribe().getChildRelationships()){
	            	String rName = cr.getRelationshipName();
	            	if(rName != null ){childObjectNames.add(rName);}
				}
				childObjectNames.sort();
				for(String childObjectName : childObjectNames){
					childObjects.add(new ObjectFieldWrapper(childObjectName));
				}	
            }
            return childObjects;
		}
		set;
	}
			
	// Inner class to wrap fields for object
	public class Field{
		private Schema.SObjectField fieldToken {get;set;}
		public Boolean isReferenceFieldQueried {get;set;}
		public string fieldName	{get{return fieldToken.getDescribe().getName();}}
		
		public Integer referenceFieldsQueried {
			get{
				referenceFieldsQueried = 0;
				if(isReferenceField && isReferenceFieldQueried){
					for (Field f : referenceObject.fields){
						if (f.selected) referenceFieldsQueried += 1;
						referenceFieldsQueried += f.referenceFieldsQueried;
					}
				}
				return referenceFieldsQueried;
			}
			set;
		}
			
		public Boolean selected {
			get;
			set{
				// Need to turn of the selection of all other inner fields if this is selected
				if((selected == true) && (value == false)){
					if(isReferenceField){
						for(Field f : referenceObject.fields){
							f.selected = false;
						}
					}
				}
				selected = value;
			}
		}
		
		
		public Field(Schema.SObjectField fieldToken){
			this.fieldToken = fieldToken;
			selected = false;
			isReferenceFieldQueried = false;
			referenceFieldsQueried = 0;
		}
		
		
		public Boolean isReferenceField {
			get{
				if(fieldToken.getDescribe().getType().Name() == 'Reference'){
					return True;
				}else{
					return False;
				}
			}
		}
		
		public String referenceObjectName {
			get{
				if (isReferenceField ){
					referenceObjectName = fieldToken.getDescribe().getReferenceTo()[0].getDescribe().getName();
				}else{
					referenceObjectName = null;
				}
				return referenceObjectName;
			}
			set;
		}
		
		public String referenceFieldName {
			get{
				if (isReferenceField ){
					referenceFieldName = fieldToken.getDescribe().getRelationshipName();
				}else{
					referenceFieldName = null;
				}
				return referenceFieldName;
			}
			set;
		}
		
		public ObjectFieldWrapper referenceObject{
			get{
				if(referenceObject == null){referenceObject = new ObjectFieldWrapper(referenceObjectName);}
				return referenceObject;
			}
			set;
		}
		
		public List<String> getRelatedSelectedFields(){
			List<String> relatedFieldNames = new list<String>();
			if(isReferenceField && isReferenceFieldQueried){
				for (String relatedFieldName : referenceObject.getInnerSelectedFields()){
					relatedFieldNames.add(referenceFieldName + '.' + relatedFieldName);
				}
			}
			return relatedFieldNames;
		}
	}	
}