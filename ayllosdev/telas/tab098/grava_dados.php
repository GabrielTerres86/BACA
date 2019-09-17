<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Ricardo Linhares
	  Data : Dezembro/2016                       Última Alteração: 01/08/2017
	                                                                   
	  Objetivo  : Grava os dados.
	                                                                 
	  Alterações: 01/08/2017 - Excluir campos para habilitar contigencia e incluir campo para valor limite.
                               PRJ340-NPC (Odirlei-AMcom)
	                                                                  
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

	$prz_baixa_cip 	= $_POST['prz_baixa_cip'];
	$vlvrboleto 	= $_POST['vlvrboleto'];
    $vlcontig_cip 	= $_POST['vlcontig_cip'];

    $sit_pag_divergente = $_POST['sit_pag_divergente'];
    $pag_a_menor 	= $_POST['pag_a_menor'];
    $pag_a_maior 	= $_POST['pag_a_maior'];
    $tip_tolerancia 	= $_POST['tip_tolerancia'];
    $vl_tolerancia 	= $_POST['vl_tolerancia'];
    
    $dsmensag = 'Parâmetros alterados com sucesso!';

	// Montar o xml de Requisicao
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "	<cdcooper>".$cdcooper."</cdcooper>";
	$xmlCarregaDados .= "	<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	<prz_baixa_cip>".$prz_baixa_cip."</prz_baixa_cip>";
	$xmlCarregaDados .= "	<vlvrboleto>".$vlvrboleto."</vlvrboleto>";
    $xmlCarregaDados .= "	<vlcontig_cip>". $vlcontig_cip.   "</vlcontig_cip>";
	$xmlCarregaDados .= "	<sit_pag_divergente>"    .$sit_pag_divergente.     "</sit_pag_divergente>";
	$xmlCarregaDados .= "	<pag_a_menor>"           .$pag_a_menor.            "</pag_a_menor>";
	$xmlCarregaDados .= "	<pag_a_maior>"           .$pag_a_maior.            "</pag_a_maior>";
	$xmlCarregaDados .= "	<tip_tolerancia>"        .$tip_tolerancia.         "</tip_tolerancia>";
	$xmlCarregaDados .= "	<vl_tolerancia>"         .$vl_tolerancia.          "</vl_tolerancia>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados, "TELA_TAB098", TAB098_ATUALIZA, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);					

	echo 'hideMsgAguardo();';

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		if ($xmlObj->roottag->tags[0]->cdata == '') {
			exibirErro('error','Erro inesperado no processo','Alerta - Ayllos',"fechaRotina($(\'#divRotina\'));",false);
		} else {
			exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos',"fechaRotina($(\'#divRotina\'));",false);
		}
	}

    echo "showError('inform','".$dsmensag."','Tab098','fechaRotina($(\'#divRotina\'));estadoInicial();');";
?>