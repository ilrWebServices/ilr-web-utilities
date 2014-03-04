<?php

require 'ilr-faculty-data.php';

if (! verify_configuration()) {
  echo "Error: Please ensure a complete configuration has been supplied for ilr-faculty-data.php.";
  exit();
}

/* Build the feed of profiles from all data sources. */

if (! file_exists('xml')) {
  mkdir('xml');
}

$ldap = get_ilr_people_from_ldap();
file_put_contents("xml/ldap.xml", ldap2xml($ldap));

$ilrweb_data = get_legacy_ilr_directory_info();
file_put_contents("xml/legacy_ilr_directory_HTML.xml", $ilrweb_data);

new_empty_xml_file('xml/ilr_people.xml');

// For each person returned by the ldap query, Append appropriate xml to xml/ilr_people.xml
foreach( $ldap as $person) {
  if ($person['uid'][0] != '') {
    //   Try to get person info from Activity Insights
    $ai_data = get_ai_person($person['uid'][0]);

    if ( $ai_data->statusCode == 200 ) {  // Activity Insight returned data for this person
      // Add Activity Insight data to the main XML document
      file_put_contents('xml/ilr_people.xml', get_ai_record_from_data($ai_data->responseData), FILE_APPEND);
    } else {
      // Add a placeholder Record to the main XML document with the userid
      file_put_contents('xml/ilr_people.xml', '<Record username="' . $person['uid'][0] . '" />', FILE_APPEND);
    }
  }
}

// Close the Data tag in the main xml file
file_put_contents('xml/ilr_people.xml', '</Data>', FILE_APPEND);

// Run the XSLT transform on the main xml file, which will fold in the fields from lpad and legacy_ilr_directory_HTML
$raw_xml = file_get_contents('xml/ilr_people.xml');
$transformed_xml = 'xml/ilr_profiles_feed.xml';
file_put_contents($transformed_xml, stripEmptyCDATA(xslt_transform($raw_xml, get_ilr_profiles_transform_xsl(), 'xml')));
