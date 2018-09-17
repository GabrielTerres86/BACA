<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Andre Clemer
	  Data : Janeiro/2018                         �ltima Altera��o: --/--/----
	                                                                   
	  Objetivo  : Carrega os dados da tela PARPRT.
	                                                                 
	  Altera��es: 
				  
	***********************************************************************/

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
    isPostMethod();

    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
	$cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : $glbvars["cdcooper"];
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 1;

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
    $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Requisicao dos dados de parametrizacao da negativacao Serasa
	$xmlResult = mensageria($xml, "PARPRT", "PARPRT_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	 	exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
	}

	$param = $xmlObj->roottag->tags[0]->tags[0];

	$qtlimitemin_tolerancia	= getByTagName($param->tags,'qtlimitemin_tolerancia');
	$qtlimitemax_tolerancia	= getByTagName($param->tags,'qtlimitemax_tolerancia');
	$hrenvio_arquivo 		= getByTagName($param->tags,'hrenvio_arquivo');
	$qtdias_cancelamento 	= getByTagName($param->tags,'qtdias_cancelamento');
	$flcancelamento 		= getByTagName($param->tags,'flcancelamento');
	$ufs 					= getByTagName($param->tags,'dsuf');
	$param_uf 				= !empty($ufs) ? explode(',', $ufs) : "";
	$cnaes 					= getByTagName($param->tags,'dscnae');
	$cdscnaes 				= !empty($cnaes) ? explode(',', $cnaes) : "";

	/*
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <cdcnae>0</cdcnae>";
    $xml .= "   <dscnae/>";
    $xml .= "   <flserasa>0</flserasa>"; // Inativo
    $xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
    $xml .= "   <nrregist>".$nrregist."</nrregist>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Requisicao dos dados de CNAE
	$xmlResult = mensageria($xml, "MATRIC", "CONSULTA_CNAE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
	}

	$registros = $xmlObj->roottag->tags[0]->tags;
 	$qtregist = $xmlObj->roottag->tags[0]->attributes['QTREGIST'];
	*/

	include('form_parprt.php');
?>

<script type="text/javascript">	
											
	$('#qtlimitemin_tolerancia','#frmParPrt').val('<?php echo $qtlimitemin_tolerancia; ?>');
	$('#qtlimitemax_tolerancia','#frmParPrt').val('<?php echo $qtlimitemax_tolerancia; ?>');
	$('#hrenvio_arquivo','#frmParPrt').val('<?php echo $hrenvio_arquivo; ?>');
	$('#qtdias_cancelamento','#frmParPrt').val('<?php echo $qtdias_cancelamento; ?>');
	$('#flcancelamento','#frmParPrt').val('<?php echo $flcancelamento; ?>');
	$('#cnaes','#frmParPrt').val('<?php echo $cnaes; ?>');
	$('#ufs','#frmParPrt').val('<?php echo $ufs; ?>');
		
</script>