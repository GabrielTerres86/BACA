<?php
/************************************************************************
Fonte     : grava_conciliacao.php
Autor     : André Clemer
Data      : Abril/2018                 Última alteração: --/--/----
Objetivo  : Script para efetuar conciliação manual
Alterações: 

	08/07/2019 - Alterações referetentes a RITM13002 (Daniel Lombardi - Mout'S)
************************************************************************/

session_start();	
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');		
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();		

// Carrega permissões do operador
require_once('../../includes/carrega_permissoes.php');		

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> '') {		
    exibirErro('error',$msgError,'Alerta - Ayllos','',false);
}
    
// Se parametros necessarios nao foram informados
if (empty($_POST["idsTitulo"]) || empty($_POST["idlancto"])) {
    exibirErro('error',"Par&acirc;metros incorretos.",'Alerta - Ayllos','',false);
}	

$idsTitulo = $_POST["idsTitulo"];
$idlancto  = $_POST["idlancto"];

// Monta o xml de requisição
$xml   = "";
$xml  .= "<Root>";
$xml  .= "  <Dados>";
$xml  .= "    <idlancto>";
foreach($idlancto as $idted) {
$xml  .= "      <IdTed>{$idted}</IdTed>";
}
$xml  .= "    </idlancto>";
$xml  .= "    <Titulos>";
foreach($idsTitulo as $id) {
$xml  .= "      <Id>{$id}</Id>";
}
$xml  .= "    </Titulos>";
$xml  .= "  </Dados>";
$xml  .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xml, "TELA_MANPRT", "GERA_CONCILIACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	exibirErro('error',utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
}

exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','realizaoConsultaTed(nriniseq, nrregist);fechaRotina($(\'#divRotina\'));$(\'#divRotina\').html(\'\');', false);