<?php

namespace ILRProfiles\GenerateBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class GenerateController extends Controller
{
    public function indexAction($uid='')
    {
        require 'inc/ilr-faculty-data-conf.php';
        require 'inc/get_all_data_use_aws.php';
        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('job_results' => $job_results));
    }

    public function retransformAction()
    {
        require 'inc/ilr-faculty-data-conf.php';
        require 'inc/perform_final_xslt_transform.php';
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
}
