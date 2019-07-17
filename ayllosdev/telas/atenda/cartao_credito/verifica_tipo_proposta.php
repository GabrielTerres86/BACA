<?php

/*************************************************************************
	Fonte: verifica_tipo_proposta.php
	Autor: Augusto - Supero			Ultima atualizacao: --/--/----
	Data : Setembro/2018
	
	Objetivo: Verificar o tipo de uma proposta
	
	Alteracoes: 

*************************************************************************/

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");	

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
	exibirErro('error',$msgError,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
}

$nrdconta = ( (!empty($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 );
$nrctrcrd = ( (!empty($_POST['nrctrcrd'])) ? $_POST['nrctrcrd'] : 0 );

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA_CRD", "VERIFICA_PROPOSTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

$xmlDados = $xmlObject->roottag->tags[0];

if (strtoupper($xmlDados->name) == 'ERRO') {
    $msgErro = $xmlDados->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlDados->tags[0]->cdata;
    }

    exibirErro('error',$msgErro,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
    
}else{
    $tipoProposta = getByTagName($xmlDados, "TipoProposta");
    if ($tipoProposta == 1) {
        echo "globalesteira = true; alterarCartaoProposta();";
    } else if ($tipoProposta == 2) {
        echo "alterarLimiteProposta();";
    } else {
        showError("error", "Edicao de proposta nao permitida.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
    }
}
