<?php

/**
 * @file
 * Functions for pulling data from ldap, Activity Insight, and legacy ilr web directory
 * @todo Retrieve faculty leave from a Box file rather than storing it here which requires a redeployment when it changes
 *
 */

require 'ilr-faculty-data-conf.php';

date_default_timezone_set('EST');

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
$job_log = array();

function verify_configuration() {
  $result = true;
  $config_vars = array(
    'AI_API_URL',
    'AI_USERID',
    'AI_PWD',
    'LDAP_START',
    'LDAP_FILTER',
    'LDAP_SERVER',
    'LDAP_PORT',
  );

  foreach ($config_vars as $config) {
    if (empty($GLOBALS[$config])) {
      $result = false;
    }
  }
  return $result;
}

// $LDAP_ATTRIBUTES = ['sn'
//   , 'givenname'
//   , 'mailnickname'
//   , 'title'
//   , 'physicaldeliveryofficename'
//   , 'telephonenumber'
//   , 'displayname'
//   , 'department'
//   , 'employeetype'
//   , 'personaltitle'
//   , 'uid'
//   , 'mail'];

$ldap_attributes = array(
  'displayname',
  'cornelleducampusaddress',
  'cornelleducampusphone',
  'edupersonprincipalname',
  'cornelleduunivtitle1',
  'cornelleduwrkngtitle1',
  'cornelledutype',
  'cornelledudeptid1',
  'cornelledudeptname1',
  'uid',
  'sn',
  'givenname',
  'mailalternateaddress',
  'edupersonnickname',
  'cornelledulocaladdress',
);

define('LDAP_ATTRIBUTES', implode(',', $ldap_attributes));

function query_ai($uri) {
  $curl = curl_init();
  curl_setopt_array($curl, array( CURLOPT_URL => AI_API_URL . $uri
  , CURLOPT_USERPWD => AI_USERID . ':' . AI_PWD
  , CURLOPT_ENCODING => 'gzip'
  , CURLOPT_FOLLOWLOCATION => true
  , CURLOPT_POSTREDIR => true
  , CURLOPT_RETURNTRANSFER => true
  ));

  $responseData = curl_exec($curl);

  if (curl_errno($curl)) {
    $errorMessage = curl_error($curl);
    // TODO: Handle cURL error
  } else {
    $statusCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
  }
  curl_close($curl);
  return (object)array("responseData" => $responseData, "statusCode" => $statusCode);
}

function xslt_transform($xml, $xsl, $format='xml') {
  $inputdom =  new DomDocument();
  $inputdom->loadXML($xml);

  $proc = new XSLTProcessor();
  $proc->importStylesheet($xsl);
  $proc->setParameter(null, "", "");
  if ($format == 'xml') {
    return $proc->transformToXML($inputdom);
  } else if ($format == 'doc') {
    return $proc->transformToDoc($inputdom);
  }
}

function stripEmptyCDATA($xml) {
  return preg_replace('/<!\[CDATA\[(<ul class="[^"]+"><\/ul>)+\]\]>/i', '', $xml);
}

function doc_append(&$doc1, $doc2) {
  // get 'Data' element of document 1
  // $data = $doc1->getElementsByTagName('Data')->item(0);

  // iterate over 'item' elements of document 2
  $records = $doc2->getElementsByTagName('Record');
  for ($i = 0; $i < $records->length; $i ++) {
      $record = $records->item($i);

      // import/copy item from document 2 to document 1
      $temp = $doc1->importNode($record, true);

      // append imported item to document 1 'res' element
      $doc1->getElementsByTagName('Data')->item(0)->appendChild($temp);
  }
}

function get_ilr_profiles_transform_xsl($version='default') {
  $xsl = new DOMDocument();
  if ($version != 'default') {
    $xsl->load('alt-transform.xsl');
  } else {
    $xsl->load('digital-measures-faculty-public.xsl');
  }
  return $xsl;
}

