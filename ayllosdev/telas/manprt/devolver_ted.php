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
	$motivo = (isset($_POST['motivo'])) ? $_POST['motivo'] : 0 ;
	$descricao = (isset($_POST['descricao'])) ? $_POST['descricao'] : '' ;

	if ($idlancto == 0) {		
		echo "showError('error', 'A TED deve ser informada.', 'Alerta - Ayllos', '');";
		exit;
	}

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "   <idlancto>".$idlancto."</idlancto>";
	$xml .= "   <motivo>".$motivo."</motivo>";
	$xml .= "   <descricao>".$descricao."</descricao>";    
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_MANPRT", "DEVOLVER_TED", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

    //print_r($xmlObjeto);

	// Se ocorrer um erro, mostra critica
	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);		 
		exit;
	}
	echo "showError('inform', 'Devolu&ccedil;&atilde;o efetuada com sucesso!', 'Notifica&ccedil;&atilde;o - Ayllos', 'fechaRotina($(\'#divRotina\'));realizaoConsultaTed(nriniseq, nrregist);');";

	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo "showError('error', '".$msgErro."', 'Alerta - Ayllos', '');";
	    exit;
	}
 
?>