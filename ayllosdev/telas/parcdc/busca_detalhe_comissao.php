<? 
/*!
 * FONTE        : busca_detalhe_comissao.php
 * CRIAวรO      : Diego Simas
 * DATA CRIAวรO : 30/04/2018
 * OBJETIVO     : Rotina para busca do detalhamento de comissão.
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	// Guardo os parโmetos do POST em variáveis	
	$cdfaixav = (isset($_POST['cdfaixav'])) ? $_POST['cdfaixav'] : 0;
	$cdcomissao = (isset($_POST['cdcomissao'])) ? $_POST['cdcomissao'] : 0;
	$cddopdet = (isset($_POST['cddopdet'])) ? $_POST['cddopdet'] : 0;

	//include('form_detalha_tarifa.php');
    include('form_detalhe_comissao.php');

?>