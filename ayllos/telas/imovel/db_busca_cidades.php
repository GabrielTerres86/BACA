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

// Recebe os parametros
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$cdestado = (isset($_POST['cdestado'])) ? $_POST['cdestado'] : 0;
$dscidade = (isset($_POST['dscidade'])) ? $_POST['dscidade'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml dinâmico de acordo com a operação 
$xml = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "	<cdestado>" . $cdestado . "</cdestado>";
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "IMOVEL", "BUSCA_CIDADES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
$xmlObjeto 	= getObjectXML($xmlResult);	
	
	
// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
	exibirErro('error',$msgErro,'Alerta - Ayllos','cNrdconta.focus();',false);
} 
	
$cidades  = $xmlObjeto->roottag->tags;
echo "cCdcidade.html(\"\");";
echo "add_cidade_tela(\"\", \"\");";

foreach($cidades as $c) {
    if (strtoupper($c->tags[1]->cdata) == strtoupper($dscidade)) {
		echo "cdcidade = " . $c->tags[0]->cdata . ";";
	} 
	echo "add_cidade_tela(" . $c->tags[0]->cdata . ",\"" . $c->tags[1]->cdata . "\");";
}

echo "hideMsgAguardo();";
	
?>