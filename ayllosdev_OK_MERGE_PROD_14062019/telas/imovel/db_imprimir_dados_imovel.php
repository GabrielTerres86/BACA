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
$nrdconta = $_POST["nrdconta"];	
$nrctremp = $_POST["nrctremp"];
$idseqbem = $_POST["idseqbem"]; 
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

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
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
$xml .= "   <idseqbem>".$idseqbem."</idseqbem>";
$xml .= " </Dados>";
$xml .= "</Root>";

// craprdr / crapaca 
$xmlResult = mensageria($xml, "IMOVEL", "IMPRIME_IMOVEL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
    exibeErro($xmlObjeto->roottag->tags[0]->cdata);		 
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