<?php
  require_once('../../includes/config.php');
  require_once('../../includes/funcoes.php');
  require_once("class_rest_analise.php");

  $oRestAnalise = new RestAnalise();
  $oRestAnalise->processaRequisicao();
?>
