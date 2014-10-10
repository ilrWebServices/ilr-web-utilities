<?php

/* Set the time zone to prevent AWS from displaying a warning that
 * it is not safe to rely on the system's timezone settings.
 */
date_default_timezone_set('EST');

require 'ilr-faculty-data.php';

$aws_key = AWS_KEY;
$aws_secret = AWS_SECRET;
$aws_bucket = AWS_BUCKET;

use Aws\S3\S3Client;
$client = S3Client::factory(array(
  'key' => $aws_key,
  'secret' => $aws_secret,
));

// Register the stream wrapper from an S3Client object
$client->registerStreamWrapper();

// Makes a file in an S3 bucket publicly readable.
function set_perms(&$aws_Client, $bucket, $file_name) {
  $aws_Client->putObjectAcl(array(
    'Bucket'     => $bucket,
    'Key'        => $file_name,
    'ACL'        => 'public-read'
  ));
}

// Remove old copies of the final output file from the S3 bucket
$out_file = 'ilr_profiles_feed.xml';
if (file_exists("s3://{$aws_bucket}/" . $out_file)) {
  unlink("s3://{$aws_bucket}/" . $out_file);
}

/* Build the feed of profiles from all data sources. */
$job_log = array();
add_log_event($job_log, "Job begun");

// Retrieve to XML
$raw_xml = file_get_contents("s3://{$aws_bucket}/ilr_profiles_raw_ai_data.xml");

// Run the XSLT transform on the main xml file, which will fold in the fields from lpad and legacy_ilr_directory_HTML
$transformed_xml = "s3://{$aws_bucket}/ilr_profiles_feed.xml";
file_put_contents($transformed_xml, stripEmptyCDATA(xslt_transform($raw_xml, get_ilr_profiles_transform_xsl(), 'xml')));
set_perms($client, $aws_bucket, 'ilr_profiles_feed.xml');
add_log_event($job_log, "Final ILR Profiles data feed generated");

$ip_tracking = !empty($_SERVER['REMOTE_ADDR']) ? "(requested from IP: {$_SERVER['REMOTE_ADDR']})" : '(from local CLI script execution)';
$job_results = "Results of a retransformation of aggregated ILR faculty and staff profile data {$ip_tracking}:\n" . display_log($job_log);
$log_file_name = 'feed-generator-report-' . date('Y-n-j-H-i-s', time()) . '.txt';
file_put_contents("s3://{$aws_bucket}/{$log_file_name}", $job_results);
set_perms($client, $aws_bucket, $log_file_name);
