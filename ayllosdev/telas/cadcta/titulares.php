<?php
/*!
 * FONTE        : titulares.php
 * CRIAÇÃO      : Andrey Formigari (Mouts)
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Listar titulares na tela CADCTA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
session_start();	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");
require_once("../../class/xmlfile.php");	
isPostMethod();

$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
$idseqttl = $_POST["idseqttl"] == "" ? 1 : $_POST["idseqttl"];	
		
// Se conta informada não for um número inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inválida.");
}		

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0051.p</Bo>";
$xml .= "		<Proc>carrega_dados_conta</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "	</Dados>";
$xml .= "</Root>";

$xmlResult = getDataXML($xml,false);
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

function exibeErro($msgErro) {
	echo 'hideMsgAguardo();';
	echo 'showError("error"," '.$msgErro.'","Alerta - Contas","$(\'#nrdconta\',\'#frmCabCadcta\').focus()");';
	echo 'limparDadosCampos();';
	echo 'flgAcessoRotina = false;';
	exit();	
}
	
// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
$msg = Array();	
	
//Atribuições
$cabecalho  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
$Titulares  = ( isset($xmlObjeto->roottag->tags[2]->tags) ) ? $xmlObjeto->roottag->tags[2]->tags : array();
$mensagens  = ( isset($xmlObjeto->roottag->tags[3]->tags) ) ? $xmlObjeto->roottag->tags[3]->tags : array();

$tpNatureza = $cabecalho[6]->cdata;

function getRelacionamento($cdgraupr){
	switch($cdgraupr){
		case 1:
			return '1 - CÔNJUGE';
		case 2:
			return '2 - PAI / MÃE';
		case 3:
			return '3 - FILHO(A)';
		case 4:
			return '4 - COMPANHEIRO(A)';
		case 6:
			return '6 - COOPERADO(A)';
		default:
			return '0 - PRIMEIRO TITULAR';
	}
}

echo '<input type="hidden" value="'.$tpNatureza.'" name="tpNatureza" id="tpNatureza" />';

if ($inpessoa >= 2){
	include('titulares_pj.php');
}else{
	include('titulares_pf.php');
}

?>