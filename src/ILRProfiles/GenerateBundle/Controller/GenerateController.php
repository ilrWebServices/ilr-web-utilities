<?php

namespace ILRProfiles\GenerateBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class GenerateController extends Controller
{
    public function indexAction($uid='')
    {
        require 'inc/ilr-faculty-data-conf.php';
        $start_time = time();
        require 'inc/get_all_data_use_aws.php';
        $total_time = time() - $start_time;
        return $this->render('ILRProfilesGenerateBundle:Generate:index.html.twig', array('time' => $total_time));
    }
}
