<?php

/************************************************************************
  Fonte: impressao_titulos.php                                 
  Autor: Gabriel                                                   
  Data : Abril/2011               Última Alteração:   /  /         
                                                                   
  Objetivo  : Fazer a chamada da procedure que traz os titulos bloqueados. 
                                                                  	 
  Alterações:   												   	
************************************************************************/
	
session_cache_limiter("private");
session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");	
require_once("../../../includes/controla_secao.php");
require_once("../../../class/xmlfile.php");	


// Verifica se tela foi chamada pelo método POST
isPostMethod();

$nrdconta = $_POST["nrdconta"];
$idseqttl = $_POST["idseqttl"];


// Monta xml
$xml  = "";
$xml .= "<Root>";
$xml .= " <Cabecalho>";
$xml .= "  <Bo>b1wgen0078.p</Bo>";
$xml .= "  <Proc>lista-grupo-titulos-sacado</Proc>";
$xml .= " </Cabecalho>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <cdagecxa>".$glbvars["cdagenci"]."</cdagecxa>";
$xml .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "   <cdopecxa>".$glbvars["cdoperad"]."</cdopecxa>";
$xml .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xml .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";
$xml .= "	<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "   <idseqttl>".$idseqttl."</idseqttl>";
$xml .= "   <dtvenini>?</dtvenini>"; 
$xml .= "   <dtvenfin>?</dtvenfin>";
$xml .= "   <cdsittit>13</cdsittit>";   
$xml .= "   <idordena>1</idordena>";
$xml .= " </Dados>";
$xml .= "</Root>";	

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

$xmlObjTermo = getObjectXML($xmlResult);


// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjTermo->roottag->tags[0]->name) == "ERRO") {
	 $msg = $xmlObjTermo->roottag->tags[0]->tags[0]->tags[4]->cdata;	
	 ?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
	 exit();
} 

//$qtTitulos  = $xmlObjTermo->roottag->tags[0]->attributes["QTTITULO"];
$titulos    = $xmlObjTermo->roottag->tags[0]->tags;
$instrucoes = $xmlObjTermo->roottag->tags[1]->tags;
$descontos  = $xmlObjTermo->roottag->tags[2]->tags;

require_once("impressao_titulos_pdf.php");	
	
?>