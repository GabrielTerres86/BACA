<?php

/***********************************************************************
  Fonte: imprimir_consulta_ted_csv.php                                              
  Autor: H�linton Steffens                                                  
  Data : Mar�o/2018                       �ltima Altera��o: - 		   
	                                                                   
  Objetivo  : Gerar o CSV dos titulos.              
	                                                                 
  Altera��es: 
  
***********************************************************************/
	session_cache_limiter("private");
	session_start();
		
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$idlancto = (isset($_POST['idlancto'])) ? $_POST['idlancto'] : 0 ;
	$idretorno = (isset($_POST['idretorno'])) ? $_POST['idretorno'] : 0 ;
	$cooperativa = (isset($_POST['cooperativa'])) ? $_POST['cooperativa'] : 0 ;
	$convenio = (isset($_POST['convenio'])) ? $_POST['convenio'] : 0 ;
	$conta = (isset($_POST['conta'])) ? $_POST['conta'] : 0 ;
	$documento = (isset($_POST['documento'])) ? $_POST['documento'] : 0 ;

	$acao = (isset($_POST['acao'])) ? $_POST['acao'] : '' ;

	if (empty($acao)) {
		exit;
	}

	if ($acao == "validar_cartorio") {

		if ($idlancto == 0) {
			exibirErro('error', 'A TED deve ser informada.', 'Alerta - Ayllos', '', false);
			exit;
		}

		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "   <idlancto>".$idlancto."</idlancto>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_MANPRT", "VALIDAR_CARTORIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		//print_r($xmlObjeto);

		// Se ocorrer um erro, mostra critica
		/*if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
			exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
			exit;
		}*/

		echo 'abrirModalEstornarTED();';

	} else if ($acao == "retornar_titulo") {
		
		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$cooperativa."</cdcooper>";
		$xml .= "   <nrdconta>".$conta."</nrdconta>";
		$xml .= "   <nrcnvcob>".$convenio."</nrcnvcob>";
		$xml .= "   <nrdocmto>".$documento."</nrdocmto>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_MANPRT", "RETORNA_TITULO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		//print_r($xmlObjeto);

		// Se ocorrer um erro, mostra critica
		if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
			exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
			exit;	 
		}

		$titulo = $xmlObjeto->roottag->tags[0]->tags;

		$custas = getByTagName($titulo,'custas');
		$dtvencto = getByTagName($titulo,'dtvencto');
		$vltitulo = getByTagName($titulo,'vltitulo');
		$nmprimtl = getByTagName($titulo,'nmprimtl');
		$idretorno = getByTagName($titulo,'idretorno');

		echo "$('#retornoTitulo').show();";
		echo "$('#custas').val('".$custas."');";
		echo "$('#dtvencto').val('".$dtvencto."');";
		echo "$('#vltitulo').val('".$vltitulo."');";
		echo "$('#nmprimtl').val('".$nmprimtl."');";
		echo "$('#idretorno').val('".$idretorno."');";
		echo "validarValorTEDCustas();";

	} else if ($acao == "estornar_ted") {

		if ($idlancto == 0) {
			exibirErro('error', 'A TED deve ser informada.', 'Alerta - Ayllos', '', false);
			exit;
		}

		$xml  = "";
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xml .= "   <idlancto>".$idlancto."</idlancto>";
		$xml .= "   <idretorno>".$idretorno."</idretorno>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "TELA_MANPRT", "ESTORNAR_TED", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);

		//print_r($xmlObjeto);

		// Se ocorrer um erro, mostra critica
		if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
			exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
			exit; 
		}
	}

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
	    exit;
	}
 
?>