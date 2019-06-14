<?php

/***********************************************************************
  Fonte: impressao_termo.php                                               
  Autor: Gabriel                                                  
  Data : Marco/2011                       Última Alteração: 04/07/2012 		   
	                                                                   
  Objetivo  : Gerar o PDF do termo da rotina de COBRANCA da ATENDA.              
	                                                                 
  Altera??es: 26/07/2011 - Incluir a impressao de Cobranca registrada
						   (Gabriel).
						   
			  04/07/2012 - Retirado funcao exibeErro(). (Jorge)

			  28/12/2015 - Novo contrato cobran?a registrada (Daniel)
  
***********************************************************************/

session_cache_limiter("private");
session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");	
require_once("../../../includes/controla_secao.php");
require_once("../../../class/xmlfile.php");	


// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Recebe o nome do PDF
$dsrowid = $_POST["dsrowid"];

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "   <dsrowid>".$dsrowid."</dsrowid>";
$xml .= " </Dados>";
$xml .= "</Root>";

// craprdr / crapaca 
$xmlResult = mensageria($xml, "ATENDA", "IMPRIMIR_TERMO_PORTAB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
	exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

//Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObjeto->roottag->cdata;

//Chama funções para mostrar PDF do impresso gerado no browser	 
visualizaPDF($nmarqpdf);	

// Funções para exibir erros na tela através de javascript
function exibeErro($msgErro) { 
	echo '<script>alert("'.$msgErro.'");</script>';	
	exit();
}