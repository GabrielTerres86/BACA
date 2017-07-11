<? 
/*!
 * FONTE        : busca_atribuicao_detalhamento.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 05/03/2013
 * OBJETIVO     : Rotina para busca do detalhamento de tarifa.
 * -------------------------
 * ALTERAÇÕES   : 02/08/2013 - Incluso tratamento para registros
 *							   de cobranca (Daniel).
 *
 *				  11/07/2017 - Inclusao das novas colunas e campos "Tipo de tarifacao", "Percentual", "Valor Minimo" e 
 *                             "Valor Maximo" (Mateus - MoutS)
 *
 * -------------------------
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
	$cddopfco = (isset($_POST['cddopfco'])) ? $_POST['cddopfco'] : '';	
	$cdtarifa = (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0;
	$dstarifa = (isset($_POST['dstarifa'])) ? $_POST['dstarifa'] : '';
	$vlinifvl2 = (isset($_POST['vlinifvl2'])) ? $_POST['vlinifvl2'] : 0;
	$vlfinfvl2 = (isset($_POST['vlfinfvl2'])) ? $_POST['vlfinfvl2'] : 0;
	$cdfvlcop  = (isset($_POST['cdfvlcop'])) ? $_POST['cdfvlcop'] : 0;	
	$nrconven  =  (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0;	
	$cdtipcat  = (isset($_POST['cdtipcat'])) ? $_POST['cdtipcat'] : 0;	
	
	$cdlcremp  =  (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : 0;	
	
	if ( $cddopfco != 'I') {
		//$cdfvlcop --> pegar proximo codigo aqui
		$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '';	
		$dtdivulg = (isset($_POST['dtdivulg'])) ? $_POST['dtdivulg'] : '';
		$dtvigenc = (isset($_POST['dtvigenc'])) ? $_POST['dtvigenc'] : '';
		$vltarifa = (isset($_POST['vltarifa'])) ? $_POST['vltarifa'] : 0;
		$vlrepass = (isset($_POST['vlrepass'])) ? $_POST['vlrepass'] : 0;
		$nmrescop = (isset($_POST['nmrescop'])) ? $_POST['nmrescop'] : '';
		$dsconven = (isset($_POST['dsconven'])) ? $_POST['dsconven'] : '';
		$tpcobtar = (isset($_POST['tpcobtar'])) ? $_POST['tpcobtar'] : '';
		$vlpertar = (isset($_POST['vlpertar'])) ? $_POST['vlpertar'] : '';
		$vlmintar = (isset($_POST['vlmintar'])) ? $_POST['vlmintar'] : '';
		$vlmaxtar = (isset($_POST['vlmaxtar'])) ? $_POST['vlmaxtar'] : '';
		
		$dslcremp = (isset($_POST['dslcremp'])) ? $_POST['dslcremp'] : '';
	}
	
	include('form_atribuicao_detalhamento.php');

?>