function get_ai_departments() {
  $URI = '/SchemaIndex/INDIVIDUAL-ACTIVITIES-University/DEPARTMENT';
  return query_ai($URI);
}

function get_ai_users() {
  $URI = '/User/INDIVIDUAL-ACTIVITIES-University/COLLEGE:School%20of%20Industrial%20and%20Labor%20Relations';
  return query_ai($URI);
}

function get_ai_person($netid) {
  $URI = '/SchemaData/INDIVIDUAL-ACTIVITIES-University/USERNAME:' . $netid;
  $result = query_ai($URI);
  // If not found, try with the netid in upper case. Some records in AI are in this state, and XPath is case-sensitive.
  if ( $result->statusCode != 200 ) {
    $URI = '/SchemaData/INDIVIDUAL-ACTIVITIES-University/USERNAME:' . strtoupper($netid);
    $result = query_ai($URI);
  }
  return $result;
}

function get_ai_record_from_data($xml) {
  $string = str_replace('<?xml version="1.0" encoding="UTF-8"?>', '', $xml);
  $string = preg_replace('/<\/*Data[^>]*>/i', '', $string);
  $string = preg_replace_callback('/(username="[^"]+)/i', function ($matches) { return strtolower($matches[0]); }, $string);
  $string = str_ireplace("<TYPE_OTHER>Selected Works</TYPE_OTHER>", "<TYPE_OTHER>selected works</TYPE_OTHER>", "$string");
  $string = str_ireplace("<TYPE_OTHER>CV</TYPE_OTHER>", "<TYPE_OTHER>cv</TYPE_OTHER>", "$string");

  return $string;
}

function write_all_people_to_file() {
  $users = simplexml_load_string(get_ai_users()->responseData);
  $first = true;
  foreach ($users->User as $user) {
    $person = get_ai_person($user->attributes()->username)->responseData;
    if ($first) {
      $person = preg_replace('/<\/Data>/', '', $person);
      file_put_contents("output/all-people.xml", $person);
      $first = false;
    } else {
      $person = preg_replace('/<\/Data>/', '', $person);
      $person = preg_replace('/<Data [^>]+>/', '', $person);
      $person = preg_replace('/<\?xml [^>]+>/', '', $person);
      file_put_contents("output/all-people.xml", $person, FILE_APPEND);
    }
  }
  file_put_contents("output/all-people.xml", '</Data>', FILE_APPEND);
}

function get_legacy_ilr_directory_info() {
  return file_get_contents(ILR_DIRECTORY_LEGACY_DATA_FEED);
}

function get_ldap_info($filter, $attributes, $start) {
  $ds=ldap_connect(LDAP_SERVER);

  if ($ds) {
    $sr=ldap_search($ds, $start, $filter, $attributes);
    $ret = ldap_get_entries($ds, $sr);
    ldap_close($ds);
      return $ret;
  } else {
    return array();
  }
}

function run_ldap_query($filter) {
  return get_ldap_info($filter, explode(',', LDAP_ATTRIBUTES), LDAP_START);
}

function get_ilr_people_from_ldap() {
  //$ldap_filter = LDAP_FILTER;
  $ldap_filter = '(|(uid=cl672)(uid=vmb2)(uid=hck2)(uid=cjm267)(uid=rss14)(cornelledudeptname1=LIBR - Catherwood*)(&(|(cornelledudeptname1=LIBR - Hospitality, Labor*)(cornelledudeptname1=LIBR - Management Library))(cornelleducampusaddress=Ives Hall*))(cornelledudeptname1=IL-*)(cornelledudeptname1=E-*)(cornelledudeptname1=ILR*)(cornelledudeptname1=CAHRS))';
  if (!strpos($ldap_filter, '(uid=rss14)')) {
    $ldap_filter = str_replace('(uid=hck2)', '(uid=hck2)(uid=rss14)', $ldap_filter);
  }
  return run_ldap_query($ldap_filter);
}

