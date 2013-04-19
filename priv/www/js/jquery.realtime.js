/*
 * jQuery Realtime
 * @author Simon Lamellière
 */

jQuery(document).ready(function()
{
	// Our poller unique id
	var poller_session = new Date().getTime();
	var poller_max_processes = 3;
	var poller_processes = 0;

	// Poller URL
	var poller_server = "/poll";

	/* Worketer Realtime */
	$("body")
		.bind("message", function(event, message){})
		.bind("error", function(event, message){})
		.bind("append", function(event, message){})
		.bind("dispatch", function(event, data)
		{
			// Continue polling
			$("body").triggerHandler("poll");

			// Go
			console.log(data);
		})
		.bind("poll", function(event)
		{
			// Check current number of processes
			if(poller_processes >= poller_max_processes)
			{
				console.log("Max Processes Reached");
				return false;
			}

			// Increment our requests
			poller_processes++;

			// Poll	
			$.ajax(
			{
				url: poller_server,
				dataType: "json",
				method: "get",
				timeout: 35000,
				data: { 
					id: poller_session 
				},
				success: function(data)
				{
					// Process ended
					poller_processes--;

					// Dispatch Data to our controller
					$("body").triggerHandler("dispatch", data);
				},
				error: function()
				{
					// Process ended
					poller_processes--;

					// Nothing to dispatch due to an error
					$("body").triggerHandler("dispatch", -1);
				}
			});
		});
});