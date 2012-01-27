<cfscript>
	examples = directoryList(expandPath("examples"));
</cfscript>
<html>
	<head>
		<title>CFDynamo Project</title>
	</head>
	<body>
		<h1>CFDynamo</h1>
		<p>Some blurb about CFDyanmo here ...</p>
		<h2>Examples</h2>
		<dd>
			<cfoutput>
			<cfloop from="1" to="#arrayLen(examples)#" index="i">
				<cfset file_name = getFileFromPath(examples[i]) />
				<dt><a href="examples/#file_name#" target="_blank">#file_name#</a></dt>
			</cfloop>
			</cfoutput>
		</dd>
	</body>
</html>