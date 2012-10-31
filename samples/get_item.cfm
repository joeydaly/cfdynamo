<cfscript>
	credentials = xmlParse(expandPath("/cfdynamo/com/imageaid/cfdynamo/aws_credentials.xml"));
	cfdynamo = new com.imageaid.cfdynamo.DynamoClient(
		aws_key = credentials.cfdynamo.access_key.xmlText, 
		aws_secret = credentials.cfdynamo.secret_key.xmlText
	);		
	if( lcase(trim(cgi.request_method)) == "post" ){
		get_item = {};
		get_item.string_field = "This is a string";
		try{
			put_item = cfdynamo.get_item(table_name="#trim(form.table_name)#", item=put_item);
		}
		catch(Any e){
			put_item = e;
		}
	}	
	try{
		my_tables = cfdynamo.list_tables();
	}
	catch(Any e){
		my_tables = [];
	}
</cfscript>
<html>
	<head>
		<title>DynamoDB - Get Item from Table</title>
	</head>
	<body>
		<h1>Get Item</h1>
		<p>
			Select the table from which to get the item. Provide a key name and its values on which to search/get. 
		</p>
		<form action="#cgi.script_name#" method="post" id="which_table_form" name="which_table_form">
			<label>Existing Tables</label>
			<select name="table_name" id="table_name">
				<cfloop array="#my_tables#" index="table">
					<option value="#table#">#table#</option>
				</cfloop>
			</select>
			<label>Field to Search</label><input type="text" name="table_field" id="table_field" value="" />
			<label>Field Value to Search</label><input type="text" name="table_field_value" id="table_field_value" value="" />
			<input type="submit" value="Put Item &rarr;">
		</form>
	</body>
</html>
