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
	$idcomissao = (isset($_POST['idcomissao'])) ? $_POST['idcomissao'] : 0;
	$cddopdet = (isset($_POST['cddopdet'])) ? $_POST['cddopdet'] : 0;

    include('form_detalhe_comissao.php');

?>