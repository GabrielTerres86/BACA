<?php

/*************************************************************************
	Fonte: ativar_convenio.php
	Autor: Odirlei Busana - AMcom			Ultima atualizacao: 26/04/2016
	Data : Abril/2016
	
	Objetivo: Ativar convenio CEB.
	
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
	exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
}	

$nrdconta = $_POST["nrdconta"];
$nrconven = $_POST["nrconven"];
$nrcnvceb = $_POST["nrcnvceb"];
$flgregis = trim($_POST["flgregis"]);


// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= "   <nrcnvceb>".$nrcnvceb."</nrcnvceb>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "ATIVAR_CONVENIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    $msgError = utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
    exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
    
}else{
    
    echo 'hideMsgAguardo();';
    // atualizar status para ativo
    echo '$("#insitceb", "#divConteudoOpcao").val("1"); '; 
    echo '$("#insitceb", "#divAba0").val("1"); '; 
    
	$xmlDados = $xmlObject->roottag->tags[0];
    $dsdmesag = getByTagName($xmlDados->tags,"DSDMESAG");
	$flgimpri = getByTagName($xmlDados->tags,"FLGIMPRI");
    
    echo 'showError("inform",
                    "'.$dsdmesag.'",
                    "Alerta - Aimaro",
                    "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));'.($flgimpri == "1" ? "confirmaImpressao('".$flgregis."','');" : $metodo ).'");';
}

echo 'hideMsgAguardo();';
?>