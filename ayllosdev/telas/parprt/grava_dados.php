<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Andre Clemer
	  Data : Janeiro/2018                       �ltima Altera��o: --/--/----
	                                                                   
	  Objetivo  : Grava os dados.
	                                                                 
	  Altera��es: 
	                                                                  
	***********************************************************************/

	session_start();

	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$acao				  	= (isset($_POST['acao']))                 	? $_POST['acao']                 	: ''  ;
	$cddopcao             	= (isset($_POST['cddopcao']))             	? $_POST['cddopcao']             	: ''  ;
	$cdcooper 				= (isset($_POST["cdcooper"])) 				? $_POST["cdcooper"] 				: $glbvars["cdcooper"];
	$dscnae              	= (isset($_POST['dscnae']))              	? $_POST['dscnae']              	: ''  ;
	$dsuf              		= (isset($_POST['dsuf']))              		? $_POST['dsuf']              		: ''  ;
	$qtlimitemin_tolerancia = (isset($_POST['qtlimitemin_tolerancia'])) ? $_POST['qtlimitemin_tolerancia'] 	: ''  ;
	$qtlimitemax_tolerancia = (isset($_POST['qtlimitemax_tolerancia'])) ? $_POST['qtlimitemax_tolerancia'] 	: ''  ;
	$hrenvio_arquivo      	= (isset($_POST['hrenvio_arquivo']))      	? $_POST['hrenvio_arquivo']      	: ''  ;
	$qtdias_cancelamento    = (isset($_POST['qtdias_cancelamento']))    ? $_POST['qtdias_cancelamento']    	: ''  ;
    $flcancelamento   		= (isset($_POST['flcancelamento']))   		? $_POST['flcancelamento']   		: ''  ;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$dsmensag = 'Parametros alterados com sucesso!';

	// Montar o xml de Requisicao
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	// PARAM
	$xmlCarregaDados .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xmlCarregaDados .= "   <limitemin_tolerancia>".$qtlimitemin_tolerancia."</limitemin_tolerancia>";
	$xmlCarregaDados .= "   <limitemax_tolerancia>".$qtlimitemax_tolerancia."</limitemax_tolerancia>";
	$xmlCarregaDados .= "   <hrenvio_arquivo>".$hrenvio_arquivo."</hrenvio_arquivo>";
	$xmlCarregaDados .= "   <qtdias_cancelamento>".$qtdias_cancelamento."</qtdias_cancelamento>";
	$xmlCarregaDados .= "   <flgcancelamento>".$flcancelamento."</flgcancelamento>";
	// UF
	$xmlCarregaDados .= "   <cdsufs>".$dsuf."</cdsufs>";
	// CNAE
	$xmlCarregaDados .= "   <cdscnaes>".$dscnae."</cdscnaes>";
	// Fecha o xml de Requisicao
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados, "PARPRT", 'PARPRT_ATUALIZA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	echo 'hideMsgAguardo();';

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
	}

    echo "showError('inform','".$dsmensag."','TELA_PARPRT','fechaRotina($(\'#divRotina\'));estadoInicial();');";
?>