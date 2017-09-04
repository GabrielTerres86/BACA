<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Jaison Fernando
	  Data : Novembro/2015                         Última Alteração: 03/08/2017
	                                                                   
	  Objetivo  : Carrega os dados da tela TAB097.
	                                                                 
	  Alterações: 03/08/2017 - Ajuste para chamar a rotina CONSULTA_CNAE (Adriano).
				  
	***********************************************************************/

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
    isPostMethod();

    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
    $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 1;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

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

	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados/>";
	$xml .= "</Root>";

	// Requisicao dos dados de parametrizacao da negativacao Serasa
	$xmlResult = mensageria($xml, "TELA_TAB097", "BUSCA_PARAM_NEG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
	}

	$param = $xmlObj->roottag->tags[0]->tags[0];

	$qtminimo_negativacao = getByTagName($param->tags,'QTMINIMO_NEGATIVACAO');
	$qtmaximo_negativacao = getByTagName($param->tags,'QTMAXIMO_NEGATIVACAO');
	$hrenvio_arquivo = getByTagName($param->tags,'HRENVIO_ARQUIVO');
	$vlminimo_boleto = getByTagName($param->tags,'VLMINIMO_BOLETO') > 0 ? formataMoeda(getByTagName($param->tags,'VLMINIMO_BOLETO')) : '';
	$qtdias_vencimento = getByTagName($param->tags,'QTDIAS_VENCIMENTO');
	$qtdias_negativacao = getByTagName($param->tags,'QTDIAS_NEGATIVACAO');

	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
    $xml .= "   <indexcecao>0</indexcecao>";
	$xml .= "   <dsuf>0</dsuf>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	// Requisicao dos dados de parametrizacao da excecao de negativacao Serasa
	$xmlResult = mensageria($xml, "TELA_TAB097", "BUSCA_PARAM_NEG_EXC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
	}

	$param_uf = $xmlObj->roottag->tags[0]->tags[0]->tags;
	$param_ufnegdif = $xmlObj->roottag->tags[0]->tags[1]->tags;

	include('form_tab097.php');
?>

<script type="text/javascript">	
											
	$('#qtminimo_negativacao','#frmTab097').val('<?php echo $qtminimo_negativacao; ?>');
	$('#qtmaximo_negativacao','#frmTab097').val('<?php echo $qtmaximo_negativacao; ?>');
	$('#hrenvio_arquivo','#frmTab097').val('<?php echo $hrenvio_arquivo; ?>');
	$('#vlminimo_boleto','#frmTab097').val('<?php echo $vlminimo_boleto; ?>');
	$('#qtdias_vencimento','#frmTab097').val('<?php echo $qtdias_vencimento; ?>');
	$('#qtdias_negativacao','#frmTab097').val('<?php echo $qtdias_negativacao; ?>');
		
</script>