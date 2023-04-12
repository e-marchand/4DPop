property file : 4D:C1709.File
property data; _factory : Object

Class constructor($module : Text)
	
	This:C1470.version:=Num:C11(Substring:C12(Application version:C493; 1; 2))
	This:C1470._factory:=New object:C1471
	This:C1470.module:=$module || Null:C1517
	This:C1470.file:=This:C1470._getFile()
	This:C1470.data:=JSON Parse:C1218(This:C1470.file.getText())
	
	If (This:C1470.module=Null:C1517)
		
		// Default for 4DPop
		This:C1470._factory.skin:="default"
		This:C1470._factory.auto_hide:=True:C214
		This:C1470._factory.palette:=New object:C1471(\
			"left"; 0; \
			"bottom"; Screen height:C188)
		
	End if 
	// === === === === === === === === === === === === === === === === === === === === === === === ===
Function get($key : Text) : Variant
	
	return This:C1470.module#Null:C1517\
		 ? This:C1470.data[This:C1470.module][$key]\
		 : This:C1470.data[$key]
	
	// === === === === === === === === === === === === === === === === === === === === === === === ===
Function set($key : Text; $value) : cs:C1710.Preferences
	
	If (This:C1470.module#Null:C1517)
		
		This:C1470.data[This:C1470.module][$key]:=$value
		
	Else 
		
		This:C1470.data[$key]:=$value
		
	End if 
	
	This:C1470.save()
	
	return This:C1470
	
	// === === === === === === === === === === === === === === === === === === === === === === === ===
Function default($default : Object)
	
	var $key : Text
	
	This:C1470._factory:=New object:C1471
	
	For each ($key; $default)
		
		This:C1470._factory[$key]:=$default[$key]
		
	End for each 
	
	// === === === === === === === === === === === === === === === === === === === === === === === ===
Function save()
	
	This:C1470.file.setText(JSON Stringify:C1217(This:C1470.data; *))
	
	// MARK:-
	// *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
Function _getFile() : 4D:C1709.File
	
	var $child; $key; $name; $node : Text
	var $i; $version : Integer
	var $attributes; $data : Object
	var $file; $previous : 4D:C1709.File
	var $xml : cs:C1710.xml
	
	// Get the path of current 4DPop preference's file
	$file:=Folder:C1567(fk user preferences folder:K87:10).file("4dPop v"+String:C10(This:C1470.version)+" preferences.json")
	
	If (Not:C34($file.exists))
		
		// Try it with the older xml format
		$previous:=Folder:C1567(fk user preferences folder:K87:10).file("4dPop v"+String:C10(This:C1470.version)+" preference.xml")
		
		If (Not:C34($previous.exists))
			
			// The file does not exist: an earlier version may be available
			$version:=This:C1470.version
			
			Repeat 
				
				$version-=1
				$previous:=Folder:C1567(fk user preferences folder:K87:10).file("4dPop v"+String:C10($version)+" preference.xml")
				
				If ($previous.exists)
					
					break
					
				End if 
				
			Until ($version=11)  // The first version
		End if 
		
		$data:=New object:C1471
		
		If ($previous.exists)
			
			// MARK:Convert to json
			$xml:=cs:C1710.xml.new($previous)
			
			If ($xml.success)
				
				For each ($child; $xml.childrens())
					
					$name:=$xml.getName($child)
					
					Case of 
							
							//______________________________________________________
						: ($xml.childrens($child).length=0)  // 4DPop
							
							$attributes:=$xml.getAttributes($child)
							
							If ($attributes.name#Null:C1517 || $attributes.value#Null:C1517)
								
								$data[Lowercase:C14($name)]:=$attributes.name || $attributes.value
								
							Else 
								
								$data[Lowercase:C14($name)]:=$attributes
								
							End if 
							
							//______________________________________________________
						: ($name="PopWindows")  // 4DPop Windows
							
							$data[$name]:=New object:C1471
							
							For each ($node; $xml.childrens($child))
								
								$key:=$xml.getName($node)
								
								Case of 
										
										//________________________________
									: ($key="options")\
										 | ($key="default")
										
										$data[$name][$key]:=$xml.getAttribute($node; "value")
										
										//________________________________
									: ($key="w.palette.mini")
										
										$data[$name].paletteMini:=$xml.getAttribute($node; "value")
										
										//________________________________
									: ($key="w.palette")
										
										$data[$name].palette:=$xml.getAttributes($node)
										
										//________________________________
								End case 
							End for each 
							
							//______________________________________________________
						: ($name="Commands")  // 4DPop Commands
							
							$data[$name]:=New object:C1471(\
								"language"; $xml.getAttributes($xml.childrens($child)[0]).value)
							
							//______________________________________________________
						: ($name="Color_Chart")  // 4DPop Color Chart
							
							$data[$name]:=New object:C1471
							
							For each ($node; $xml.childrens($child))
								
								$key:=$xml.getName($node)
								
								Case of 
										
										//________________________________
									: ($key="decimalFormat")
										
										$data[$name][$key]:=$xml.getAttribute($node; "value")
										
										//________________________________
									: ($key="colors")
										
										$data[$name][$key]:=New collection:C1472
										
										$node:=$xml.firstChild($node)
										
										For ($i; 1; 16; 1)
											
											$data[$name][$key].push($xml.getAttribute($node; "value"))
											$node:=$xml.nextSibling($node)
											
										End for 
										
										//________________________________
									: ($key="samplenames")
										
										$data[$name][$key]:=New collection:C1472
										
										$node:=$xml.firstChild($node)
										
										For ($i; 1; 8; 1)
											
											$data[$name][$key].push($xml.getAttribute($node; "name"))
											$node:=$xml.nextSibling($node)
											
										End for 
										
										//________________________________
								End case 
							End for each 
							
							//______________________________________________________
						Else 
							
							//––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
							ASSERT:C1129(False:C215; "\"Case of\" statement should never omit \"Else\"")
							
							//______________________________________________________
					End case 
				End for each 
				
			End if 
			
			$xml.close()
			
		End if 
		
		$file.setText(JSON Stringify:C1217($data; *))
		
	End if 
	
	return $file
	