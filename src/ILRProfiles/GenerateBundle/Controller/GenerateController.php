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
}
