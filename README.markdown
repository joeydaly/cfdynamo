# CFDynamo #

CFDynamo is a typically lame-named ColdFusion wrapper for the Amazon DynamoDB Java API.

## Goal ##
To build a simple but effective CFC wrapper for the Java AWS SDK for DynamoDB.

## Setup ##
Setup is faily simple, with the only realy consideration being the implementation for the Java AWS SDK on your Railo instance. 

I use Tomcat with Railo and have done the following: 
* Download/expand the Zip archive and move the "aws" folder^, generated when you expand the archve, into your tomcat/lib folder.
* Stop Tomcat/Railo
* Open tomcat root/conf/catalina.properties and find the line with "common.loader="
* Add the following to the end of the common.loader= line: ,${catalina.home}/lib/aws,${catalina.home}/lib/aws/*.jar
* Add the "com" folder and its content to your web application
* Perhaps, depending on your server setup, add a mapping to "cfdynamo" in your web administrator. 
* Start Tomcat/Railo  

### Sample App ###
Other than the assets folder in this Git repository, which you need to address with the steps above, you can clone the files into a directory in your web root and just get going. Sort of ... you still have to create a table in the AWS console (going to add the createTable wrapper shortly).

^The "aws" folder contains a series of JARs. These JARs can be dropped directly into your tomcat/lib folder with no updates to the catalina.properties file. However, I prefer to keep my added JARs organized for easier updates, etc.   

### Details to Come ###
More details to come on the project ... just getting the initial repo setup today. 