<?php
/* !
 * FONTE        : form_acionamentos.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 22/03/2016 
 * OBJETIVO     : Rotina para controlar a busca de acionamentos
 * --------------
 * ALTERAÇÕES   : 18/04/2017 - Alterações referentes ao projeto 337 - Motor de Crédito. (Reinert)
 *                12/06/2017 - Retornar o protocolo. (Jaison/Marcos - PRJ337)
 * -------------- 
 */

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
session_start();
require_once("../../../../includes/config.php");
require_once("../../../../includes/funcoes.php");   
require_once("../../../../includes/controla_secao.php");    
require_once("../../../../class/xmlfile.php");  
isPostMethod();

$dsprotocolo = (isset($_POST['dsprotocolo'])) ? $_POST['dsprotocolo'] : '';
$nmarquiv    = (isset($_POST['nmarquiv']))    ? $_POST['nmarquiv']    : '';

// Gera o arquivo
if ($dsprotocolo) {

    // Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <dsprotocolo>".$dsprotocolo."</dsprotocolo>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // craprdr / crapaca 
    $xmlResult = mensageria($xml, "CONPRO", "CONPRO_GERA_ARQ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
        exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)', false);
    }

    // Obtem nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    echo $xmlObjeto->roottag->tags[0]->cdata;

// Efetua o download
} else if ($nmarquiv) {

    //Chama função para mostrar PDF do impresso gerado no browser    
    visualizaPDF($nmarquiv);

// Mostra a listagem
} else {

    echo 'showError("error","Operação inválida!","Alerta - Aimaro","bloqueiaFundo(divRotina);fechaRotinaDetalhe();");';
    exit;
}
   
    
