<?php require("config.inc.php"); require("lib/bootstrap.php") ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
<head>
	<title>Asterisk Balls by simonoche</title>
	<link rel="stylesheet" type="text/css" media="screen" href="css/main.css" />
</head>
<body>
	<div class="cookie_error">
		PLEASE SET YOUR "jqr" AUTH COOKIE 
	</div>
		
	<div class="pollbar">

		<div class="test">
			<b>ASTERISK BALLS</b>
		</div>

		<div class="user_id">
			<b>Your USER_ID is <?php echo $user->user_id; ?></b>
		</div>

		<div class="processes">
			Current processes : <span>0</span>
		</div>

		<div class="processes_limit">
			Max allowed processes : <span>0</span>
		</div>

		<div class="actions">
			<button class="jq_spawn">Launch Process</button>
			<button class="jq_more">Limit +</button>
			<button class="jq_less">Limit -</button>
		</div>

	</div>

	<script type="text/javascript">
		// Your Config (change it if needed)
		var poller_server = "<?php echo $jqrealtime["poller"]; ?>";
		var poller_start_with = 3;

		// Action to trigger
		var poller_trigger = function(data){

			if($("#ball-"+data.realtime.astball.ballid).length > 0)
			{
				var ball = $("#ball-"+data.realtime.astball.ballid);
				var ratio = 50;

				if(data.realtime.astball.action == "kill")
				{
					ball.fadeOut();
					return false;
				}

				// Move the ball
				switch(data.realtime.astball.digit)
				{
					case "1":
						ball.animate({top: "-="+ratio, left: "-="+ratio});
					break;
					case "2":
						ball.animate({top: "-="+ratio});
					break;
					case "3":
						ball.animate({top: "-="+ratio, left: "+="+ratio});
					break;
					case "4":
						ball.animate({left: "-="+ratio});
					break;
					case "5":
						// Change size
						var rzi = randsize();
						ball.css("height", rzi).css("width", rzi);
					break;
					case "6":
						ball.animate({left: "+="+ratio});
					break;
					case "7":
						ball.animate({left: "-="+ratio, top: "+="+ratio});
					break;
					case "8":
						ball.animate({top: "+="+ratio});
					break;
					case "9":
						ball.animate({left: "+="+ratio, top: "+="+ratio});
					break;
					case "*":
						// Return at origin
						ball.animate({left: "60", top: "60"});
					break;
					case "#":
						// Change color
						ball.css("background", randcolor());
					break;
				}	
			}
			else
			{
				// Generate a random size (in px)
				var ballSize = randsize();

				// Create the ball
				$("body").append(
					$("<div/>")
						.addClass("ball")
						.attr("id", "ball-" + data.realtime.astball.ballid)
						.css("height", ballSize)
						.css("width", ballSize)
						.css("border-radius", ballSize)
						.css("background", randcolor())
						.html("<span>" + data.realtime.astball.ballnu + "</span>")
					);
			}
		};

		// Random size
		function randsize()
		{
			return (Math.floor(Math.random() * (150 - 100 + 1)) + 100) + "px";
		}

		function randcolor()
		{
			return '#'+Math.floor(Math.random()*16777215).toString(16);
		}

	</script>
	<script type="text/javascript" src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
	<script type="text/javascript" src="js/jquery.realtime.js"></script>
</body>
</html>