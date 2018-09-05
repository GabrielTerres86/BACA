<?php

/* !
 * FONTE        : imprimir_boleto.php
 * CRIAÇÃO      : Vitor Shimada Assanuma
 * DATA CRIAÇÃO : 04/06/2018
 * OBJETIVO     : Rotina para impressão de boleto.
 * --------------
 * ALTERAÇÕES   :  								    			
 * -------------- 
 */
?> 

<?php

session_cache_limiter("private");
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Recebe Parametros
$nrdconta = $_POST["nrdconta1"];
$nrcnvcob = $_POST["nrcnvcob1"];
$nrdocmto = $_POST["nrdocmto1"];

// Inicializa variavel
$retornoAposErro = '';

$nmendter = session_id();

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrcnvcob>" . $nrcnvcob . "</nrcnvcob>";
$xml .= "   <nrdocmto>" . $nrdocmto . "</nrdocmto>";
$xml .= " </Dados>";
$xml .= "</Root>";

// craprdr / crapaca 
$xmlResult = mensageria($xml, "COBTIT", "IMPRIMIR_BOLETO_PDF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

if (strtoupper($xmlObjeto->roottag->tags[0]->name == 'ERRO')) {
    
    $msgErro = $xmlObjeto->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    ?><script language="javascript">alert('<?php echo substr($msgErro,0,103); ?>');</script><?php
   // exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);
    exit();
} else {

//Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObjeto->roottag->cdata;

//Chama função para mostrar PDF do impresso gerado no browser	 
visualizaPDF($nmarqpdf);

}
 