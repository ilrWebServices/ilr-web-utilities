<?php

namespace ILRProfiles\GenerateBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

class GetProfileDataController extends Controller
{
    public function indexAction($uid='')
    {
        header("Location: https://s3.amazonaws.com/{$this->container->getParameter('aws_bucket')}/ilr_profiles_feed.xml");
        exit;
    }
}
