<?php
/*************************************************************************
	Fonte: obtem_consulta.php                                               
	Autor: Andr� Clemer
	Data : Abril/2018                         �ltima Altera��o: --/--/----
																	
	Objetivo  : Carrega os dados da tela MANCAR.
																	
	Altera��es: 
				
***********************************************************************/

session_start();

require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");	
require_once("../../includes/controla_secao.php");

require_once("../../class/xmlfile.php");
isPostMethod();

$nmeacao  = 'MANCAR_CONSULTA';
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 1;
$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;

$uf = (isset($_POST["uf"])) ? $_POST["uf"] : 0;
$idcidade = (isset($_POST["idcidade"])) ? $_POST["idcidade"] : 0;
$nrcpf_cnpj = (isset($_POST["nrcpf_cnpj"])) ? $_POST["nrcpf_cnpj"] : '';

$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>";	
$xml .= "   <nrcpf_cnpj>".$nrcpf_cnpj."</nrcpf_cnpj>";
$xml .= "   <nmcartorio></nmcartorio>";
$xml .= "   <nrregist>".$nrregist."</nrregist>";
$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
$xml .= "   <uf>".$uf."</uf>";
$xml .= "   <idcidade>".$idcidade."</idcidade>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "MANCAR", $nmeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
}

$registros = $xmlObj->roottag->tags[0]->tags;
$qtregist = $xmlObj->roottag->tags[1]->cdata;

include('tabela_mancar.php');