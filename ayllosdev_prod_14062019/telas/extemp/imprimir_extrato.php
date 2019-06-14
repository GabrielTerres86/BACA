<?php
/* !
 * FONTE        : imprimir_extrato.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 06/10/2011
 * OBJETIVO     : Imprime o extrato caso o tipo do empréstimos seja igual a 1
 * ALTERACOES   :
 * 		09/04/2012 - Modificado a chamada da b1wgen0084.p para b1wgen0112.p (Tiago)
 *      04/07/2012 - Ajuste em alerta de erro. (Jorge)
 * 	    31/10/2014 - Alterado a chamada da procedure gera-impextepr para Gera_Impressao (Jean Michel). 
 * */

session_cache_limiter("private");
session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");


if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], "C")) <> "") {
    ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
    exit();
}

// Guardo os parâmetos do POST em variáveis	
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '1';
$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
$intpextr = (isset($_POST['intpextr'])) ? $_POST['intpextr'] : '';
$dsiduser = session_id();

// Monta o xml de requisição
$xml = "";
$xml.= "<Root>";
$xml.= "	<Cabecalho>";
$xml.= "		<Bo>b1wgen0112.p</Bo>";
$xml.= "		<Proc>Gera_Impressao</Proc>";
$xml.= "	</Cabecalho>";
$xml.= "	<Dados>";
$xml.= "		<cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
$xml.= "		<cdagenci>" . $glbvars["cdagenci"] . "</cdagenci>";
$xml.= "		<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>";
$xml.= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
$xml.= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
$xml.= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xml.= "		<dtmvtopr>" . $glbvars["dtmvtopr"] . "</dtmvtopr>";
$xml.= "		<cdprogra>" . $glbvars["nmdatela"] . "</cdprogra>";
$xml.= "		<inproces>1</inproces>";
$xml.= "		<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
$xml .= '		<dsiduser>' . $dsiduser . '</dsiduser>';
$xml .= "		<flgrodar>TRUE</flgrodar>";
$xml.= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xml.= "		<idseqttl>" . $idseqttl . "</idseqttl>";
$xml.= "		<intpextr>" . $intpextr ."</intpextr>";
$xml.= "		<tpextrat>3</tpextrat>";
$xml.= "		<dtrefere>?</dtrefere>";
$xml.= "		<dtreffim>?</dtreffim>";
$xml.= "		<flgtarif>FALSE</flgtarif>";
$xml.= "		<inrelext>0</inrelext>";
$xml.= "		<inselext>1</inselext>";
$xml.= "		<nrctremp>" . $nrctremp ."</nrctremp>";
$xml.= "		<nraplica>0</nraplica>";
$xml.= "		<nranoref>0</nranoref>";
$xml.= "		<flgerlog>TRUE</flgerlog>";
$xml.= "	</Dados>";
$xml.= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
    $msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    ?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
    exit();
}

// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObj->roottag->tags[0]->attributes["NMARQPDF"];

// Chama função para mostrar PDF do impresso gerado no browser
visualizaPDF($nmarqpdf);
?>