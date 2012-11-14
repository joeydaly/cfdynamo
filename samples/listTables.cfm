<!--- Get the tables --->
<cfset tables = application.aws.cfdynamo.listTables() />
<cfoutput>
	<h2>List Tables</h2>
	<table id="dynamodbtables" class="table table-striped table-hover">
		<tr>
			<th>Actions</th>
			<th>Table Name</th>
		</tr>
		<cfloop array="#tables#" index="table">
			<tr>
				<td style="text-align:center;">
					<a href="##" class="btn btn-mini btn-info disabled"><i class="icon-edit"></i></a>
					<a href="##" class="btn btn-mini btn-danger disabled"><i class="icon-remove"></i></a>
				</td>
				<td class="tableName">#table#</td>
			</tr>
		</cfloop>
	</table>

	<div id="deleteTableModal" class="modal hide fade">
	  <div class="modal-header">
	    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	    <h3>Delete Table</h3>
	  </div>
	  <div class="modal-body">
	    <p>Are you sure you would like to delete this table?</p>
	    <p><strong id="deleteTableNameHolder"></strong></p>
	  </div>
	  <div class="modal-footer">
	    <a href="##" class="btn">Cancel</a>
	    <a href="##" class="btn btn-danger">Delete</a>
	  </div>
	</div>
</cfoutput>