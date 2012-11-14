$(document).ready(function(){
	console.log("Up and running at " + new Date().toString());
		
	$("ul.nav a#listTables").click(function(e){
		e.preventDefault();
		console.log("Fetching table listing...");
		$("div#content").load("listTables.cfm", function(e) {
			
			console.log("Loaded the listTables data.");
			
			// Set up some behaviors that we want to affect the dom
			$("table#dynamodbtables tr")
				.on("mouseenter", function(e) {
					$(e.currentTarget).find("a").removeClass("disabled");
				})
				.on("mouseleave", function(e) {
					$(e.currentTarget).find("a").addClass("disabled");
				});

			$("table#dynamodbtables tr td a.btn-danger").click(confirmTableDelete);
			$("table#dynamodbtables tr td a.btn-primary").click(showTableInfo);
			
			$('#deleteTableModal').modal({
				keyboard: false
				,show: false
			});
			$('#infoTableModal').modal({
				keyboard: false
				,show: false
			});

		});
	});


});

function confirmTableDelete(e) {
	e.preventDefault();
	var sTableName = $(e.currentTarget).closest("tr").children("td.tableName").text();
	$("div.modal-body strong#deleteTableNameHolder").html(sTableName);
	$("div.modal-footer a.btn-danger").click(function(e){
		e.preventDefault();
		$('#deleteTableModal').modal("hide");
		$("div#content").load("deleteTable.cfm?table=" + sTableName);
	})
	$('#deleteTableModal').modal("show");
}

function showTableInfo(e) {
	e.preventDefault();
	var sTableName = $(e.currentTarget).closest("tr").children("td.tableName").text();
	$.getJSON("tableInfo.cfm?table=" + sTableName, function(r){
		$("div.modal-body span.tableName").text(r.tableName);
		$("div.modal-body span.tableStatus").text(r.status);
		$("div.modal-body span.tableReadCapacity").text(r.readCapacity);
		$("div.modal-body span.tableWriteCapacity").text(r.writeCapacity);
		if (r.keys.hashKey) {
			$("div.modal-body span.tableHashKeyName").text(r.keys.hashKey.name);
			$("div.modal-body span.tableHashKeyType").text(r.keys.hashKey.type);
		}
		if (r.keys.rangeKey) {
			$("div.modal-body span.tableRangeKeyName").text(r.keys.rangeKey.name);
			$("div.modal-body span.tableRangeKeyType").text(r.keys.rangeKey.type);
		}
	});
	$('#infoTableModal').modal("show");
}