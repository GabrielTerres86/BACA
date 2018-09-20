<?php 

	/************************************************************************
          Fonte: principal.php
	      Autor: Lucas Lombardi
          Data : Marco/2016                 Ultima Alteracao: 00/00/0000

	      Objetivo  : Listar os consorcios

	      Alteracoes:
              		  
	 ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"])) <> "") {
		exibeErro($msgError);		
	}	

	$nrdconta = $_POST['nrdconta'] == '' ? 0  : $_POST['nrdconta'];
	$nrregist = $_POST['nrregist'] == '' ? 20 : $_POST['nrregist'];
	$nrinireg = $_POST['nrinireg'] == '' ? 0  : $_POST['nrinireg'];
	
	$xmlBuscaPacotes  = "";
	$xmlBuscaPacotes .= "<Root>";
	$xmlBuscaPacotes .= "   <Dados>";
	$xmlBuscaPacotes .= "	   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlBuscaPacotes .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlBuscaPacotes .= "	   <nrregist>".$nrregist."</nrregist>";	
	$xmlBuscaPacotes .= "	   <nrinireg>".$nrinireg."</nrinireg>";
	$xmlBuscaPacotes .= "   </Dados>";
	$xmlBuscaPacotes .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaPacotes, "ADEPAC", "BUSCA_PACOTES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjBuscaPacotes = getObjectXML($xmlResult);
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjBuscaPacotes->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjBuscaPacotes->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjBuscaPacotes->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrrecben";
		}
				 
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'input\',\'#divBeneficio\').removeClass(\'campoErro\');unblockBackground(); $(\'#'.$nmdcampo.'\',\'#divBeneficio\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divBeneficio\');',false);		
							
	}   
	
    $registros = $xmlObjBuscaPacotes->roottag->tags[0]->tags;
    $qtregist = $xmlObjBuscaPacotes->roottag->tags[1]->name;
	
	include('tab_pacote_tarifas.php');
			
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
		
	
?>
