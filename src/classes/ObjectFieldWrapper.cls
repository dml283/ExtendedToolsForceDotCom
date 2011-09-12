/*
Represents schema info for any object, field, the fields related objects.
1. 0-n fields for the base object.
2. 0-n child objects for the base object
3. 0-n fields for the child objects

Trying to lazy load as much as possible. 

TODOs
:  Make field aware if it can be queried and or filtered.  Include special excpetions like : for field in innerjoin child query, cannot query binary fields (e.g body of attachment object)
:  Review approach for building soql query where the external function has to determine the relationship path for the field.  Should the field object have this already
i.e AccountId.Name  for the account name field when accessed from contact as base.  Currently, it just provides its name: Name. 
:  In inner field class, handle reference object for multiple objects i.e whatID.
:  Map and build custom exceptions
:  double check that objectname is valid.  Throw custom exception if not.
:  If this is the approach, write tests methods right away
*/

public class ObjectFieldWrapper {
	public string objectName {get;set;}
	public string childRelationshipName {get;set;}
	public Boolean selected {get;set;}
	private static final String parseFlag = 'SPLITOBJECTNAMEFROMOBJECTCHILDNAME'; // :((

	public ObjectFieldWrapper(String objectName){
	   
		this.objectName = objectName;
		this.selected = false;
	}
	
	public ObjectFieldWrapper(String objectName, String childRelationshipName){
	   //todo:  double check that objectname is valid.  Throw custom exception if not.
		this(objectName);
		this.childRelationshipName = childRelationshipName;
	}
	
	private Schema.SObjectType objectToken { 
		get{
			if (objectToken == null) objectToken = Schema.getGlobalDescribe().get(objectName);
			return objectToken;
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
		
	public Map<String, List<String>> getChildObjectsAndInnerFields(){
		Map<String, List<String>> childObjectNames = new Map<String, List<String>>();
		for (ObjectFieldWrapper childObject : childObjects){
			if(childObject.selected){
				List<String> innerFields = childObject.getInnerSelectedFields();
				if(!innerFields.isEmpty()){
					childObjectNames.put(childObject.childRelationshipName, innerFields);
					system.debug('===>ChildRName:'+ childObject.childRelationshipName);
					system.debug('===>innerfields:'+ innerFields);
				}
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
		private set;
	}
	
	public Field getFieldObject(String fieldName){
		Field tmp; 
		for (Field f : fields){
			if(f.fieldName == fieldName){
				tmp = f;
				break;
			}
		}
		return tmp;
	}
	
	public ObjectFieldWrapper getChildObject(String childObjectName){
		ObjectFieldWrapper tmp; 
		for (ObjectFieldWrapper childObject : childObjects){
			if(childObject.objectName == childObjectName){
				tmp = childObject;
				break;
			}
		}
		return tmp;
	}
	
	public Integer fieldsQueried {
			get{
				fieldsQueried = 0;
				for (Field f : fields){
					if (f.selected) fieldsQueried += 1;
					fieldsQueried += f.referenceFieldsQueried;
				}
				return fieldsQueried;
			}
			set;
	} 
		
	// All the childobjects for this object
	public List<ObjectFieldWrapper> childObjects {
		get{
			if (childObjects == null){
				childObjects = new List<ObjectFieldWrapper>();
				List<String> childObjectNames = new List<String>();
				for(Schema.ChildRelationship cr : objectToken.getDescribe().getChildRelationships()){
	            	String oName = cr.getChildSObject().getDescribe().getName();
	            	String rName = cr.getRelationshipName();
	            	if(rName != null && rName != '' && oName != null && oName != ''){childObjectNames.add(oName+parseFlag+rName);}
				}
				childObjectNames.sort();
				for(String childObjectName : childObjectNames){
					String oName = childObjectName.split(parseFlag)[0];
	            	String rName = childObjectName.split(parseFlag)[1];
					childObjects.add(new ObjectFieldWrapper(oName, rName));
				}	
            }
            return childObjects;
		}
		private set;
	}
			
	// Inner class to wrap fields for object
	public class Field{
		private Schema.SObjectField fieldToken {get; private set;}
		public Boolean isReferenceFieldQueried {get; set;}
		public string fieldName	{get{return fieldToken.getDescribe().getName();}}
		public Boolean selected {get; set;}
		
		public Field(Schema.SObjectField fieldToken){
			this.fieldToken = fieldToken;
			selected = false;
			isReferenceFieldQueried = false;
			referenceFieldsQueried = 0;
		}
		
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
		
		public Boolean isReferenceObjectQuerable {
			get{
				if (isReferenceField && (referenceFieldName != '')){
					isReferenceObjectQuerable = true;
				}else{
					isReferenceObjectQuerable = false;
				}
				return isReferenceObjectQuerable;
			}
			private set;
		}
		
		public Boolean isReferenceField {
			get{
				if(fieldType == 'Reference'){
					return True;
				}else{
					return False;
				}
			}
		}
	
		public String fieldType {
			get{
				if (fieldType == null){ 
					string ft = fieldToken.getDescribe().getType().name();
					if(ft == null || ft == ''){
						fieldType = '';
					}else{
						fieldType = ft;
					}
				}
				return fieldType;	
			}
			private set;
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
			private set;
		}
		
		public String referenceFieldName {
			get{
				if (referenceFieldName == null){
					string rf = fieldToken.getDescribe().getRelationshipName();
					if (rf == null || rf == ''){
						referenceFieldName = '';	
					}else{
						referenceFieldName = rf;
					}
				}
				return referenceFieldName;
			}
			private set;
		}
		
		public ObjectFieldWrapper referenceObject{
			get{
				if(referenceObject == null) referenceObject = new ObjectFieldWrapper(referenceObjectName);
				return referenceObject;
			}
			private set;
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
	
	public class Filter{}	
}