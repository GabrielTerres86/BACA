<?php
/*!
 * FONTE        : processaCPF.php
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 04/09/2015 
 * OBJETIVO     : Funcoes da CONSULTA A RECEITA FEDERAL
 *
 * ALTERACOES   :
 */
?>
<?
	require('funcoes.php');
	 
	$dscaptch = $_POST['dscaptch'];
	$nrcpfcgc = $_POST['nrcpfcgc'];
	$dtnasctl = $_POST['dtnasctl'];
	  		 
	// pega html resposta da receita
	$getHtmlCPF = getHtmlCPF($nrcpfcgc, $dtnasctl, $dscaptch);

	if($getHtmlCPF) {
		// Voltar os dados em um array
		$campos = parseHtmlCPF($getHtmlCPF);
		echo $campos;
	} 
	
	 
?>