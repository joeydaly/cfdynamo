# CFDynamo #

CFDynamo is a typically lame-named ColdFusion wrapper for the Amazon DynamoDB Java API.

## Goal ##
To build a simple but effective CFC wrapper for the Java AWS SDK for DynamoDB.

## Setup ##
Setup is faily simple, with the only realy consideration being the implementation for the Java AWS SDK on your Railo/ACF instance. 

I use Tomcat with Railo and have done the following: 

1. Download/expand the Zip archive from Github.
2. Rename the downloaded folder to cfdynamo
3. Inside the assets folder is a Zip archive containing the AWS and related JARs ... expand this archive (it will be named "aws")
4. Move the newly expanded "aws" folder^ into your {tomcat root}/lib folder.
5. Open {tomcat root}/conf/catalina.properties and find the line with "common.loader="
6. Add the following to the end of the common.loader= line: ,${catalina.home}/lib/aws,${catalina.home}/lib/aws/*.jar
7. Add the "cfdynamo" folder and its content to your web application or web root (you can remove the examples and other files, not in the com folder, if you like)
8. Add a mapping to "cfdynamo" in your web administrator ... the sample app attemtps to create a /cfdynamo mapping for you, but, if you're going to use this in an application, it's probably best to just add the mapping the the administrator.
9. Retart Tomcat/Railo  

If you use Adobe ColdFusion 9, the general idea is the same but here is how I configured ACF9 (stand-alone server) to load my AWS JARs: 

1. Download/expand the Zip archive from Github.
2. Rename the downloaded folder to cfdynamo
3. Inside the assets folder is a Zip archive containing the AWS and related JARs ... expand this archive (it will be named "aws")
4. Move the newly expanded "aws" folder^ into your {Adobe ColdFusion 9 Install Folder}/WEB-INF/lib folder.
5. Open {Adobe ColdFusion 9 Install Folder}/runtime/bin/jvm.config and find the line with "java.class.path=" (there may be a better way to do this but this is how I got it working with the lest amount of headaches)
6. Add the following to the end of the java.class.path= line: ,{application.home}/../wwwroot/WEB-INF/lib/aws
7. Add the "cfdynamo" folder and its content to your web application (you can remove the examples and other files if you like)
8. Add a mapping to "cfdynamo" in your web administrator ... the sample app attemtps to create a /cfdynamo mapping for you, but, if you're going to use this in an application, it's probably best to just add the mapping the the administrator.
9. Retart ACF 9

### Sample App ###
Other than the assets folder in this Git repository, which you need to address with the steps above, you can clone the files into a directory in your web root and just get going. Sort of ... you still have to create a table in the AWS console (going to add the createTable wrapper shortly).

^The "aws" folder contains a series of JARs. These JARs can be dropped directly into your {tomcat root}/lib or {Adobe ColdFusion 9 Install Folder}/wwwroot/WEB-INF/lib/ folder with no updates to the catalina.properties file. 

However, I prefer to keep my added JARs organized into their own folders for easier updates, etc.   

### Details to Come ###
More details to come on the project ... just getting the initial repo setup today. 