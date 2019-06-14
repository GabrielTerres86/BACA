<?php
/* !
 * FONTE        : imprimir_custod_l.php
 * CRIA��O      : Odirlei Busana - AMcom 
 * DATA CRIA��O : 30/09/2016
 * OBJETIVO     : Faz as impress�o da custodia de cheque opcao L
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */


session_cache_limiter("private");
session_start();

// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m�todo POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], $_POST['cddopcao'])) <> "") {
    ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
    exit();
}

$c = array('.', '-');

// Recebe as variaveis
$dsiduser = session_id();
$cddopcao = $_POST['cddopcao'];
$dsiduser = session_id();
$nrdconta = str_ireplace($c, '', $_POST['nrdconta']);
$nrremret = !isset($_POST["nrremret"]) ? 0  : $_POST["nrremret"];

$xmlimpres = new XmlMensageria();
$xmlimpres->add('nrdconta',$nrdconta)
          ->add('nrremret',$nrremret)
          ->add('dsiduser',$dsiduser); 

$xmlResult = mensageria($xmlimpres, "TELA_CUSTOD", "CUSTOD_RELAT_ACOMP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
   $xmlObj = getObjectXML($xmlResult);	
   
// Se ocorrer um erro, mostra cr�tica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    ?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
    exit();
}

// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObj->roottag->tags[0]->tags[0]->cdata;

// Chama fun��o para mostrar PDF do impresso gerado no browser
visualizaPDF($nmarqpdf);
?>