<?
/*!
 * FONTE        : imprime_relacao.php
 * CRIAÇÃO      : Cristian Filipe (Gati)
 * DATA CRIAÇÃO : 18/11/2013
 *
 * ALTERAÇÕES   : 19/10/2015 - Ao validar permissão, passado parâmetro cddopcao fixo 'R' (Dionathan)
 */    
 
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();		

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'R')) <> '') {
	exibirErro('error',$msgError,'Alerta - Aimaro','',false);
}

$flgordem = $_POST['flgordem'];

/*VALIDA SE OS DADOS DA EMPRESA ESTAO CORRETOS*/
$xml  = "";
$xml.= "<Root>";
$xml.= "  <Cabecalho>";
$xml.= "	    <Bo>b1wgen0166.p</Bo>";
$xml.= "        <Proc>Imprime_relacao</Proc>";
$xml.= "  </Cabecalho>";
$xml.= "  <Dados>";
$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xml .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xml .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
$xml .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xml .= "        <cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
$xml.="			<flgordem>".$flgordem."</flgordem>";
$xml.= "  </Dados>";
$xml.= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	$msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	exibeErro($msg);
}

// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObj->roottag->tags[0]->attributes["NMARQPDF"];

visualizaPDF($nmarqpdf);

function exibeErro($msgErro) {
	echo '<script>alert("'.$msgErro.'");</script>';
	exit();
}
