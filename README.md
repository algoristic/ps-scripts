# **ps-scipts**

Collection of useful PowerShell scripts I wrote to simplify some developing processes, or just for fun :)

### **Scripts **

#### **[code-report](https://bitbucket.org/obabo/ps-scripts/src/master/code-report/)**

Scans directories for a set of pre-defined programming- or markup-languages.
Outputs several result-tables and even a chart with a percentual overview.
The set of build-in languages contains at least the syntax of the Top-10 most frequently used programming-languages as specified by the [TIOBE-Index](https://www.tiobe.com/tiobe-index/) and is easy to extend.

#### **[generate-attrs](https://bitbucket.org/obabo/ps-scripts/src/master/generate-attrs/)**

Optimised for ```.xhtml```-Files, this scipt is a powerful tool to generate missing attributes on a flexible set of tags. With a given pattern for the attribute to be added, it is possible to transform ```<h:inputText ... />``` to ```<h:inputText id="generated_id_42_" ... />``` or even ```<h:commandButton ... />``` to ```<h:commandButton action="#{foo.bar()}" />``` for a single file, some directories or complete projects. It is meant to generate those attributes by a default value and then use this to iterate (with your IDE) through the project and fill in meaningful values.