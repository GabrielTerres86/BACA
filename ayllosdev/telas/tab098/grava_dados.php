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