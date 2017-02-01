<?php

/* !
 * FONTE        : db_busca_cidades.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 07/06/2016
 * OBJETIVO     : Rotina para buscar a lista das cidades conforme a UF selecionada e 
 *				  configurar o campo select da tela
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
$cdcoopel = 0;

// Recebe os parametros
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;

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


if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml dinâmico de acordo com a operação 
$xml = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "	<cdcooper>" . $cdcoopel . "</cdcooper>";
$xml .= "	<nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "	<nrctremp>" . $nrctremp . "</nrctremp>";
$xml .= "	<cddopcao>" . $cddopcao . "</cddopcao>";
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "IMOVEL", "BUSCA_IMOVEIS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
$xmlObjeto 	= getObjectXML($xmlResult);	
	
	
// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
	exibirErro('error',$msgErro,'Alerta - Ayllos','cNrdconta.focus();',false);
} 
	
$cidades  = $xmlObjeto->roottag->tags;
echo "cIdseqbem.html(\"\");";

echo "add_imovel_tela(0,\"\");";

foreach($cidades as $c) {
	echo "add_imovel_tela(" . $c->tags[0]->cdata . ",\"" . $c->tags[1]->cdata . "\");";
}
 
echo "cIdseqbem.focus();";
echo "hideMsgAguardo();";
	
?>