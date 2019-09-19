<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Ricardo Linhares
	  Data : Dezembro/2016                         Última Alteração: 01/08/2017
	                                                                   
	  Objetivo  : Carrega os dados da tela TAB098.
	                                                                 
	  Alterações: 01/08/2017 - Excluir campos para habilitar contigencia e incluir campo para valor limite.
                               PRJ340-NPC (Odirlei-AMcom)
				  
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

	$vlcontig_cip 	= getByTagName($param->tags,'vlcontig_cip');
	$prz_baixa_cip 	= getByTagName($param->tags,'prz_baixa_cip');
	$vlvrboleto 	= getByTagName($param->tags,'vlvrboleto'); //> 0 ? formataMoeda(getByTagName($param->tags,'vlvrboleto')) : '';

	$sit_pag_divergente = getByTagName($param->tags,'sit_pag_divergente');
	$pag_a_menor 	    = getByTagName($param->tags,'pag_a_menor');
	$pag_a_maior 	    = getByTagName($param->tags,'pag_a_maior');
	$tip_tolerancia     = getByTagName($param->tags,'tip_tolerancia');
	$vl_tolerancia 	    = getByTagName($param->tags,'vl_tolerancia');
	
	$dtcadast   = getByTagName($param->tags,'dtcadast');
	$cdoperad   = getByTagName($param->tags,'cdoperad');
	
	include('form_tab098.php');
?>

<script type="text/javascript">	

	$('#vlcontig_cip','#frmTab098').val('<?php echo $vlcontig_cip; ?>');
	$('#prz_baixa_cip','#frmTab098').val('<?php echo $prz_baixa_cip; ?>');
	$('#vlvrboleto','#frmTab098').val('<?php echo $vlvrboleto; ?>');
	
	$('#sit_pag_divergente','#frmTab098').val('<?=$sit_pag_divergente;?>');
	$('#pag_a_menor','#frmTab098').prop('checked', <?=$pag_a_menor;?>);
	$('#pag_a_maior','#frmTab098').prop('checked', <?=$pag_a_maior;?>);
	$('#tip_tolerancia','#frmTab098').val('<?=$tip_tolerancia;?>');
	$('#vl_tolerancia','#frmTab098').val('<?=$vl_tolerancia;?>');
	
        $("#dtcadast", "#frmTab098").html('<?=$dtcadast;?>');
        $("#cdoperad", "#frmTab098").html('<?=$cdoperad;?>');	
		
</script>