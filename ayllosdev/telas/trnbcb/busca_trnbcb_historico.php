<? 
/*!
 * FONTE        : busca_trnbcb_historico.php
 * CRIA��O      : Lucas Ranghetti
 * DATA CRIA��O : 20/01/2016
 * OBJETIVO     : Rotina para busca do vinculo da transacao com historico.
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
	$cddtrans = (isset($_POST['cddtrans'])) ? $_POST['cddtrans'] : 0;
	$cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : '';
	$dshistor = (isset($_POST['dshistor'])) ? $_POST['dshistor'] : '';
	$dsctrans = $_POST['dsctrans'];
	$tphistor = $_POST['cdtiptrn'];
	$opcao    = $_POST['cddopcao'];
	
	include('form_vinculo_historico.php');

?>