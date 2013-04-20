<?php require("config.inc.php"); ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
<head>
	<title>jqRealtime by simonoche</title>
	<link rel="stylesheet" type="text/css" media="screen" href="css/main.css" />
</head>
<body>
	<div class="cookie_error">
		PLEASE SET YOUR "jqr" AUTH COOKIE 
	</div>
		
	<div class="pollbar">

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

	<div class="data">

	</div>
	<script type="text/javascript">
		// Your Config (change it if needed)
		var poller_server = "http://realtime.dev:8080/poll";
	</script>
	<script type="text/javascript" src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
	<script type="text/javascript" src="js/jquery.realtime.js"></script>
</body>
</html>