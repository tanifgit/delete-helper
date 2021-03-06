/// A class to help assist in "deep" deleting of an instance, including references to other persistent classes.
/// <br><br>
/// To use simply add as a Super Class in your persistent class<br>
/// The class defines a Generator %OnDelete method that will generate code for your class, 
/// deleting, if needed, references (inclduing collections) to other persistent classes<br>
/// <br>
/// See the <class>SampleUtil.DeleteHelper.AddHelper</class> class that can help in adding this class as a Super class to several classes
/// <br>
/// <br>
/// Here is an example of a class and what it's generated %OnDelete will look like -<br><br>
/// A snippet from the Class Definition:<br><br>
/// <code>
/// Property Name As %String(MAXLEN = "", XMLNAME = "Name") [ Required ];<br>
/// <br>
/// Property SSN As %String(MAXLEN = "", XMLNAME = "SSN") [ Required ];<br>
/// <br>
/// Property DOB As %Date(XMLNAME = "DOB");<br>
/// <br>
/// Property Home As ITest.Proxy.s0.Address(XMLNAME = "Home");<br>
/// <br>
/// Property Office As ITest.Proxy.s0.Address(XMLNAME = "Office");<br>
/// <br>
/// Property Spouse As ITest.Proxy.s0.Person(XMLNAME = "Spouse");<br>
/// </code><br>
/// And this is the generated %OnDelete (from the generated INT routine):<br>
/// <code>
/// <br> %OnDelete(oid) public {
/// <br> Set status = 1
/// <br> Set obj = ..%Open(oid,,.status)
/// <br> If ('status) {
/// <br> &emsp;Set errorCode = $System.Status.GetErrorCodes(status)
/// <br> &emsp;&emsp;If errorCode [ 5809 { 
/// <br> &emsp;&emsp;&emsp;Quit 1
/// <br> &emsp;&emsp;} Else {
/// <br> &emsp;&emsp;&emsp;Quit status
/// <br> &emsp;&emsp;}
/// <br> }
/// <br> If $IsObject(obj.Home) {
/// <br> &emsp;Set delStatus = obj.Home.%DeleteId(obj.Home.%Id())
/// <br> &emsp;&emsp;If ('delStatus) {
/// <br> &emsp;&emsp;&emsp;Set errorCode = $System.Status.GetErrorCodes(delStatus)
/// <br> &emsp;&emsp;&emsp;If errorCode [ 5810 { 
/// <br> &emsp;&emsp;} Else {
/// <br> &emsp;&emsp;&emsp;Set status=$select(+status:delStatus,1:$$AppendStatus^%occSystem(status,delStatus))
/// <br> &emsp;&emsp;}
/// <br> &emsp;}
/// <br> }
/// <br> If $IsObject(obj.Office) {
/// <br> &emsp;Set delStatus = obj.Office.%DeleteId(obj.Office.%Id())
/// <br> &emsp;If ('delStatus) {
/// <br> &emsp;&emsp;Set errorCode = $System.Status.GetErrorCodes(delStatus)
/// <br> &emsp;&emsp;If errorCode [ 5810 { 
/// <br> &emsp;&emsp;} Else {
/// <br> &emsp;&emsp;&emsp;Set status=$select(+status:delStatus,1:$$AppendStatus^%occSystem(status,delStatus))
/// <br> &emsp;&emsp;}
/// <br> &emsp;}
/// <br> }
/// <br> If $IsObject(obj.Spouse) {
/// <br> &emsp;Set delStatus = obj.Spouse.%DeleteId(obj.Spouse.%Id())
/// <br> &emsp;If ('delStatus) {
/// <br> &emsp;&emsp;Set errorCode = $System.Status.GetErrorCodes(delStatus)
/// <br> &emsp;&emsp;If errorCode [ 5810 { 
/// <br> &emsp;&emsp;} Else {
/// <br> &emsp;&emsp;&emsp;Set status=$select(+status:delStatus,1:$$AppendStatus^%occSystem(status,delStatus))
/// <br> &emsp;&emsp;}
/// <br> &emsp;}
/// <br> }
/// <br> Quit status }
/// </code>
/// <br><br>
/// Here is a sample with a list collection -<br>
/// <br>
/// The class definition snippet:<br>
/// <code>Property GetListByNameResult As list Of ITest.Proxy.s0.PersonIdentification;</code><br>
/// <br>
/// And the generated code snippet:<br>
/// <code>
/// <br> If $IsObject(obj.GetListByNameResult) {
/// <br>	&emsp;Set key=""
/// <br>	&emsp;Set item = obj.GetListByNameResult.GetNext(.key)
/// <br>	&emsp;While key'="" {
/// <br> &emsp;&emsp;If $IsObject(item) {
/// <br> &emsp;&emsp;&emsp;Set delStatus = item.%DeleteId(item.%Id())
/// <br> &emsp;&emsp;&emsp;If ('delStatus) {
/// <br> &emsp;&emsp;&emsp;&emsp;Set errorCode = $System.Status.GetErrorCodes(delStatus)
/// <br> &emsp;&emsp;&emsp;&emsp;If errorCode [ 5810 { 
/// <br> &emsp;&emsp;&emsp;&emsp;} Else {
/// <br> &emsp;&emsp;&emsp;&emsp;&emsp;Set status=$select(+status:delStatus,1:$$AppendStatus^%occSystem(status,delStatus))
/// <br> &emsp;&emsp;&emsp;&emsp;}
/// <br> &emsp;&emsp;&emsp;}
/// <br> &emsp;&emsp;}
/// <br> &emsp;Set item = obj.GetListByNameResult.GetNext(.key)
/// <br>	}
/// </code>
/// <br>
/// <br>
Class SampleUtil.DeleteHelper.OnDeleteSuper [ Abstract ]
{

/// This callback method is invoked by the <METHOD>%Delete</METHOD> method to 
/// provide notification that the object specified by <VAR>oid</VAR> is being deleted.
/// 
/// <P>If this method returns an error then the object will not be deleted.
/// <br>
/// This method was implemented as a generator method and creates the code according to the properties defined in the class
ClassMethod %OnDelete(oid As %ObjectIdentity) As %Status [ CodeMode = objectgenerator, Private, ServerOnly = 1 ]
{

	// a list ($ListBuild format) of "simple" (non-collection) property names we'll want to delete the references of (because they're Persistent)
	Set delPropNames = ""
                            
	// a list ($ListBuild format) of collection (List) property names we'll want to delete the references of (because they're Persistent)
	Set delCollectionPropNames = ""
                            
	// NOTE! - this sample might not cover all cases of references to be deleted 
	//	(perhaps for example a reference to a Serial class that has a reference to a Persistent one.
	///  Also the code uses the "Class Definition" as its source for the properties 
	///  and not the "Compiled Class" so inherited references will not be covered)
                            
	// Lists and non-lists or arrays need separate handling (since for lists we'll need to iterate its members)
                            
	// A flag whether we have any Persistent reference properties at all, default to 0/false
	Set hasDelProps = 0
	
	#dim prop As %Dictionary.PropertyDefinition
	
	// Loop over all properties in the class definition
	for i=1:1:%class.Properties.Count() {
                                            
		Set prop = %class.Properties.GetAt(i)
		// grab the property type
		set propType=prop.Type
                                            
		// grab the property name
		set propName = prop.Name
                                            
		// grab the "collection-ness" of the property
		set propCollection = prop.Collection
                                            
		// check if relationship
		If (prop.Relationship)&&(prop.Cardinality="many") {
			set propCollection="list"
		}
		// check if relationship and referencing One or Parent
		If (prop.Relationship)&&((prop.Cardinality="one")||(prop.Cardinality="parent")) {
			Continue
		}

                                            
		// if this is a property who's type starts with '%' (e.g. %String) simply iterate to the next property
		If $Extract(propType)="%" Continue
                                            
			
		If $ClassMethod(propType,"%IsA","%Persistent") { 
			// "Turn on" the flag that we'll be trying to delete some references in this method
			Set hasDelProps=1
                                                            
			// If this is a collection put the property name in the appropriate property list
			If (propCollection="list")||(propCollection="array") {
				Set delCollectionPropNames = delCollectionPropNames _ $ListBuild(propName)
                                                                            
                                                            
			// If it's not a list (but it's still Persistent) put it in the second
			} Else {
				Set delPropNames = delPropNames _ $ListBuild(propName)
			}
		}
                                            
	}
    Do %code.WriteLine(" Set status = $$$OK")                         
	// If the flag is on then we have references to delete
	If hasDelProps {
                            
		// Open the object so we can access it's properties
                               
		Do %code.WriteLine(" Set obj = ..%Open(oid,,.status)")
		Do %code.WriteLine(" If $$$ISERR(status) {")
		Do %code.WriteLine("	Set errorCode = $System.Status.GetErrorCodes(status)")
		
		// Maybe we simple already deleted this object (perhaps referenced from more than one object)
		//	If so ignore this error
		Do %code.WriteLine("	If errorCode [ $$$LoadObjectNotFound { ")
		Do %code.WriteLine("		Quit $$$OK")
		Do %code.WriteLine("	} Else {")
		Do %code.WriteLine("		Quit status")
		Do %code.WriteLine("	}")
		Do %code.WriteLine(" }")
                                                
		// Loop over the list of "simple" (non-list) properties
		for i=1:1:$ListLength(delPropNames) {
			// grab the property name from the list
			Set propName = $ListGet(delPropNames,i)
			// check it actually currently references a valid object
			Do %code.WriteLine(" If $IsObject(obj."_propName_") {")
			// Delete the object
			Do %code.WriteLine("	Set delStatus = obj."_propName_".%DeleteId(obj."_propName_".%Id())")
			Do %code.WriteLine("	If $$$ISERR(delStatus) {")
			Do %code.WriteLine("		Set errorCode = $System.Status.GetErrorCodes(delStatus)")
			// As when opening the oject, maybe we simple already deleted this object (perhaps referenced from more than one object)
			//	If so ignore this error
			Do %code.WriteLine("		If errorCode [ $$$DeleteObjectNotFound { ")
            	// In this case simply do nothing and continue to next prop
            	                                                    
			Do %code.WriteLine("		} Else {")
			// If this is a different error return it. 
			Do %code.WriteLine("			Set status=$$$ADDSC(status,delStatus)")
			Do %code.WriteLine("		}")
			Do %code.WriteLine("	}")
			Do %code.WriteLine(" }")
		}
                                                
		// Loop over the list of List collection properties
		for i=1:1:$ListLength(delCollectionPropNames) {
			Set propName = $ListGet(delCollectionPropNames,i)
			// if this list prop is indeed an object
			Do %code.WriteLine(" If $IsObject(obj."_propName_") {")
			// Loop over all members of the list
			Do %code.WriteLine("	Set key=""""")
			// grab the next reference (and key)
			Do %code.WriteLine("	Set item = obj."_propName_".GetNext(.key)")
			Do %code.WriteLine("	While key'="""" {")
                                                                
	                                                                
			Do %code.WriteLine("		If $IsObject(item) {")
			
			// delete it
			Do %code.WriteLine("			Set delStatus = item.%DeleteId(item.%Id())")
			Do %code.WriteLine("			If $$$ISERR(delStatus) {")
			Do %code.WriteLine("				Set errorCode = $System.Status.GetErrorCodes(delStatus)")
			// As when opening the oject, maybe we simple already deleted this object (perhaps referenced from more than one object)
			//	If so ignore this error
			Do %code.WriteLine("					If errorCode [ $$$DeleteObjectNotFound { ")
            											// In this case simply do nothing and continue to next prop
            	                                                    
			Do %code.WriteLine("					} Else {")
			// If this is a different error return it. 
			Do %code.WriteLine("						Set status=$$$ADDSC(status,delStatus)")
			Do %code.WriteLine("					}")
		
			Do %code.WriteLine("			}")
            Do %code.WriteLine("		}")
			Do %code.WriteLine("		Set item = obj."_propName_".GetNext(.key)")
			Do %code.WriteLine("	}")
			Do %code.WriteLine(" }")
		}
		
	}
	
	Do %code.WriteLine(" Quit status")
	
                
                
   Quit $$$OK
}

}
