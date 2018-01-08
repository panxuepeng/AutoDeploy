<?php

foreach (glob("/data/devs/[0-9]*") as $filename) {
    echo basename($filename) . "\n";
}
