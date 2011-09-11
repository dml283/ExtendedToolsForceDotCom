/*
Any stateless methods for the ObjectFieldWrapper class can be put here.
*/
public  class ObjectFieldWrapperHelper {
	public static String cleanString(String s){
    	s = s.replace('[', '');
    	s = s.replace(']', '');
    	s = string.escapeSingleQuotes(s);
    	return s;
    }
}