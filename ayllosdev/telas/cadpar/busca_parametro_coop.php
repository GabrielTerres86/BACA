<? 
/*!
 * FONTE        : busca_parametro_coop.php
 * CRIA��O      : Daniel Zimmermann
 * DATA CRIA��O : 05/03/2013
 * OBJETIVO     : Rotina para busca parametro por cooperativa.
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
	$cdpartar = (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : 0;
	$nmpartar = (isset($_POST['nmpartar'])) ? $_POST['nmpartar'] : '';
	$tpdedado = (isset($_POST['tpdedado'])) ? $_POST['tpdedado'] : '';
	$opcao = (isset($_POST['opcao'])) ? $_POST['opcao'] : '';
	
	include('form_parametro_coop.php');

?>