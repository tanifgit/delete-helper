/// A supplement class to the <class>SampleUtil.DeleteHelper.OnDeleteSuper</class> class, 
/// to ease the addition of it to existing classes (particularity when there are many)
/// <br>
/// See the <method>AddDeleteHelper</method> method for further details
Class SampleUtil.DeleteHelper.AddHelper
{

/// Add the <class>SampleUtil.DeleteHelper.OnDeleteSuper</class> class as a Super class for the desired classes
/// <br><br>
/// Arguments:
/// <ul>
/// <li><b>performDryRun</b> - Whether to actually update the class definitions and compile them or just perform a dry run which would allow to show which classes would be changed. Default is 1 (true), e.g. perform only a dry run. For a real change set to 0 (false).</li>
/// <li><b>classesNumLimit</b> - How many classes to perform the login on (dry or not). This is useful if there are many classes, and you'd like to just test on a few. If set to -1 then there is no limit. The default is 0 (i.e. no classes at all)</li>
/// <li><b>classSpec</b> - The specification of class names to change. E.g. "MyPackage.MySub*.cls". The Spec may contain both * and ? as wildcards. It may also consist of more than one, comma-delimited selections. If you wish to exclude items then prefix the pattern with ' symbol.</li>
/// <li><b>makeRightInheritance</b> - Whether to change the inheritance to Right. The default is 0 (i.e. do not touch the Inheritance). (This is in order to pick up the Delete Helper's %OnDelete and not the left most class. This is relevant if the current inheritance is Left. See note below *)</li>
/// <li><b>removeExistingOnDelete</b> - Whether to remove an existing OnDelete method in the current class. The default is 0 (i.e. do not remove an existing %OnDelete)</li>
/// </ul>
/// <i>* Note regarding the Inheritance-direction-related argument:<br>
/// In some versions the implicit default was left, in some right, therefore in some upgrades an explicit 'Inheritance' keyword was added. In case it is left, then the %Persistent default %OnDelete will supercede the Delete Helper one</i>
/// <br><br>
/// Examples:<br>
/// <example>Set status = ##class(SampleUtil.DeleteHelper.AddHelper).AddDeleteHelper(1 /* Dry Run */, 10 /* Class Number Limit */,"Package.Sub.*.cls")</example>
/// This will perform a dry run of up to 10 classes in the 'Package.Sub' package, reporting the classes that would be changed in a real non-dry run (adding the Delete Helper to their Super class list)
/// <example>Set status = ##class(SampleUtil.DeleteHelper.AddHelper).AddDeleteHelper(0 /* Non-Dry Run */, 1 /* Only One Class */,"Package.Sub.*.cls")</example>
/// This will perform a non-dry run of up to 1 class in the 'Package.Sub' package, adding the Delete Helper to it's Super class list
/// <example>Set status = ##class(SampleUtil.DeleteHelper.AddHelper).AddDeleteHelper(0 /* Non-Dry Run */, -1 /* Unlimited Number of Classes */,"Package.Sub.*.cls")</example>
/// This will perform a non-dry run of an unlimited number of classes in the 'Package.Sub' package, adding the Delete Helper to their Super class list
/// <example>Set status = ##class(SampleUtil.DeleteHelper.AddHelper).AddDeleteHelper(0 /* Non-Dry Run */, -1 /* Unlimited Number of Classes */,"Package.Sub.*.cls", 1 /* Change Inheritance to Right*/, 1 /* Remove Existing %OnDelete */)</example>
/// This will perform a non-dry run of an unlimited number of classes in the 'Package.Sub' package, adding the Delete Helper to their Super class list, Changing the Inheritance to Right, and removing an %OnDelete method if it already exists in the class
/// <br><br>
/// Sample Output:<br>
/// <code>
/// 
/// ENSEMBLE>set status = ##class(SampleUtil.DeleteHelper.AddHelper).AddDeleteHelper(1,1,"ITest.Proxy.s0.*.cls")<br>
/// handling class: ITest.Proxy.s0.Address<br>
/// <br>
/// ENSEMBLE>set status = ##class(SampleUtil.DeleteHelper.AddHelper).AddDeleteHelper(1,-1,"ITest.Proxy.s0.*.cls")<br>
/// handling class: ITest.Proxy.s0.Address<br>
/// handling class: ITest.Proxy.s0.Employee<br>
/// handling class: ITest.Proxy.s0.Person<br>
/// handling class: ITest.Proxy.s0.PersonIdentification<br>
/// <br>
/// ENSEMBLE>set status = ##class(SampleUtil.DeleteHelper.AddHelper).AddDeleteHelper(0,-1,"ITest.Proxy.s0.*.cls")<br>
/// handling class: ITest.Proxy.s0.Address<br>
/// saved: 1<br>
/// <br>
/// Compilation started on 01/10/2017 13:24:54 with qualifiers 'ck'<br>
/// Compiling class ITest.Proxy.s0.Address<br>
/// Compiling table ITest_Proxy_s0.Address<br>
/// Compiling routine ITest.Proxy.s0.Address.1<br>
/// Compilation finished successfully in 0.172s.<br>
/// handling class: ITest.Proxy.s0.Employee<br>
/// saved: 1<br>
/// <br>
/// Compilation started on 01/10/2017 13:24:54 with qualifiers 'ck'<br>
/// Compiling 2 classes, using 2 worker jobs<br>
/// Compiling class ITest.Proxy.s0.Person<br>
/// Compiling class ITest.Proxy.s0.Employee<br>
/// Compiling table ITest_Proxy_s0.Person<br>
/// Compiling table ITest_Proxy_s0.Employee<br>
/// Compiling routine ITest.Proxy.s0.Person.1<br>
/// Compiling routine ITest.Proxy.s0.Employee.1<br>
/// Compilation finished successfully in 0.363s.<br>
/// handling class: ITest.Proxy.s0.Person<br>
/// saved: 1<br>
/// <br>
/// Compilation started on 01/10/2017 13:24:55 with qualifiers 'ck'<br>
/// Compiling class ITest.Proxy.s0.Person<br>
/// Compiling table ITest_Proxy_s0.Person<br>
/// Compiling routine ITest.Proxy.s0.Person.1<br>
/// Compilation finished successfully in 0.152s.<br>
/// handling class: ITest.Proxy.s0.PersonIdentification<br>
/// saved: 1<br>
/// <br>
/// Compilation started on 01/10/2017 13:24:55 with qualifiers 'ck'<br>
/// Compiling class ITest.Proxy.s0.PersonIdentification<br>
/// Compiling table ITest_Proxy_s0.PersonIdentification<br>
/// Compiling routine ITest.Proxy.s0.PersonIdentification.1<br>
/// Compilation finished successfully in 0.122s.<br>
/// <br>
/// </code>
ClassMethod AddDeleteHelper(performDryRun As %Boolean = 1, classesNumLimit As %Integer = 0, classSpec As %String = "", makeRightInheritance As %Boolean = 0, removeExistingOnDelete As %Boolean = 0)
{


	set statement = ##class(%SQL.Statement).%New()
 
	Set status = statement.%PrepareClassQuery("%Library.RoutineMgr","StudioOpenDialog")
 
	#dim result As %SQL.StatementResult
 
	set result=statement.%Execute(/* spec */ classSpec,/*dir */,/* order by*/,/* system files */0,
 								/* flat */1,/* NotStudio*/,/*Show Generated */ 0)
 
 
	// Counting in order to allow limiting the number of classes
	set count=0
 
	While result.%Next() {
	 
		// Getting the class name, removing the ".cls" extension at the end 
		Set className = $Piece(result.%Get("Name"),".",1,*-1)
            
		// The classes that interest us are only Persistent ones
		If $ClassMethod(className,"%IsA","%Persistent") {
			
			// Will ignore classes that are Business Hosts (i.e. Business Service, Business Process or Business Operation)
			//	As they do not require this handling
			If $ClassMethod(className,"%IsA","Ens.Host")||$ClassMethod(className,"%IsA","Ens.Rule.Definition") {
				Continue
			}
             
            // Increment the counter       
			Set count=count+1
			
			// Check if the classes number has been limited and if yes if we passed the limit, of so stop
			If (classesNumLimit'=-1)&&(count>classesNumLimit) {
		 		Quit
	 		}
	 		
	 		// Report we are working on a specific class. This is important for the "Dry Run"
			Write "handling class: ",className,!
            
            // Open the class definition
			Set classDef = ##class(%Dictionary.ClassDefinition).%OpenId(className)
            
            // Check we are not already extending the Delete Helper class
			If classDef.Super '[ "SampleUtil.DeleteHelper.OnDeleteSuper" {
	            
	            // Add the Delete Helper to the Super classes list    
				Set classDef.Super = classDef.Super _ ",SampleUtil.DeleteHelper.OnDeleteSuper"
				
				// Need also to make sure we add an include (%occErrors) 
				///	as the Delete Helper code accesses a macro with a status error ($$$LoadObjectNotFound)
				
				// Depending on whether there is already an Include we might or might not need to start with a comma
				If classDef.IncludeCode '= "" {
					Set BeginInc = ","             
           		} else {
					Set BeginInc = ""
             	}
             	// Add the %occErrors include 
                Set classDef.IncludeCode = classDef.IncludeCode _ BeginInc _ "%occErrors"
                 
                // See note in class reference. In some cases (if explicit inheritance was set to left, we'd need to change this right)
                // 	Can consider to change this from being user-parameter-driven to simply check if the inheritance is left 
                //		and if so change to right, or in any case just change to right without checking
                //		For now opted to have this depend on user input (as to minimize forced undesired "surprise" changes)
				If makeRightInheritance {
					Set classDef.Inheritance = "right"
				}
                
                // Assuming this was desired by the caller, if the class definition already includes an %OnDelete method 
                //	then it will take precedence over the Delete Helper inherited one. So this allows to remove the existing method
                If removeExistingOnDelete {
	                
	                // Loop over methods in the class
	             	For i=1:1:classDef.Methods.Count() {
	                         Set methodName = classDef.Methods.GetAt(i)
	                         // If it is an %OnDelete then remove it (and exit the loop)
	                         If methodName = "%OnDelete" {
	                               Do classDef.Methods.RemoveAt(i)
	                               Quit
	                        }
	             	   }
                }
                
             	// If this is not a Dry Run then go ahead and save (and compile) the class
                if 'performDryRun {   
                
                	// Save the class definition             
	                Set status = classDef.%Save()
	                                
	                write "saved: ",status,!
	                
	                // Compile the class
	                Do $system.OBJ.Compile(className,"ck")
                }
                                
			}	
		}
	}
	Quit $$$OK
}

}
