public class ReportingBasics{

Public String SelectedObject {get; set;}


Map<String, Schema.SObjectType> gd;


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



/*

3. Generate the describe result for the sObject
    ***Use object name from variable to grab describe from method
    
*/
    
/*

4. Generate a map of field tokens for the sObject (see Accessing All Field Describe Results for an sObject)
    ***Send these fields out in a public list
    
*/









}