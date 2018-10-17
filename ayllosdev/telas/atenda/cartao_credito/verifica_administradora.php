<?php

/*************************************************************************
	Fonte: alterar_desconto.php
	Autor: André Clemer - Supero			Ultima atualizacao: --/--/----
	Data : Julho/2018
	
	Objetivo: Ativar desconto.
	
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

$cdadmcrd = ( (!empty($_POST['cdadmcrd'])) ? $_POST['cdadmcrd'] : 0 );

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <cdadmcrd>".$cdadmcrd."</cdadmcrd>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADA0004", "VERIFICA_ADM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

$xmlDados = $xmlObject->roottag->tags[0];

if (strtoupper($xmlDados->tags[0]->name) == 'ERRO') {
    $msgErro = $xmlDados->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlDados->tags[0]->cdata;
    }

    exibirErro('error',$msgErro,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
    
}else{
    $administradora = getByTagName($xmlDados, "Administradora");
    echo json_encode(array('administradora' => $administradora));
}
