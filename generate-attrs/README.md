## **generate-attrs**

Optimised for ```.xhtml```-Files, this scipt is a powerful tool to generate missing attributes on a flexible set of tags. With a given pattern for the attribute to be added, it is possible to transform ```<h:inputText ... />``` to ```<h:inputText id="generated_id_42_" ... />``` or even ```<h:commandButton ... />``` to ```<h:commandButton action="#{foo.bar()}" />``` for a single file, some directories or complete projects. It is meant to generate those attributes by a default value and then use this to iterate (with your IDE) through the project and fill in meaningful values. E.g.: when you add IDs on your tags with a common pattern like "generated_id_42_" you can search your project for "generated_id_*_" and get all tags that need the specified attribute in return.

### **Arguments**

* **```-Path```**: Specifies either a single file or a directory (if the path is directory, you can toggle ```-Recurse```).
* **```-Recurse```**: See above.
* **```-Attribute```**: The attribute to be searched for (e.g. ```"id"``` or ```"name"```).
* **```-Components```**: A list of components, that should specify the given attribute (e.g. ```"h:commandButton", "h:inputText"``` or ```@("h:commandButton","h:inputText")```).
* **```-SearchOnly```**: Sctipt does not save any changes. Toggle this to have a test run, before running the script over a whole project.
* **```-GeneratorPattern```**: Pattern for the generated attributes. Default pattern is ```"generated_{attr}_{num}_"```.
	* ```{attr}``` will be replaced by the specified attribute
	* ```{id}``` will be replaced by a running number (to prevent crashes: if there are already attributes of the given pattern, the counter prevents duplicates)
	* None of these must be specified, but at least the ```{num}``` is recommended, to prevent duplicates.
	*Full example*: For a given configuration ```<h:commandButton ... />``` would become ```<h:commandButton id="generated_id_17_" ... />```.
* **```-LogLevel```**: One of ```TRACE```, ```DEBUG```, ```INFO```, ```WARN``` or ```ERROR```. Controls the verbosity of the console output. Default is ```INFO```

### **Examples**

#### Minimal call
```PowerShell
.\generate-attrs.ps1 -Path "C:\dev\project\index.xhtml" -Components "h:commandButton", "h:inputText" -Attribute "id"
```
creates the following output:
```
2018.01.01 00:00:00 INFO	GENERATED 4 ATTRIBUTES ON C:\dev\project\index.xhtml
2018.01.01 00:00:00 INFO	SCRIPT FINISHED: 4 CHANGES ON 1 FILES.
```

#### Example call with more configurations
```PowerShell
$path = "C:\dev\project"
$attribute = "id"
$pattern = "automatic_{attr}_{num}_" #will result in: id="automatic_id_1_"
$components = "h:commandButton", "h:inputText", "h:inputTextarea", "h:inputSecret"
.\generate-attrs.ps1 -Path $path -Components $components -Attribute $attribute -Recurse -SearchOnly -LogLevel DEBUG
```
creates the following output:
```
2018.01.01 00:00:00 INFO	GENERATED 2 ATTRIBUTES ON C:\dev\project\impressum.xhtml
2018.01.01 00:00:00 DEBUG		-> automatic_id_1_ ON h:commandButton
2018.01.01 00:00:00 DEBUG		-> automatic_id_2_ ON h:inputText
2018.01.01 00:00:00 INFO	GENERATED 8 ATTRIBUTES ON C:\dev\project\index.xhtml
2018.01.01 00:00:00 DEBUG		-> automatic_id_1_ ON h:commandButton
2018.01.01 00:00:00 DEBUG		-> automatic_id_2_ ON h:commandButton
2018.01.01 00:00:00 DEBUG		-> automatic_id_3_ ON h:commandButton
2018.01.01 00:00:00 DEBUG		-> automatic_id_4_ ON h:commandButton
2018.01.01 00:00:00 DEBUG		-> automatic_id_5_ ON h:commandButton
2018.01.01 00:00:00 DEBUG		-> automatic_id_6_ ON h:commandButton
2018.01.01 00:00:00 DEBUG		-> automatic_id_7_ ON h:commandButton
2018.01.01 00:00:00 DEBUG		-> automatic_id_8_ ON h:inputText
2018.01.01 00:00:00 INFO	GENERATED 6 ATTRIBUTES ON C:\dev\project\help.xhtml
2018.01.01 00:00:00 DEBUG		-> automatic_id_6_ ON h:inputText
2018.01.01 00:00:00 DEBUG		-> automatic_id_7_ ON h:inputText
2018.01.01 00:00:00 DEBUG		-> automatic_id_8_ ON h:inputText
2018.01.01 00:00:00 DEBUG		-> automatic_id_9_ ON h:inputText
2018.01.01 00:00:00 DEBUG		-> automatic_id_10_ ON h:inputText
2018.01.01 00:00:00 DEBUG		-> automatic_id_11_ ON h:inputText
2018.01.01 00:00:00 INFO	SEARCH FINISHED: 16 MISSING ATTRIBUTES ON 3 FILES.
```