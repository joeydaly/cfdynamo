<cfscript>
	try{
		credentials = xmlParse(expandPath("/cfdynamo/com/imageaid/cfdynamo/aws_credentials.xml"));
		cfdynamo = new com.imageaid.cfdynamo.DynamoClient(
			aws_key = credentials.cfdynamo.access_key.xmlText, 
			aws_secret = credentials.cfdynamo.secret_key.xmlText
		);	
		/*
		 * required string table_name, required string pk_name='id', required string pk_type = 'hash', required string pk_value_type='int',
		string pk_range_name, string pk_range_value_type, numeric read_capacity=5, numeric write_capacity=5
		 **/
		if( lcase(trim(cgi.request_method)) == "post" ){
			cfdynamo.create_table(
				table_name = trim(form.table_name), pk_name = '#form.table_id#', pk_value_type = "#form.pk_value_type#", 
				read_capacity = form.read_capacity, write_capacity = form.write_capacity
			);
		}
		my_tables = cfdynamo.list_tables(limit=1);
	}
	catch(Any e){
		my_tables = e;
	}
</cfscript>
<html>
	<head>
		<title>DynamoDB - Create Table</title>
	</head>
	<body>
		<cfoutput>
		<h1>Current Tables</h1>
		<cfif lcase(trim(cgi.request_method)) == "post">
			<p>Note: It takes a few moments for AWS to create a DynamoDB table. I would expect, with this iteration of CFDynamo, that the table you just created does not show up in the listing yet ... reload the page (without the tbl value in the URL) in a minute or two to see it appear.</p>
			<p><a href="#cgi.script_name#">reload page</a></p>
		</cfif>		
			<ul>
			<cfloop array="#my_tables#" index="table_name">
				<li><a href="#cgi.script_name#?tbl=#table_name#">#table_name#</a></li>
			</cfloop>
			</ul>
		<h2>Add a New Table</h2>
		<p>As a testing page, there are no validations in place. Enter the data correctly and away you go!</p>
		<form action="#cgi.script_name#" method="post" id="create_table_form" name="create_table_form">
			<label>Table Name</label><input type="text" name="table_name" id="table_name" /><br />
			<label>Table Primary Key Field Name</label><input type="text" name="table_id" id="table_id" /><br />
			<label>Table Primary Key Type</label>
			<select name="pk_type" id="pk_type">
				<option value="hash">Hash</option>
				<option value="range">Hash and Range</option>
			</select><br />
			<label>Table Primary Key Type/Value</label>
			<select name="pk_value_type" id="pk_value_type">
				<option value="int">Integer/Numeric</option>
				<option value="string">String</option>
			</select><br />
			<h4>Optional Values</h4>
			<label>Table Range Primary Key Field Name</label><input type="text" name="pk_range_name" id="pk_range_name" /><br />
			<label>Table Range Primary Key Type Value</label>
			<select name="pk_range_value_type" id="pk_range_value_type">
				<option value="hash">Hash</option>
				<option value="hashrange">Hash and Range</option>
			</select><br />
			<label>Read Capacity</label><input type="text" name="read_capacity" id="read_capacity" value="5" /><br />
			<label>Write Capacity</label><input type="text" name="write_capacity" id="write_capacity" value="5" /><br />
			<input type="Submit" value="Create &rarr;">
		</form>
		</cfoutput>
	</body>
</html>