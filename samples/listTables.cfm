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
				<td style="text-align:center;" nowrap>
					<a href="##" class="btn btn-mini btn-info disabled"><i class="icon-edit icon-white"></i></a>
					<a href="##" class="btn btn-mini btn-primary disabled"><i class="icon-eye-open icon-white"></i></a>
					<a href="##" class="btn btn-mini btn-danger disabled"><i class="icon-remove"></i></a>
				</td>
				<td width="99%" class="tableName">#table#</td>
			</tr>
		</cfloop>
	</table>


	<!--- DELETE MODAL --->
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


	<!--- INFO MODAL --->
	<div id="infoTableModal" class="modal hide fade">
	  <div class="modal-header">
	    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
	    <h3>Table Information</h3>
	  </div>
	  <div class="modal-body">
	    <p>
			<strong>Name:</strong> <span class="tableName"></span><br />
			<strong>Status:</strong> <span class="tableStatus"></span><br />
			<strong>Read Capacity:</strong> <span class="tableReadCapacity"></span><br />
			<strong>Write Capacity:</strong> <span class="tableWriteCapacity"></span><br />
			<strong>Hash Key Name:</strong> <span class="tableHashKeyName"></span><br />
			<strong>Hash Key Type:</strong> <span class="tableHashKeyType"></span><br />
			<strong>Range Key Name:</strong> <span class="tableRangeKeyName"></span><br />
			<strong>Range Key Type:</strong> <span class="tableRangeKeyType"></span><br />
		</p>
	  </div>
	  <div class="modal-footer">
	    <button type="button" data-dismiss="modal">Ok</button>
	  </div>
	</div>

</cfoutput>