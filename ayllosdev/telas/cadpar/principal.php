<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 07/03/2013
 * OBJETIVO     : Capturar dados para tela CADPAR
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
	
	// Recebe o POST
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdpartar = (isset($_POST['cdpartar'])) ? $_POST['cdpartar'] : 0  ;
	$nmpartar = (isset($_POST['nmpartar'])) ? $_POST['nmpartar'] : '' ;
	$tpdedado = (isset($_POST['tpdedado'])) ? $_POST['tpdedado'] : 0  ;

	include('form_cabecalho.php');	
	include('tab_cadpar.php');
	
?>
<script type='text/javascript'>	
	$('#cddopcao','#frmCab').desabilitaCampo();
	$('#nmpartar','#frmCab').desabilitaCampo();
	$('#cdpartar','#frmCab').desabilitaCampo();
	$('#tpdedado','#frmCab').desabilitaCampo();
</script>

