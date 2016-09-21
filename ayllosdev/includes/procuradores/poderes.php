<?
/*!
 * FONTE        : poderes.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 04/07/2013 
 * OBJETIVO     : Exibe rotina de Poderes
 *
 * ALTERACOES   : 
 */	
?>
 
<?
	setVarSession("opcoesTela",$opcoesTela);		
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	$nrdctato = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
	include('busca_poderes.php');
?>