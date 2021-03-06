#!/usr/bin/php5 -q
<?php

    /**
       jqRealtime <https://github.com/simonoche/jqrealtime>
       Copyright (C) 2013 Simon Lamellière <simon@lamellie.re>

       This program is free software: you can redistribute it and/or modify
       it under the terms of the GNU Affero General Public License as
       published by the Free Software Foundation, either version 3 of the
       License, or (at your option) any later version.

        @purpose:
        Caller can move balls on a webpage with phone digits (DTMF)
        (useless, but fun...)
        
        Simply make a symbolic link of this and kill-ball.php in /var/lib/asterisk/agi-bin/
        Ensure asterisk has permission to execute and read this AGI file

    **/

    // Include configuration
    require_once "/var/lib/asterisk/agi-bin/phpagi.php";
    require_once dirname(__FILE__) . "/../php/config.inc.php";
    require_once dirname(__FILE__) . "/../php/lib/jqrealtime.class.php";

    // Init AGI
    $agi = new AGI();
    $i = 0;

    // UniqueId
    $guid = $argv[1];

    // Kill the ball
    jqRealtime::push("all", array("astball" => 
        array(
           "ballid" => md5($guid),
           "action" => "kill"
        )
    ));

    // We always hangup
    $agi->hangup();

?>