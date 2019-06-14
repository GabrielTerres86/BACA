<?php 

/*************************************************************************
	Fonte: valida_habilitacao.php
	Autor: Gabriel						Ultima atualizacao: 23/02/2016
	Data : Dezembro/2010
	
	Objetivo: Valida os dados da inclusao.
	
	Alteracoes: 19/05/2011 - Tratar cob. regist. (Guilherme).
	
				29/04/2015 - Incluido campo cddbanco. (Reinert)

				23/02/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

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

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
	exibirErro('error',$msgError,'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
}	

$nrdconta = $_POST["nrdconta"];
$nrconven = $_POST["nrconven"];

// Montar o xml de Requisicao
$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrconven>".$nrconven."</nrconven>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "VALIDA_HABILITACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObject = getObjectXML($xmlResult);

if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
    exibirErro('error',utf8_encode($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
} 

$param    = $xmlObject->roottag->tags[0];
$dsorgarq = getByTagName($param->tags,"DSORGARQ");
$flgregis = getByTagName($param->tags,"FLGREGIS");
$flsercco = getByTagName($param->tags,"FLSERASA");
$cddbanco = getByTagName($param->tags,"CDDBANCO");

echo '$("#dsorgarq","#frmConsulta").val("'.$dsorgarq.'");';
echo '$("#flgregis","#frmConsulta").val("'.$flgregis.'");';
echo '$("#flsercco","#frmConsulta").val("'.$flsercco.'");';

if ($flsercco == "0") {
    echo '$("#flserasa","#divOpcaoConsulta").prop("disabled",true);';
    echo '$("#flserasa","#divOpcaoConsulta").prop("checked",false);';
}

if ($dsorgarq == 'IMPRESSO PELO SOFTWARE') {
    echo '$("#divCnvHomol","#frmConsulta").show();';
} else {
    echo '$("#divCnvHomol","#frmConsulta").hide();';
}	

echo 'hideMsgAguardo();';
echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
?>
