<?php

/* !
 * FONTE        : db_busca_emprestimos.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 07/06/2016
 * OBJETIVO     : Rotina para buscar os dados dos emprestimos
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Inicializa
$retornoAposErro = '';
$nmprimtl = '';
$cdcoopel = 0;

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;

// Se for a opção X
if ($cddopcao == 'X') {
    $cdcoopel = (isset($_POST['cdcooptl'])) ? $_POST['cdcooptl'] : 0;

	// Se não foi informado a cooperativa
	if ($cdcoopel == 0) {
		exibirErro('error', 'Cooperativa deve ser selecionada.', 'Alerta - Ayllos', 'cCdcooper.focus();', false);
	}
} else {
	$cdcoopel = $glbvars['cdcooper'];
}

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao,false)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml dinâmico de acordo com a operação 
$xml = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "   <cdcooper>" . $cdcoopel . "</cdcooper>";
$xml .= "	<nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "	<cddopcao>" . $cddopcao . "</cddopcao>";
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "IMOVEL", "BUSCA_ASS_EPR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");	
$xmlObjeto 	= getObjectXML($xmlResult);	
	
	
// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
	exibirErro('error',$msgErro,'Alerta - Ayllos','cNrdconta.focus();',false);
} 
	
$nmprimtl	= $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
$registros  = $xmlObjeto->roottag->tags;
echo "cNmprimtl.val('" . $nmprimtl . "');";
echo "cContaAux.val('" . $nrdconta . "');";  // Servirá para controle na tela
echo "cNrctremp.html(\"\");";

foreach($registros as $i) {

	$indice = 0;
	
	if ($i->tags[1]->cdata != 0) {
		echo "add_contrato_tela(" . $i->tags[1]->cdata . ");";
		$indice = $indice + 1;
	}
}

echo "hideMsgAguardo();";
	
?>