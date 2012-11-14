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
			
			$('#deleteTableModal').modal({
				keyboard: false
				,show: false
			});

		});
	});


});

function confirmTableDelete(e) {
	console.log($(e.currentTarget).closest("tr").children("td.tableName").text());
	var sTableName = $(e.currentTarget).closest("tr").children("td.tableName").text();
	$("div.modal-body strong#deleteTableNameHolder").html(sTableName);
	$('#deleteTableModal').modal("show");
}