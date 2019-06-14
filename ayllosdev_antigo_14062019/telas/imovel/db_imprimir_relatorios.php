<?php
/*!
 * FONTE        : db_imprimir_dados_imovel.php
 * CRIAÇÃO      : Renato Darosci
 * DATA CRIAÇÃO : 14/06/2016
 * OBJETIVO     : Rotina para impressão dos dados cadastrados na tela IMOVEL
 * --------------
 * ALTERAÇÕES   :  								    			
 * -------------- 
 */
 
session_cache_limiter("private");
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();		

// Receber os parametros
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$inrelato = (isset($_POST['inrelato'])) ? $_POST['inrelato'] : 0; 
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0; 
$intiprel = (isset($_POST['intiprel'])) ? $_POST['intiprel'] : ''; 
$dtrefere = (isset($_POST['dtrefere'])) ? $_POST['dtrefere'] : ''; 
$cddolote = (isset($_POST['cddolote'])) ? $_POST['cddolote'] : 0; 

// Inicializa
$retornoAposErro= '';

$nmendter = session_id();

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	exibirErro('error',$msgError,'Alerta - Ayllos','',false);
}
	
// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <cdcoptel>".$cdcooper."</cdcoptel>";
$xml .= "   <inrelato>".$inrelato."</inrelato>";
$xml .= "   <intiprel>".$intiprel."</intiprel>";
$xml .= "   <dtrefere>".$dtrefere."</dtrefere>";
$xml .= "   <cddolote>".$cddolote."</cddolote>";
$xml .= " </Dados>";
$xml .= "</Root>";

// craprdr / crapaca 
$xmlResult = mensageria($xml, "IMOVEL", "RELATO_IMOVEL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra mensagem
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
	$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
	exibirErro($msgErro);
} 

//Obtém nome do arquivo PDF
$nmarqpdf = $xmlObjeto->roottag->cdata;

//Chama função para mostrar PDF do impresso gerado no browser	 
visualizaPDF($nmarqpdf);	

// Função para exibir erros na tela através de javascript
function exibeErro($msgErro) { 
  echo '<script>alert("'.$msgErro.'");</script>';	
  exit();
}

?>