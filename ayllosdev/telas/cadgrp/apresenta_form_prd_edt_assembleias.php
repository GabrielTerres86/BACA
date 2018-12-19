<?php  
	/*********************************************************************
	 Fonte: apresenta_form_prd_edt_assembleias.php.php                                                 
	 Autor: Jonata - Mouts
	 Data : Setembro/2018                 Última Alteração: 
	                                                                  
	 Objetivo  : Mostrar o form da opcao E                                
	                                                                  
	 Alterações: 
	 
	 
	
	**********************************************************************/
	
?>

<?php
	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$rowid               = (isset($_POST["rowid"])) ? $_POST["rowid"] : '';
	$nrano_exercicio     = (isset($_POST["nrano_exercicio"])) ? $_POST["nrano_exercicio"] : '';
	$dtinicio_grupo      = (isset($_POST["dtinicio_grupo"])) ? $_POST["dtinicio_grupo"] : '';
	$dtfim_grupo         = (isset($_POST["dtfim_grupo"])) ? $_POST["dtfim_grupo"] : '';
	$ope                 = (isset($_POST["ope"])) ? $_POST["ope"] : '';
	
	include("form_periodo_edital_assembleias.php");
	
	?>
	

	




