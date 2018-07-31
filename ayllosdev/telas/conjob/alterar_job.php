<?php
	/*!
	* FONTE        : alterar_job.php
	* CRIA��O      : Mateus Zimmermann - Mouts
	* DATA CRIA��O : Junho/2018
	* OBJETIVO     : Rotina para realizar a altera��o das jobs
	* --------------
	* ALTERA��ES   : 
	* -------------- 
	*/		
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$tpmantem             = 'A';
	$nmjob                = isset($_POST["nmjob"])                ? $_POST["nmjob"]                : "";
	$idativo              = isset($_POST["idativo"])              ? $_POST["idativo"]              : "";
	$dsdetalhe            = isset($_POST["dsdetalhe"])            ? $_POST["dsdetalhe"]            : "";
	$dsprefixo_jobs       = isset($_POST["dsprefixo_jobs"])       ? $_POST["dsprefixo_jobs"]       : "";
	$idperiodici_execucao = isset($_POST["idperiodici_execucao"]) ? $_POST["idperiodici_execucao"] : "";
	$tpintervalo          = isset($_POST["tpintervalo"])          ? $_POST["tpintervalo"]          : "";
	$qtintervalo          = isset($_POST["qtintervalo"])          ? $_POST["qtintervalo"]          : "";
	$dsdias_habilitados   = isset($_POST["dsdias_habilitados"])   ? $_POST["dsdias_habilitados"]   : "";
	$dtprox_execucao      = isset($_POST["dtprox_execucao"])      ? $_POST["dtprox_execucao"]      : "";
	$hrprox_execucao      = isset($_POST["hrprox_execucao"])      ? $_POST["hrprox_execucao"]      : "";
	$flexecuta_feriado    = isset($_POST["flexecuta_feriado"])    ? $_POST["flexecuta_feriado"]    : "";
	$flsaida_email        = isset($_POST["flsaida_email"])        ? $_POST["flsaida_email"]        : "";
	$dsdestino_email      = isset($_POST["dsdestino_email"])      ? $_POST["dsdestino_email"]      : "";
	$flsaida_log          = isset($_POST["flsaida_log"])          ? $_POST["flsaida_log"]          : "";
	$dsnome_arq_log       = isset($_POST["dsnome_arq_log"])       ? $_POST["dsnome_arq_log"]       : "";
	$dscodigo_plsql       = isset($_POST["dscodigo_plsql"])       ? $_POST["dscodigo_plsql"]       : "";
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tpmantem>"            .$tpmantem.            "</tpmantem>";
	$xml .= "   <nmjob>"               .$nmjob.               "</nmjob>";
	$xml .= "   <idativo>"             .$idativo.             "</idativo>";
	$xml .= "   <dsdetalhe>"           .$dsdetalhe.           "</dsdetalhe>";
	$xml .= "   <dsprefixo_jobs>"      .$dsprefixo_jobs.      "</dsprefixo_jobs>";
	$xml .= "   <idperiodici_execucao>".$idperiodici_execucao."</idperiodici_execucao>";
	$xml .= "   <tpintervalo>"         .$tpintervalo.         "</tpintervalo>";
	$xml .= "   <qtintervalo>"         .$qtintervalo.         "</qtintervalo>";
	$xml .= "   <dsdias_habilitados>"  .$dsdias_habilitados.  "</dsdias_habilitados>";
	$xml .= "   <dtprox_execucao>"     .$dtprox_execucao.     "</dtprox_execucao>";
	$xml .= "   <hrprox_execucao>"     .$hrprox_execucao.     "</hrprox_execucao>";
	$xml .= "   <flexecuta_feriado>"   .$flexecuta_feriado.   "</flexecuta_feriado>";
	$xml .= "   <flsaida_email>"       .$flsaida_email.       "</flsaida_email>";
	$xml .= "   <dsdestino_email>"     .$dsdestino_email.     "</dsdestino_email>";
	$xml .= "   <flsaida_log>"         .$flsaida_log.         "</flsaida_log>";
	$xml .= "   <dsnome_arq_log>"      .$dsnome_arq_log.      "</dsnome_arq_log>";
	$xml .= "   <dscodigo_plsql>"      .$dscodigo_plsql.      "</dscodigo_plsql>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_CONJOB", "CONJOB_MANTEM_JOB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','',false);
	}
	
	exibirErro('inform','JOB alterado com sucesso.','Alerta - Ayllos','estadoInicial();',false);	
		
?>