<?php

ini_set('display_errors',1);
ini_set('display_startup_erros',1);
error_reporting(E_ALL);


  require_once('../../includes/config.php');
  require_once('../../includes/funcoes.php');
  require_once("class_rest_cartao.php");

  $oRestCartao = new RestCartao();
  $oRestCartao->processaRequisicao();
  
?>