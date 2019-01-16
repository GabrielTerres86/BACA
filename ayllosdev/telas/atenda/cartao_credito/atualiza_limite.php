<?php

/*************************************************************************
	Fonte: atualiza_limite.php
	Autor: Augusto - Supero			Ultima atualizacao: --/--/----
	Data : Setembro/2018
	
	Objetivo: Atualiza a proposta de alteração de limite
	
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
$insitdec = ( (!empty($_POST['insitdec'])) ? $_POST['insitdec'] : 0 );
$tpsituacao = ( (!empty($_POST['tpsituacao'])) ? $_POST['tpsituacao'] : 0 );
$vllimite_anterior = ( (!empty($_POST['vllimite_anterior'])) ? $_POST['vllimite_anterior'] : 0 );
$vllimite_alterado = ( (!empty($_POST['vllimite_alterado'])) ? $_POST['vllimite_alterado'] : 0 );
$dsjustificativa = ( (!empty($_POST['dsjustificativa'])) ? $_POST['dsjustificativa'] : '' );
$dsiduser = session_id();

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
$xml .= "   <insitdec>".$insitdec."</insitdec>";
$xml .= "   <tpsituacao>".$tpsituacao."</tpsituacao>";
$xml .= "   <vllimite_anterior>".$vllimite_anterior."</vllimite_anterior>";
$xml .= "   <vllimite_alterado>".$vllimite_alterado."</vllimite_alterado>";
$xml .= "   <dsjustificativa>".$dsjustificativa."</dsjustificativa>";
$xml .= "   <dsiduser>".$dsiduser."</dsiduser>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA_CRD", "ATUALIZA_LIMITE_CRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

$xmlDados = $xmlObject->roottag->tags[0];

if (strtoupper($xmlDados->name) == 'ERRO') {
    $msgErro = $xmlDados->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlDados->tags[0]->cdata;
    }

    exibirErro('error',$msgErro,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
    
}else{
    echo "showError('inform','Solicita&ccedil;&atilde;o enviada para esteira com sucesso.','Alerta - Ayllos','voltarParaTelaPrincipal();');";
}
