public class Report_Create_Controller{

Public String SelectedObject {get; set;}


Schema.SObjectType SelectedObjectType;
Transient Schema.DescribeSObjectResult SelectedObjectDescribe;

Map<String, Schema.SObjectType> gd;
Map<String, Schema.SObjectField> gfd;

Public List<String> SelectedFields {get; set;}

/*

1. Generate a list of the sObjects in your organization
    ***public getter provides them to the vforcepage
   
*/

public List<SelectOption> getGlobalDescribeSelect(){
    if(gd == null){
        gd = Schema.getGlobalDescribe();
    }
    
    List<string> gd_list = new List<string>(gd.keyset());
    List<SelectOption> options = new List<SelectOption>();
    For(String s : gd_list){
        options.add(new SelectOption(s,s));
    }
        
    return options;
}





/*

2. Determine the sObject you need to access
    ***VF page selection will be set from selection to variable
    
*/
public List<SelectOption> getFieldResultSelect(){
    List<SelectOption> options = new List<SelectOption>();
    
    if(SelectedObject != null && SelectedObject != ''){
        SelectedObjectType = gd.get(SelectedObject);
        SelectedObjectDescribe = SelectedObjectType.getDescribe();
        gfd = SelectedObjectDescribe.fields.getMap();
        for(String s:gfd.keyset()){
            options.add(new SelectOption(s,s));
        }
    }
    return options;
}



/*

3. Generate the describe result for the sObject
    ***Use object name from variable to grab describe from method
    
*/
    
/*

4. Generate a map of field tokens for the sObject (see Accessing All Field Describe Results for an sObject)
    ***Send these fields out in a public list
    
*/









}