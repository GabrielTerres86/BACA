<?php
/* !
 * FONTE        : imprimir_recarga.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 09/03/2017
 * OBJETIVO     : Faz as impressão da recarga de celular
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */


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

if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], 'C')) <> "") {
    ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
    exit();
}

$c = array('.', '-');

// Recebe as variaveis
$cddopcao = $_POST['cddopcao'];
$dsiduser = session_id();
$nrdconta = str_ireplace($c, '', $_POST['nrdconta']);
$idoperacao = !isset($_POST["idoperacao"]) ? 0  : $_POST["idoperacao"];

$xmlimpres = new XmlMensageria();
$xmlimpres->add('nrdconta',$nrdconta)
          ->add('idoperacao',$idoperacao)
          ->add('dsiduser',$dsiduser); 

$xmlResult = mensageria($xmlimpres, "TELA_RECCEL", "IMPRIME_RECARGA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
   $xmlObj = getObjectXML($xmlResult);	
   
// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    ?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
    exit();
}

// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObj->roottag->tags[0]->tags[0]->cdata;

// Chama função para mostrar PDF do impresso gerado no browser
visualizaPDF($nmarqpdf);
?>