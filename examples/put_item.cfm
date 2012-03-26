<cfscript>
	credentials = xmlParse(expandPath("/cfdynamo/com/imageaid/cfdynamo/aws_credentials.xml"));
	cfdynamo = new com.imageaid.cfdynamo.DynamoClient(
		aws_key = credentials.cfdynamo.access_key.xmlText, 
		aws_secret = credentials.cfdynamo.secret_key.xmlText
	);		
	if( lcase(trim(cgi.request_method)) == "post" ){
		put_item = {};
		put_item.string_field = "This is a string";
		put_item.number_field = 1;
		put_item.array_field = ["Hello","World","!","How","are","you","?"];
		try{
			put_item = cfdynamo.put_item(table_name="#trim(form.table_name)#", item=put_item);
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
		<title>DynamoDB - Put Item to Table</title>
	</head>
	<body>
		<h1>Put Item</h1>
		<p>
			Select the table in which to place the item. The item itself is just a three basic keys and their values (a string, a number and an array of strings). 
			Nothing facny. 
		</p>
		<cfoutput>
			<form action="#cgi.script_name#" method="post" id="which_table_form" name="which_table_form">
				<label>Existing Tables</label>
				<select name="table_name" id="table_name">
					<cfloop array="#my_tables#" index="table">
						<option value="#table#">#table#</option>
					</cfloop>
				</select>
				<input type="submit" value="Put Item &rarr;">
			</form>
		</cfoutput>
	</body>
</html>
