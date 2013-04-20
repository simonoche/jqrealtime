/*
 * jQuery Realtime
 * @author Simon Lamellière
 */

// Our poller unique id
var poller_session = String(new Date().getTime()).substr(5,8);
var poller_max_processes = 3;
var poller_processes = 0;
var poller_timeout = 35000;
var poller_requests = 0;
var is_identified = true;

// Poller URL
var poller_server = "/poll";

// Poller
jQuery(document).ready(function()
{
	/* Listeners */
	$(document).on("click", ".jq_spawn", function(){
		$("body").triggerHandler("poll");
	});

	$(document).on("click", ".jq_less", function(){
		poller_max_processes--;
		$("body").triggerHandler("update");
	});

	$(document).on("click", ".jq_more", function(){
		poller_max_processes++;
		$("body").triggerHandler("update");
	});

	/* Realtime */
	$("body")
		.bind("update", function(event, message)
		{
			$(".processes_limit span").text(poller_max_processes);
			$(".processes span").text(poller_processes);
		})
		.bind("dispatch", function(event, data)
		{
			// Do whatever you want with data
			$(".data").prepend(new Date() + " : " + data.realtime.message + " <br/>");
		})
		.bind("poll", function(event)
		{
			// Check current number of processes
			if(poller_processes >= poller_max_processes)
				return false;

			// Increment our requests
			poller_processes++;

			// Update
			$("body").triggerHandler("update");

			// Poll	
			$.ajax(
			{
				async: true,
				url: poller_server,
				dataType: "jsonp",
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

					// Session problem ?
					if(data.session === false)
					{
						$(".cookie_error").fadeIn();
						is_identified = false;
						return false;
					}
					else
					{
						$(".cookie_error").hide();
					}

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

	// Launch first processus
	$("body").triggerHandler("poll");
});