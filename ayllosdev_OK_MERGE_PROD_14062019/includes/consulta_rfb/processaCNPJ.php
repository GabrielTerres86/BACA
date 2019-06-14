<?php
/*!
 * FONTE        : processaCNPJ.php
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
	$nrcpfcgc = preg_replace('(\.|\/|\-)','',$_POST['nrcpfcgc']);
	 
	 
	// pega html resposta da receita
	$getHtmlCNPJ = getHtmlCNPJ($nrcpfcgc, $dscaptch);
	 
	if($getHtmlCNPJ) {
		// volova os dados em um array
		$campos = parseHtmlCNPJ($getHtmlCNPJ);
		echo $campos;
	} 
	
?>