function get_faculty_leave() {
  $handle = fopen("faculty-leave.csv", "r");
  $first_line = true;
  $faculty_leave = Array();
  $leave = Array();
  if ($handle) {
      while (($line = fgets($handle)) !== false) {
        if (!$first_line) {
          array_push($faculty_leave, explode(',', $line));
        }
        $first_line = false;
      }
  }
  fclose($handle);

  foreach($faculty_leave as $faculty) {
    $leave[strtolower($faculty[0])] = Array("leave_start" => $faculty[6], "leave_end" => $faculty[7]);
  }
  return $leave;
}

function get_leave_for_one_faculty($faculty_leave_array, $netid) {
  if (array_key_exists($netid, $faculty_leave_array)) {
    $result = $faculty_leave_array[$netid];
  } else {
    $result = Array("leave_start" => '', "leave_end" => '');
  }
  return $result;
}

function ldap2xml($ldap) {
  $result = array();

  if (count($ldap)) {
    $whiteLabels = array();
    $whiteLabels['displayname'] = "ldap_display_name";
    $whiteLabels['cornelleducampusaddress'] = "ldap_campus_address";
    $whiteLabels['cornelleducampusphone'] = "ldap_campus_phone";
    $whiteLabels['edupersonprincipalname'] = "ldap_email";
    $whiteLabels['cornelleduunivtitle1'] = "ldap_working_title1";
    $whiteLabels['cornelleduwrkngtitle1'] = "ldap_working_title2";
    $whiteLabels['cornelledutype'] = "ldap_employee_type";
    $whiteLabels['cornelledudeptid1'] = "ldap_department";
    $whiteLabels['cornelledudeptname1'] = "ldap_department_name";
    $whiteLabels['uid'] = "ldap_uid";
    $whiteLabels['sn'] = "ldap_last_name";
    $whiteLabels['givenname'] = "ldap_first_name";
    $whiteLabels['mailalternateaddress'] = "ldap_mail_nickname";
    $whiteLabels['edupersonnickname'] = "ldap_nickname";
    $whiteLabels['cornelledulocaladdress'] = "ldap_local_address";

    $faculty_titles = array();
    $faculty_titles[] = 'Extension Associate Sr';
    $faculty_titles[] = 'Lecturer Sr';
    $faculty_titles[] = 'Lecturer Visit';
    $faculty_titles[] = 'Lecturer';
    $faculty_titles[] = 'Prof Assoc';
    $faculty_titles[] = 'Prof Asst';
    $faculty_titles[] = 'Prof Emeritus';
    $faculty_titles[] = 'Prof Leading';
    $faculty_titles[] = 'Prof Visiting';
    $faculty_titles[] = 'Professor';
    $faculty_titles[] = 'Research Associate Sr';
    $faculty_titles[] = 'Research Associate';
    $faculty_titles[] = 'Scholar Visit';

    $temp_faculty = array('lha1', 'gc32', 'ljf8', 'lsg3', 'vmb2', 'zen2', 'srt82', 'so44');
    $deans = array('kfh7', 'ljb239', 'jeg68', 'rss14');
    $faculty_leave = get_faculty_leave();

      $result[] = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
    $result[] = "<Data dmd:date=\"2010-02-23\" xmlns=\"http://www.digitalmeasures.com/schema/data\" xmlns:dmd=\"http://www.digitalmeasures.com/schema/data-metadata\">";

    foreach($ldap AS $person) {
      if (is_array($person) && !empty($person['cornelledutype'][0]) && $person['cornelledutype'][0] != 'alumni') {
        $result[] = "\t<Record username=\"" . $person['uid'][0] . "\">";
        foreach (explode(',', LDAP_ATTRIBUTES) as $attr) {
          if (array_key_exists($attr, $person)) {
            for ($j=0; $j<count($person[$attr])-1; $j++) {
              $suffix = count($person[$attr]) > 2 ? $j + 1 : '';
              $thisVal = trim($person[$attr][$j]);
              if ($attr == 'edupersonprincipalname'
                  && in_array('mailalternateaddress', $person)
                  && ! empty($person['mailalternateaddress'][$j]) ) {
                $thisVal = trim($person['mailalternateaddress'][$j]) . '@cornell.edu';
              }
              if ($attr == 'cornelledudeptname1') {
                switch ($person['cornelledudeptname1'][$j]) {
                  case "Dean's Office":
                    $thisVal = "ILR Dean's Office";
                    break;

                  case 'ILR -  Human Resources':
                    $thisVal = "ILR - Human Resources";
                    break;

                  default:
                    break;
                }
              }
              if ($attr == 'cornelleduwrkngtitle1' && strpos($person['cornelleduwrkngtitle1'][0], 'Temp Serv') !== FALSE) {
                $thisVal = 'Staff';
              }
              if ($thisVal == '-') {
                $thisVal = '';
              }
              if (strlen($thisVal) > 0) {
                $result[] = "\t\t<$whiteLabels[$attr]" . "$suffix>" . htmlspecialchars($thisVal, ENT_QUOTES, "UTF-8") . "</$whiteLabels[$attr]" . "$suffix>";
              } else {
                $result[] = "\t\t<$whiteLabels[$attr]" . "$suffix/>";
              }
            }
          } else {
            $result[] = "\t\t<$whiteLabels[$attr]/>";
          }
        }
        if (in_array($person['uid'][0], $deans)) {
          $profile_type = 'faculty';
        } elseif ($person['cornelledutype'][0] == 'academic' && strpos($person['cornelledudeptid1'][0], 'LIB')) {
          $profile_type = 'librarian';
        } elseif (in_array($person['cornelleduunivtitle1'][0], $faculty_titles)) {
          $profile_type = 'faculty';
        } elseif (in_array($person['uid'][0], $temp_faculty)) {
          $profile_type = 'faculty';
        } else {
          $profile_type = 'staff';
        }
        $result[] = "\t\t<ldap_profile_type>{$profile_type}</ldap_profile_type>";

        $leave = get_leave_for_one_faculty($faculty_leave, $person['uid'][0]);
        $result[] = "\t\t<ldap_leave_start>{$leave['leave_start']}</ldap_leave_start>";
        $result[] = "\t\t<ldap_leave_end>{$leave['leave_end']}</ldap_leave_end>";

        $result[] = "\t</Record>";
      }
      }
      $result[] = "</Data>";
  }
  return join("\n", $result);
}

