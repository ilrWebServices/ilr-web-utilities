<?php

/* Set the time zone to prevent AWS from displaying a warning that
 * it is not safe to rely on the system's timezone settings.
 */
date_default_timezone_set('EST');

require 'ilr-faculty-data.php';
// require 'vendor/autoload.php';
// require 'aws-sdk-conf.php';

// if (! verify_configuration()) {
//   echo "Error: Please ensure a complete configuration has been supplied for ilr-faculty-data.php.";
//   exit();
// }

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

function set_perms(&$aws_Client, $bucket, $file_name) {
  $aws_Client->putObjectAcl(array(
    'Bucket'     => $bucket,
    'Key'        => $file_name,
    'ACL'        => 'public-read'
  ));
}

// Remove old copies of the output files in the S3 bucket
foreach( array(
  'ilr_people.xml',
  'ilr_profiles_feed.xml',
  'ldap.xml',
  'legacy_ilr_directory_HTML.xml',
  ) as $out_file) {
  if (file_exists("s3://{$aws_bucket}/" . $out_file)) {
    unlink("s3://{$aws_bucket}/" . $out_file);
  }
}

/* Build the feed of profiles from all data sources. */

$ldap = get_ilr_people_from_ldap();
file_put_contents("s3://{$aws_bucket}/ldap.xml", ldap2xml($ldap));
set_perms($client, $aws_bucket, 'ldap.xml');

$ilrweb_data = get_legacy_ilr_directory_info();
file_put_contents("s3://{$aws_bucket}/legacy_ilr_directory_HTML.xml", $ilrweb_data);
set_perms($client, $aws_bucket, 'legacy_ilr_directory_HTML.xml');

/* Accumulate the AI data for all people in the ldap file. */

$raw_xml = '<?xml version="1.0" encoding="UTF-8"?>
<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2014-01-14">';
$count = 0;
// For each person returned by the ldap query, Append appropriate xml to xml/ilr_people.xml
foreach( $ldap as $person) {
  $count += 1;
  if ($person['uid'][0] != '') {
    //   Try to get person info from Activity Insights
    $ai_data = get_ai_person($person['uid'][0]);

    if ( $ai_data->statusCode == 200 ) {  // Activity Insight returned data for this person
      // Add Activity Insight data to the main XML document
      // file_put_contents('xml/ilr_people.xml', get_ai_record_from_data($ai_data->responseData), FILE_APPEND);
      $raw_xml .= get_ai_record_from_data($ai_data->responseData);
    } else {
      // Add a placeholder Record to the main XML document with the userid
      //file_put_contents('xml/ilr_people.xml', '<Record username="' . $person['uid'][0] . '" />', FILE_APPEND);
      $raw_xml .= '<Record username="' . $person['uid'][0] . '" />';
    }
  }
}
$raw_xml .= '<recordcount>' . $count . '</recordcount>';

// Close the Data tag in the main xml file
// file_put_contents('xml/ilr_people.xml', '</Data>', FILE_APPEND);
$raw_xml .= '</Data>';

// Run the XSLT transform on the main xml file, which will fold in the fields from lpad and legacy_ilr_directory_HTML
$transformed_xml = "s3://{$aws_bucket}/ilr_profiles_feed.xml";
file_put_contents($transformed_xml, stripEmptyCDATA(xslt_transform($raw_xml, get_ilr_profiles_transform_xsl(), 'xml')));
set_perms($client, $aws_bucket, 'ilr_profiles_feed.xml');
