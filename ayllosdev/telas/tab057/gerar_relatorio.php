<?php
/* !
 * FONTE          : gerar_relatorio.php
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 09/03/2017
 * OBJETIVO       : Faz as impressao do relatorio de criticas
 * --------------
 * ALTERACOES   : 
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


// Recebe as variaveis
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : 0;
$dtmvtolt = (isset($_POST["dtmvtolt"])) ? $_POST["dtmvtolt"] : "";
$nrsequen = (isset($_POST['nrsequen'])) ? $_POST['nrsequen'] : 0;

$xml = new XmlMensageria();
$xml->add('cdcoptel',$cdcooper)
    ->add('cdconven',$cdempres)
    ->add('dtmvtolt',$dtmvtolt)
    ->add('nrsequen',$nrsequen); 

$xmlResult = mensageria($xml, "TAB057", "GERA_RELAT_CRITIC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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