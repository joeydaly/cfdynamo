<cfscript>
	try{
		credentials = xmlParse(expandPath("/cfdynamo/com/imageaid/cfdynamo/aws_credentials.xml"));
		cfdynamo = new com.imageaid.cfdynamo.DynamoClient(
			aws_key = credentials.cfdynamo.access_key.xmlText, 
			aws_secret = credentials.cfdynamo.secret_key.xmlText
		);
		my_tables = cfdynamo.list_tables();	
		if( lcase(trim(cgi.request_method)) == "post" ){
			cfdynamo.update_table(table_name = trim(form.table_name), read_capacity = form.read_capacity, write_capacity = form.write_capacity);
		}
	}
	catch(Any e){
		my_tables = [];
		writeLog(type="Error",text="#e.type# :: #e.message#", file="dynamodb.log");
		rethrow;
	}
</cfscript>
<html>
	<head>
		<title>DynamoDB - Update Table</title>
	</head>
	<body>
		<cfoutput>
		<h1>Update Tables</h1>
		<cfif lcase(trim(cgi.request_method)) == "post">
			<p>Note: It takes a few moments for AWS to update a DynamoDB table.</p>
			<p><a href="#cgi.script_name#">reload page</a></p>
		</cfif>
		<p>As a testing page, there are no validations in place. Enter the data correctly and away you go!</p>
		<form action="#cgi.script_name#" method="post" id="update_table_form" name="update_table_form">
			<label>Existing Tables</label>
			<select name="table_name" id="table_name">
				<cfloop array="#my_tables#" index="table">
					<option value="#table#">#table#</option>
				</cfloop>
			</select>
			<br />
			<h4>Optional Values</h4>
			<label>Read Capacity</label><input type="text" name="read_capacity" id="read_capacity" value="5" /><br />
			<label>Write Capacity</label><input type="text" name="write_capacity" id="write_capacity" value="5" /><br />
			<input type="submit" value="Update &rarr;">
		</form>
		</cfoutput>
	</body>
</html>