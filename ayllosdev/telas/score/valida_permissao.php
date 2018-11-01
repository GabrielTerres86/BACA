<?php
	/*!
	 * FONTE        : val_permis.php
	 * CRIAÇÃO      : Diogo Ferreira - Envolti
	 * DATA CRIAÇÃO : setembro/2018
	 * OBJETIVO     : Validar permição do botão
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		

  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao('ATENDA','',$cddopcao, false)) <> '') {
		//exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		echo $msgError;
	}
		
?>
