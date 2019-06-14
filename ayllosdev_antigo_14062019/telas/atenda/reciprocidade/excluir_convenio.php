<?php

/*************************************************************************
	Fonte: incluir_desconto.php
	Autor: André Clemer - Supero			Ultima atualizacao: --/--/----
	Data : Agosto/2018
	
	Objetivo: Valida exclusão do convênio.
	
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

$nrdconta = ( (!empty($_POST['nrdconta'])) ? $_POST['nrdconta'] : $glbvars['nrdconta'] );
$nrconven = ( (!empty($_POST['nrconven'])) ? $_POST['nrconven'] : 0 );
$idrecipr = ( (!empty($_POST['idrecipr'])) ? $_POST['idrecipr'] : '' );

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <idrecipr>".$idrecipr."</idrecipr>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "VALIDA_EXCLUSAO_CONVENIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);
$xmlDados = $xmlObject->roottag;

$insitceb = getByTagName($xmlDados->tags,"INSITCEB");
$qtbolcob = getByTagName($xmlDados->tags,"QTBOLCOB");
$qtcebati = getByTagName($xmlDados->tags,"QTCEBATI");

if (strtoupper($xmlDados->tags[0]->name) == 'ERRO') {
    $erro = $xmlDados->tags[0]->tags[0]->tags[4];
    if ($erro->cdata == "") {
        $erro = $xmlDados->tags[0];
    }
    $cdcritic = getByTagName($erro->parent->tags,"CDCRITIC");

    if ($cdcritic != '0') {
        exibirErro('error',$erro->cdata,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);

    } elseif ($cdcritic == '0') {   // erro informando boletos já cadastrados
        echo "hideMsgAguardo();showConfirmacao('Existem boletos cadastrados para este convenio CEB. Deseja inativar o conv&ecirc;nio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'inativarConvenio($nrconven)', 'blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))', 'sim.gif', 'nao.gif');";
    }
    
}else{
    echo "hideMsgAguardo();showConfirmacao('Confirma a exclus&atilde;o do conv&ecirc;nio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirConvenio($nrconven)', 'blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")))', 'sim.gif', 'nao.gif');";
}
