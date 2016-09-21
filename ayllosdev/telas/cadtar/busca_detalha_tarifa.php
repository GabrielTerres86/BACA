<? 
/*!
 * FONTE        : busca_detalha_tarifa.php
 * CRIA��O      : Daniel Zimmermann
 * DATA CRIA��O : 05/03/2013
 * OBJETIVO     : Rotina para busca do detalhamento de tarifa.
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	
	// Guardo os par�metos do POST em vari�veis	
	$cdfaixav = (isset($_POST['cdfaixav'])) ? $_POST['cdfaixav'] : 0;
	$cdtarifa = (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0;
	$cddopdet = (isset($_POST['cddopdet'])) ? $_POST['cddopdet'] : 0;

	include('form_detalha_tarifa.php');

?>