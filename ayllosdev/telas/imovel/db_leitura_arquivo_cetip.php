<?php

/* !
 * FONTE        : db_leitura_arquivo_cetip.php
 * CRIAÇÃO      : Renato Darosci (Supero)
 * DATA CRIAÇÃO : 26/07/2016
 * OBJETIVO     : Rotina para gravar a baixa manual do imóvel
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

if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $cddopcao)) <> '') {
    exibirErro('error', $msgError, 'Alerta - Ayllos', '', false);
}

// Monta o xml dinâmico de acordo com a operação 
$xml = "";
$xml .= "<Root>";
$xml .= "  <Dados>";
$xml .= "	<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
$xml .= "  </Dados>";
$xml .= "</Root>";

// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult = mensageria($xml, "IMOVEL", "LEITURA_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
$xmlObjeto 	= getObjectXML($xmlResult);	
		
// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
	exibirErro('error',$msgErro,'Alerta - Ayllos','cCdcooper.focus();',false);
} 

echo "hideMsgAguardo();";
	
?>
