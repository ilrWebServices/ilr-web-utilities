<?php

namespace ILRProfiles\GenerateBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class GenerateController extends Controller
{
    public function indexAction($uid='')
    {
        require 'inc/ilr-faculty-data.php';

        add_log_event($job_log, "Job begun");
        $ldap = write_ldap_xml_to_file($client, $aws_bucket, $job_log);
        write_legacy_ilr_directory_info_to_file($client, $aws_bucket, $job_log);
        write_raw_ai_data_to_file($client, $aws_bucket, $ldap, $job_log);
        write_aggregated_ai_data_to_file($client, $aws_bucket, $job_log);
        $job_results = log_results($client, $aws_bucket, $job_log, "aggregation and XSL transformation of all ILR faculty and staff profile data");

        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('job_results' => $job_results));
    }

    public function generateLdapAction()
    {
        require 'inc/ilr-faculty-data.php';

        add_log_event($job_log, "Job begun");
        write_ldap_xml_to_file($client, $aws_bucket, $job_log);
        $job_results = log_results($client, $aws_bucket, $job_log, "collection of ILR LDAP data");

        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('job_results' => $job_results));
    }

    public function generateLegacyAction()
    {
        require 'inc/ilr-faculty-data.php';

        add_log_event($job_log, "Job begun");
        write_legacy_ilr_directory_info_to_file($client, $aws_bucket, $job_log);
        $job_results = log_results($client, $aws_bucket, $job_log, "collection of legacy website data");

        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('job_results' => $job_results));
    }

    public function generateRawAiAction()
    {
        require 'inc/ilr-faculty-data.php';

        add_log_event($job_log, "Job begun");
        write_raw_ai_data_to_file($client, $aws_bucket, $job_log);
        $job_results = log_results($client, $aws_bucket, $job_log, "collection of raw Activity Insight");

        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('job_results' => $job_results));
    }

    public function retransformAction()
    {
        require 'inc/ilr-faculty-data.php';

        add_log_event($job_log, "Job begun");
        write_aggregated_ai_data_to_file($client, $aws_bucket, $job_log);
        $job_results = log_results($client, $aws_bucket, $job_log, "XSL re-transformation only of exisitng profile data for all ILR faculty and staff");

        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('job_results' => $job_results));
    }

    public function retransformWithAltXslAction()
    {
        require 'inc/ilr-faculty-data.php';

        add_log_event($job_log, "Job begun");
        write_aggregated_ai_data_to_file($client, $aws_bucket, $job_log, 'alt', 'ilr_profiles_alternate.xml');
        $job_results = log_results($client, $aws_bucket, $job_log, "XSL re-transformation only of exisitng profile data using alternate XSLT");

        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('job_results' => $job_results));
    }

    public function dumpConstantsAction()
    {
        require 'inc/ilr-faculty-data-conf.php';
        $job_results =
        'AI_API_URL: ' . AI_API_URL . "\n" .
        'LDAP_START: ' . LDAP_START . "\n" .
        'LDAP_FILTER: ' . LDAP_FILTER . "\n" .
        'ILR_DIRECTORY_LEGACY_DATA_FEED: ' . ILR_DIRECTORY_LEGACY_DATA_FEED . "\n";
        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('job_results' => $job_results));
    }

    public function ldapQueryAction($filter='')
    {
        require 'inc/ilr-faculty-data.php';
        $job_results = ldap2xml(run_ldap_query($filter));
        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('job_results' => $job_results));
    }
}