function new_empty_xml_file($filename) {
  return file_put_contents($filename
  , '<?xml version="1.0" encoding="UTF-8"?>
<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2014-01-14">');
}

function add_log_event(&$log, $message) {
  $time = time();
  $elapsed_time = count($log) > 0 ? $time - $log[count($log) - 1]['time'] : 0;
  $log[] = array(
    'message' => $message,
    'time' => $time,
    'elapsed_time' => $elapsed_time,
  );
  return true;
}

function display_log($log) {
  $result = "";
  foreach ($log as $entry) {
    $result .= date('D j/n/Y', $entry['time']) . ' ' . date('H:i:s', $entry['time']) . ': ' .
      $entry['message'] .
      ($entry['elapsed_time'] > 0 ? " in ({$entry['elapsed_time']} seconds)\n" : "\n");
  }
  $total_time = $log[count($log)-1]['time'] - $log[0]['time'];
  $result .= "\nTotal execution time: {$total_time} seconds.\n";
  return $result;
}

// Write log results to file and also return as string
function log_results(&$aws_Client, $aws_bucket, &$job_log, $job_title) {
  $ip_tracking = !empty($_SERVER['REMOTE_ADDR']) ? "(requested from IP: {$_SERVER['REMOTE_ADDR']})" : '(from local CLI script execution)';
  $job_results = "Results of {$job_title} {$ip_tracking}:\n" . display_log($job_log);
  $log_file_name = 'feed-generator-report-' . date('Y-n-j-H-i-s', time()) . '.txt';
  file_put_contents("s3://{$aws_bucket}/{$log_file_name}", $job_results);
  set_perms($aws_Client, $aws_bucket, $log_file_name);
  return $job_results;
}

// Makes a file in an S3 bucket publicly readable.
function set_perms(&$aws_Client, $bucket, $file_name) {
  $aws_Client->putObjectAcl(array(
    'Bucket'     => $bucket,
    'Key'        => $file_name,
    'ACL'        => 'public-read'
  ));
}

// Deletes a file in an S3 bucket.
function delete_file($aws_bucket, $file_name) {
  if (file_exists("s3://{$aws_bucket}/{$file_name}")) {
    unlink("s3://{$aws_bucket}/{$file_name}");
  }
}

// Repalces a file in an S3 bucket with a new version.
function replace_file(&$aws_Client, $aws_bucket, $file_name, $output) {
  delete_file($aws_bucket, $file_name);
  file_put_contents("s3://{$aws_bucket}/{$file_name}", $output);
  set_perms($aws_Client, $aws_bucket, $file_name);
}

// Functions to write data files

// LDAP to file
function write_ldap_xml_to_file(&$aws_Client, $aws_bucket, &$job_log) {
  $ldap = get_ilr_people_from_ldap();
  replace_file($aws_Client, $aws_bucket, 'ldap.xml', ldap2xml($ldap));
  add_log_event($job_log, "LDAP file created");
  return $ldap;
}

// Legacy ILR directory data to file
function write_legacy_ilr_directory_info_to_file(&$aws_Client, $aws_bucket, &$job_log) {
  $ilrweb_data = get_legacy_ilr_directory_info();
  replace_file($aws_Client, $aws_bucket, 'legacy_ilr_directory_HTML.xml', $ilrweb_data);
  add_log_event($job_log, "Legacy ILR Profile data collected");
}

// Raw AI data to file
function write_raw_ai_data_to_file(&$aws_Client, $aws_bucket, $ldap, &$job_log) {
  delete_file($aws_bucket, "ilr_profiles_raw_ai_data.xml");
  $stream = fopen("s3://{$aws_bucket}/ilr_profiles_raw_ai_data.xml", 'w');

  fwrite($stream, '<?xml version="1.0" encoding="UTF-8"?>
  <Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2014-01-14">');
  $count = 0;
  // For each person returned by the ldap query, Append appropriate xml to xml/ilr_people.xml
  foreach( $ldap as $person) {
    $count += 1;
    if ($person['uid'][0] != '') {
      //   Try to get person info from Activity Insights
      $ai_data = get_ai_person($person['uid'][0]);

      if ( $ai_data->statusCode == 200 ) {  // Activity Insight returned data for this person
        // Add Activity Insight data to the main XML document
        fwrite($stream, get_ai_record_from_data($ai_data->responseData));
      } else {
        // Add a placeholder Record to the main XML document with the userid
        fwrite($stream, '<Record username="' . $person['uid'][0] . '" noaidata="true" />');
      }
    }
  }

  fwrite($stream, '<recordcount>' . $count . '</recordcount></Data>');
  fclose($stream);
  set_perms($aws_Client, $aws_bucket, 'ilr_profiles_raw_ai_data.xml');
  add_log_event($job_log, "Raw Activity Insight data collected");
}

// Aggregated and transformed data to file
function write_aggregated_ai_data_to_file(&$aws_Client, $aws_bucket, &$job_log, $version='default', $output_file='ilr_profiles_feed.xml') {
  // Retrieve to XML
  $raw_xml = file_get_contents("s3://{$aws_bucket}/ilr_profiles_raw_ai_data.xml");

  // Run the XSLT transform on the main xml file, which will fold in the fields from lpad and legacy_ilr_directory_HTML
  replace_file($aws_Client, $aws_bucket, $output_file, stripEmptyCDATA(xslt_transform($raw_xml, get_ilr_profiles_transform_xsl($version), 'xml')));
  add_log_event($job_log, "Final ILR Profiles data feed generated");
}
