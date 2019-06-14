<?php

require('funcoes.php');
/*
$cnpj = $_POST['CNPJ'];
$captcha = $_POST['CAPTCHA'];
*/
$captcha = $_POST['dscaptch'];
$cnpj = preg_replace('(\.|\/|\-)','',$_POST['nrcpfcgc']);

// pega html resposta da receita
$getHtmlCNPJ = getHtmlCNPJ($cnpj, $captcha);

if($getHtmlCNPJ){
	// volova os dados em um array
	$campos = parseHtmlCNPJ($getHtmlCNPJ);
	echo json_encode($campos);
}else{
	echo json_encode(array(
	    'error' => array(
	        'msg' => 'falha ao tentar recuperar as informações',
	        'code' => 'XXXXX',
	    ),
	));
}
?>