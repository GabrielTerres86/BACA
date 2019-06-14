<? 
/*!
 * FONTE        : busca_detalhes_faixa.php
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 03/12/2015
 * OBJETIVO     : Rotina para buscar dados da tela FAIRRF
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$cdfaixa = (isset($_POST['cdfaixa'])) ? $_POST['cdfaixa'] : 0;
	$cddopdet = (isset($_POST['cddopdet'])) ? $_POST['cddopdet'] : 0;
	
	include('form_detalhes_faixa.php');
    
?>