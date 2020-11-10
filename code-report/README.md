## **code-report**

Scans directories for a set of pre-defined programming- or markup-languages.
Outputs several result-tables and even a chart with a percentual overview.
The set of build-in languages contains at least the syntax of the Top-10 most frequently used programming-languages as specified by the [TIOBE-Index](https://www.tiobe.com/tiobe-index/) and is easy to extend.

### **Arguments**

* **```-Path```**: Specifies the directory to be examined. The directory will be searched recusively by default.
* **```-CountNoLines```**: The Program counts code-lines by default. This can be toggled of with this switch
* **```-CountWords```**: Count also words, additional to code-lines
* **```-CountChars```**: Count also single characters, additional to code-lines and words (every switch works on its own too, of course)
* **```-ResultChart```**: Prints a result chart with the percentual amount of files/code-lines per programming-language

### **Examples**

#### Minimal call

```PowerShell
.\code-report -Path "C:\dev\project"
```
creates the following output:
```
Content-Type:                               Python
Total-Files:                                     4
==================================================
File-Extension:                    |           .py
-----+--------------+--------------+--------------
     |         Total|          Code|       Comment
-----+--------------+--------------+--------------
Lines|        622,00|        539,00|         83,00
-----+--------------+--------------+--------------


Content-Type:                           Unix-Shell
Total-Files:                                     3
==================================================
File-Extension:                    |           .sh
-----+--------------+--------------+--------------
     |         Total|          Code|       Comment
-----+--------------+--------------+--------------
Lines|         73,00|         66,00|          7,00
-----+--------------+--------------+--------------


Content-Type:                             Markdown
Total-Files:                                     1
==================================================
File-Extension:                    |           .md
-----+--------------+--------------+--------------
     |         Total|          Code|       Comment
-----+--------------+--------------+--------------
Lines|          5,00|          5,00|          0,00
-----+--------------+--------------+--------------
```

#### Example call with more configurations
```PowerShell
.\code-report.ps1 -Path "C:\dev\project" -CountWords -CountChars -ResultChart
```
creates the following output:
```
Content-Type:                               Python
Total-Files:                                     4
==================================================
File-Extension:                    |           .py
-----+--------------+--------------+--------------
     |         Total|          Code|       Comment
-----+--------------+--------------+--------------
Lines|        622,00|        539,00|         83,00
Words|      2.739,00|      1.927,00|        812,00
Chars|     32.679,00|     27.404,00|      5.275,00
-----+--------------+--------------+--------------


Content-Type:                           Unix-Shell
Total-Files:                                     3
==================================================
File-Extension:                    |           .sh
-----+--------------+--------------+--------------
     |         Total|          Code|       Comment
-----+--------------+--------------+--------------
Lines|         73,00|         66,00|          7,00
Words|        187,00|        175,00|         12,00
Chars|      1.862,00|      1.741,00|        121,00
-----+--------------+--------------+--------------


Content-Type:                             Markdown
Total-Files:                                     1
==================================================
File-Extension:                    |           .md
-----+--------------+--------------+--------------
     |         Total|          Code|       Comment
-----+--------------+--------------+--------------
Lines|          5,00|          5,00|          0,00
Words|         48,00|         48,00|          0,00
Chars|        290,00|        290,00|          0,00
-----+--------------+--------------+--------------


     Content-Type|                       Files (%)
==================================================
           Python|xxxxxxxxxxxx             50,00 %
       Unix-Shell|xxxxxxxxxx               37,50 %
         Markdown|xxx                      12,50 %
-----------------+--------------------------------
                                          100,00 %

     Content-Type|                       Lines (%)
==================================================
           Python|xxxxxxxxxxxxxxxxxxxxxx   88,86 %
       Unix-Shell|xx                       10,43 %
         Markdown|                          0,71 %
-----------------+--------------------------------
                                          100,00 %
```