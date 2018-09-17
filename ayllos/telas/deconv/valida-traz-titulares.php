<? 
  /**************************************************************************
	
  Fonte: valida-traz-titulares.php
  Autor: Gabriel
  Data : Junho/2011							Ultima alteracao:
	 
  Objetivo: Validar os campos da tela DECONV e trazer os titulares.
	 
  Alteraçoes:
	 
  **************************************************************************/

  session_start();
	
  // Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
  require_once("../../includes/config.php");
  require_once("../../includes/funcoes.php");	
  require_once("../../includes/controla_secao.php");

  // Verifica se tela foi chamada pelo método POST
  isPostMethod();	
		
  // Classe para leitura do xml de retorno
  require_once("../../class/xmlfile.php");
	
  $cdconven = $_POST["cdconven"];
  $nrdconta = $_POST["nrdconta"];
  
  // Verifica Permissão
  if (($msgError = validaPermissao($glbvars["nmdatela"],"","R")) <> "") {
	  exibeErro($msgError); 
  }
  
 // Montar o xml de Requisicao  
 $xml  = "";
 $xml .= "<Root>";
 $xml .= " <Cabecalho>";
 $xml .= "    <Bo>b1wgen0099.p</Bo>";
 $xml .= "    <Proc>valida-traz-titulares</Proc>";
 $xml .= " </Cabecalho>";
 $xml .= " <Dados>";
 $xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
 $xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
 $xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
 $xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
 $xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
 $xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
 $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
 $xml .= "    <cdconven>".$cdconven."</cdconven>"; 
 $xml .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
 $xml .= " </Dados>";
 $xml .= "</Root>";
 
 // Executa script para envio do XML
 $xmlResult = getDataXML($xml);
	
 $xmlObjValidaConvenio = getObjectXML($xmlResult);
	
 echo 'hideMsgAguardo();';
 
 // Se ocorrer um erro, mostra crítica
 if (strtoupper($xmlObjValidaConvenio->roottag->tags[0]->name) == "ERRO") {
	'hideMsgAguardo();'; 
	$msgErro  = $xmlObjValidaConvenio->roottag->tags[0]->tags[0]->tags[4]->cdata;
	$nmdcampo = $xmlObjValidaConvenio->roottag->tags[0]->attributes['NMDCAMPO'];	
	if (!empty($nmdcampo)) {
		$mtdErro = $mtdErro . "$('#".$nmdcampo."','#frmDeconv').focus();";  
	}		
	exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);	
	exit();	
 }
 
 // Carga a lista dos titulares 
 $titulares  = $xmlObjValidaConvenio->roottag->tags[0]->tags;
	
 $qtTitulares = count($titulares);
	
 $idseqttl = 1;
	
 // Mostrar os titulares 
 include('mostra_titulares.php');
	
 echo 'controlaBotoes();';
		
 echo 'SelecionaTit("'.$idseqttl.'" , "'.$qtTitulares.'");';
  
?>