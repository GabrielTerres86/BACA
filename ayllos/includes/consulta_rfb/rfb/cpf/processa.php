<?php

require('funcoes.php');

/*$CPF = $_POST['CPF'];
$DATA = $_POST['DATA'];
$captcha = $_POST['CAPTCHA'];*/

$CPF = $_POST['nrcpfcgc'];
$DATA = $_POST['dtnasctl'];
$captcha = $_POST['dscaptch'];

// pega html resposta da receita
$getHtmlCPF = getHtmlCPF($CPF, $DATA, $captcha);

if($getHtmlCPF)
{
	// volova os dados em um array
	$campos = parseHtmlCPF($getHtmlCPF);
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