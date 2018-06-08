<?
/*!
 * FONTE        : processa_leitura_cartao_chip.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Junho/2014
 * OBJETIVO     : Processa os dados de leitura do cartao com Chip
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	require_once('class_leitura_cartao_chip.php');
	isPostMethod();	

	$oLeituraCartaoEmv = new LeituraCartaoChip();	
	$oLeituraCartaoEmv->setPortador($_POST['tagPortador']);
	$oLeituraCartaoEmv->setNumeroCartao($_POST['tagNumeroCartao']);
	$oLeituraCartaoEmv->setDataValidade($_POST['tagDataValidade']);
	
	echo '$("#repsolic","#frmEntregaCartaoBancoob").val("'.$oLeituraCartaoEmv->getPortador().'");';
	echo '$("#nrcrcard","#frmEntregaCartaoBancoob").val("'.$oLeituraCartaoEmv->getNumeroCartao().'");';
	echo '$("#nrcarfor","#frmEntregaCartaoBancoob").val("'.$oLeituraCartaoEmv->getNumeroCartaoFormatado().'");';
	echo '$("#dtvalida","#frmEntregaCartaoBancoob").val("'.$oLeituraCartaoEmv->getDataValidade().'");';
?>