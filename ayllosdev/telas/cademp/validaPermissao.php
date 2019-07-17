<?
/*!
 * FONTE        : validaPermissao.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 06/03/2017
 * OBJETIVO     : Validar permissão das opções da tela
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
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> ''){
		echo 'showError("error","'.$msgError.'","Alerta - Ayllos","estadoInicial();");';
		$js .= 'validaPerm = false;';
		echo $js;
		return;
	}
?>