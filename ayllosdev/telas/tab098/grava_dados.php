<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Ricardo Linhares
	  Data : Dezembro/2016                       Última Alteração: --/--/----
	                                                                   
	  Objetivo  : Grava os dados.
	                                                                 
	  Alterações: 
	                                                                  
	***********************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : $glbvars["cdcooper"];

	$flgpagcont_ib 	= $_POST['flgpagcont_ib'];
	$flgpagcont_taa = $_POST['flgpagcont_taa'];
	$flgpagcont_cx  = $_POST['flgpagcont_cx'];
	$flgpagcont_mob = $_POST['flgpagcont_mob'];
	$prz_baixa_cip 	= $_POST['prz_baixa_cip'];
	$vlvrboleto 	= $_POST['vlvrboleto'];
	$rollout_cip_reg_data	= $_POST['rollout_cip_reg_data'];
	$rollout_cip_reg_valor 	= $_POST['rollout_cip_reg_valor'];
	$rollout_cip_pag_data	= $_POST['rollout_cip_pag_data'];
	$rollout_cip_pag_valor 	= $_POST['rollout_cip_pag_valor'];

    $dsmensag = 'Parâmetros alterados com sucesso!';

	// Montar o xml de Requisicao
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "	<cdcooper>".$cdcooper."</cdcooper>";
	$xmlCarregaDados .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	<flgpagcont_ib>".$flgpagcont_ib."</flgpagcont_ib>";
	$xmlCarregaDados .= "	<flgpagcont_taa>".$flgpagcont_taa."</flgpagcont_taa>";
	$xmlCarregaDados .= "	<flgpagcont_cx>".$flgpagcont_cx."</flgpagcont_cx>";
	$xmlCarregaDados .= "	<flgpagcont_mob>".$flgpagcont_mob."</flgpagcont_mob>";
	$xmlCarregaDados .= "	<prz_baixa_cip>".$prz_baixa_cip."</prz_baixa_cip>";
	$xmlCarregaDados .= "	<vlvrboleto>".$vlvrboleto."</vlvrboleto>";
	$xmlCarregaDados .= "	<rollout_cip_reg_data>".$rollout_cip_reg_data."</rollout_cip_reg_data>";
	$xmlCarregaDados .= "	<rollout_cip_reg_valor>".$rollout_cip_reg_valor."</rollout_cip_reg_valor>";
	$xmlCarregaDados .= "	<rollout_cip_pag_data>".$rollout_cip_pag_data."</rollout_cip_pag_data>";
	$xmlCarregaDados .= "	<rollout_cip_pag_valor>".$rollout_cip_pag_valor."</rollout_cip_pag_valor>";	
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados, "TELA_TAB098", TAB098_ATUALIZA, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);					

	echo 'hideMsgAguardo();';

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
	}

    echo "showError('inform','".$dsmensag."','Tab098','fechaRotina($(\'#divRotina\'));estadoInicial();');";
?>