<?php
$time = microtime();

$num_points = 100000;
$all_points = array();
$fifteen_minutes = 15 * 60;

for ( $x = 0; $x < $num_points; $x++)
{
	$all_points[] = rand(1000, 30000) / 100;
}

$temp_total = 0;
$average_points = array();

//calculate average
for ( $x = 0; $x < $num_points; $x++)
{
	$temp_total += $all_points[$x];
	
	if($x >= $fifteen_minutes)
	{
		//echo $x . ": " . $temp_total . "<br/>";
		$average_points[] = $temp_total/$fifteen_minutes;
		$temp_total -= $all_points[$x - $fifteen_minutes];
	}
}

echo count($all_points);
echo "Total time: " . (microtime() - $time) . "<br/>";
?>