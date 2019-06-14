<?
/*
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Ramirez
 * DATA CRIAÇÃO : 13/04/2011 
 * OBJETIVO     : Efetuar a adesao/encerramento do DDA. 
 * 
 * ALTERACOES   :
 */ 


session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");	

$nrdconta = $_POST["nrdconta"];
$idseqttl = $_POST["idseqttl"];
$nmrotina = $_POST["nmrotina"];
$cddopcao = ($nmrotina == "aderir-sacado") ?  "I" : "X";

// Carregas as opções da Rotina de DDA
$flgManter  = (in_array($cddopcao,$glbvars["opcoesTela"]));	
				
if ($flgManter == '') exibeErro('Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o para inclus&atilde;o/exclus&atilde;o');


// Monta o xml de requisição
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0078.p</Bo>';
$xml .= '		<Proc>'.$nmrotina.'</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagecxa>0</cdagecxa>';
$xml .= '		<nrdcaixa>0</nrdcaixa>';
$xml .= '		<cdopecxa>'.$glbvars['cdoperad'].'</cdopecxa>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
$xml .= '		<dtmvtolt>'.$glbvars["dtmvtolt"].'</dtmvtolt>';
$xml .= '	</Dados>';
$xml .= '</Root>';
	
// Executa script para envio do XML
$xmlResult = getDataXML($xml);	
// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

echo 'hideMsgAguardo();';
echo 'confirmaImpressao("'.$nmrotina.'");';


// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}	

?>