<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Ricardo Linhares
	  Data : Dezembro/2016                         Última Alteração: --/--/----		   
	                                                                   
	  Objetivo  : Carrega os dados da tela TAB098.
	                                                                 
	  Alterações: 
				  
	***********************************************************************/

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
    isPostMethod();

    $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : $glbvars["cdcooper"];

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
    $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= " </Dados>";
	$xml .= "</Root>";


	// Requisicao dos dados de parametrizacao da negativacao Serasa
	$xmlResult = mensageria($xml, "TELA_TAB098", "TAB098_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
	}

	$param = $xmlObj->roottag->tags[0]->tags[0];

	$flgpagcont_ib 	= getByTagName($param->tags,'flgpagcont_ib');
	$flgpagcont_taa 	= getByTagName($param->tags,'flgpagcont_taa');
	$flgpagcont_cx 	= getByTagName($param->tags,'flgpagcont_cx');
	$flgpagcont_mob 	= getByTagName($param->tags,'flgpagcont_mob');
	$prz_baixa_cip 	= getByTagName($param->tags,'prz_baixa_cip');
	$vlvrboleto 	= getByTagName($param->tags,'vlvrboleto'); //> 0 ? formataMoeda(getByTagName($param->tags,'vlvrboleto')) : '';
	$rollout_cip_reg_data	= getByTagName($param->tags,'rollout_cip_reg_data');
	$rollout_cip_reg_valor 	= getByTagName($param->tags,'rollout_cip_reg_valor'); //> 0 ? formataMoeda(getByTagName($param->tags,'rollout_cip_reg_valor')) : '';
	$rollout_cip_pag_data	= getByTagName($param->tags,'rollout_cip_pag_data');
	$rollout_cip_pag_valor 	= getByTagName($param->tags,'rollout_cip_pag_valor');// > 0 ? formataMoeda(getByTagName($param->tags,'rollout_cip_pag_valor')) : '';

	include('form_tab098.php');
?>

<script type="text/javascript">	

	$('#flgpagcont_ib','#frmTab098').val('<?php echo $flgpagcont_ib; ?>');
	$('#flgpagcont_taa','#frmTab098').val('<?php echo $flgpagcont_taa; ?>');
	$('#flgpagcont_cx','#frmTab098').val('<?php echo $flgpagcont_cx; ?>');
	$('#flgpagcont_mob','#frmTab098').val('<?php echo $flgpagcont_mob; ?>');
	$('#prz_baixa_cip','#frmTab098').val('<?php echo $prz_baixa_cip; ?>');
	$('#vlvrboleto','#frmTab098').val('<?php echo $vlvrboleto; ?>');
	$('#rollout_cip_reg_data','#frmTab098').val('<?php echo $rollout_cip_reg_data; ?>');
	$('#rollout_cip_reg_valor','#frmTab098').val('<?php echo $rollout_cip_reg_valor; ?>');
	$('#rollout_cip_pag_data','#frmTab098').val('<?php echo $rollout_cip_pag_data; ?>');
	$('#rollout_cip_pag_valor','#frmTab098').val('<?php echo $rollout_cip_pag_valor; ?>');
		
</script>