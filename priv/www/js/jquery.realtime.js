/*
 * jQuery Realtime
 * @author Simon Lamellière
 */

// Our poller unique id
var poller_session = new Date().getTime();
var poller_max_processes = 3;
var poller_processes = 0;
var poller_timeout = 35000;
var poller_requests = 0;

// Poller URL
var poller_server = "/poll";

// Poller
jQuery(document).ready(function()
{
	/* Worketer Realtime */
	$("body")
		.bind("message", function(event, message){})
		.bind("error", function(event, message){})
		.bind("dispatch", function(event, data)
		{
			// Do whatever you want with data
			$(".data").append("Message " + data.realtime.message + " <br/>");
		})
		.bind("poll", function(event)
		{
			// Check current number of processes
			if(poller_processes >= poller_max_processes)
				return false;

			// Increment our requests
			poller_processes++;

			// Poll	
			$.ajax(
			{
				async: true,
				url: poller_server,
				dataType: "json",
				method: "get",
				timeout: poller_timeout,
				data: {
					n: poller_requests++,
					id: poller_session
				},
				success: function(data)
				{
					// Process ended
					poller_processes--;

					// Continue Polling
					$("body").triggerHandler("poll");

					// Dispatch Data to our controller
					if(data.timeout !== true)
						$("body").triggerHandler("dispatch", data);
				},
				error: function()
				{
					// Process ended
					poller_processes--;

					// Continue Polling
					$("body").triggerHandler("poll");
					
					// Nothing to dispatch due to an error
					$("body").triggerHandler("dispatch", -1);
				}
			});
		});
});