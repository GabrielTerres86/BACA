<? 
/******************************************************************************
ATENCAO! CONVERSAO PROGRESS - ORACLE
ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!

PARA QUALQUER ALTERACAO QUE ENVOLVA PARAMETROS DE COMUNICACAO NESSE FONTE,
A PARTIR DE 10/MAI/2013, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES PESSOAS:
- GUILHERME STRUBE (CECRED)
- MARCOS MARTINI (SUPERO)
- GUILHERME BOETTCHER (SUPERO)
*******************************************************************************/




  /**************************************************************************
	
  Fonte: alterar-senha.php
  Autor: Gabriel
  Data : Julho/2011							Ultima alteracao:
	 
  Objetivo: Validar e alterar a senha do Operador.
	 
  Alteracoes: 
	 
  **************************************************************************/

  session_start();
	
  // Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
  require_once("../../includes/config.php");
  require_once("../../includes/funcoes.php");	
  require_once("../../includes/controla_secao.php");

  // Verifica se tela foi chamada pelo m�todo POST
  isPostMethod();	
		
  // Classe para leitura do xml de retorno
  require_once("../../class/xmlfile.php");
	
  $cdoperad = $_POST["cdoperad"];
  $cdsenha1 = $_POST["cdsenha1"];
  $cdsenha2 = $_POST["cdsenha2"];
  $cdsenha3 = $_POST["cdsenha3"];

	    
 // Montar o xml de Requisicao  
 $xml  = "";
 $xml .= "<Root>";
 $xml .= " <Dados>";
 $xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
 $xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
 $xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
 $xml .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
 $xml .= "    <cdoperad>".$cdoperad."</cdoperad>";
 $xml .= "    <cdsenha1>".$cdsenha1."</cdsenha1>";
 $xml .= "    <cdsenha2>".$cdsenha2."</cdsenha2>";
 $xml .= "    <cdsenha3>".$cdsenha3."</cdsenha3>";
 $xml .= " </Dados>";
 $xml .= "</Root>";

 $xmlResult = mensageria($xml, "MUDSEN", "ALTSENHA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
 $xmlObjSenha = getObjectXML($xmlResult);
	
 echo 'hideMsgAguardo();';
 
 // Se ocorrer um erro, mostra cr�tica
 if (strtoupper($xmlObjSenha->roottag->tags[0]->name) == "ERRO") {
	$msgErro  = $xmlObjSenha->roottag->tags[0]->tags[0]->tags[4]->cdata;
	$nmdcampo = $xmlObjSenha->roottag->tags[0]->attributes['NMDCAMPO'];	
	if (!empty($nmdcampo)) {
		$mtdErro = $mtdErro . "$('#".$nmdcampo."','#frmMudsen').focus();";  
	}		
	exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);	
	exit();	
 }
 	
 echo 'limpaTela();';
 
 if ($glbvars["flgdsenh"] == "yes") {
	?>
	$("#flgdsenh","#frmAcesso").val("no");
	if ($('#inproces','#frmAcesso').val() && existeTela('atenda')) direcionaTela("atenda",false);
	<?php 
	setVarSession("flgdsenh","no");
 } 
 ?>  