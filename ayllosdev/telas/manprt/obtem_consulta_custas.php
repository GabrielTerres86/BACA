<?php
	/***********************************************************************
	Fonte: obtem_consulta_custas.php                                              
	Autor: André Clemer                                                  
	Data : Abril/2018                       Última Alteração: - 		   
																		
	Objetivo  : Consulta de custas para front-end.              
																		
	Alterações: 
	
	***********************************************************************/
	session_start();
		
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'@')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}	

	// Recebe o POST
	$inidtpro 			= $_POST['inidtpro'] ;
	$fimdtpro 			= $_POST['fimdtpro'];
    $cdcooper 			= (!empty($_POST['cdcooper'])) ? $_POST['cdcooper'] : 3;
    $nrdconta 			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta']  : null;
	$cduflogr 			= (isset($_POST['cduflogr'])) ? $_POST['cduflogr']  : null;
    $dscartor 			= (isset($_POST['dscartor'])) ? $_POST['dscartor']  : null;
	$flcustas 			= (!empty($_POST['flcustas'])) ? $_POST['flcustas'] : null;

	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";	
    $xml .= "   <dtinicial>".$inidtpro."</dtinicial>";
	$xml .= "   <dtfinal>".$fimdtpro."</dtfinal>";
	$xml .= "   <cdestado>".$cduflogr."</cdestado>";
	$xml .= "   <cartorio></cartorio>";
	$xml .= "   <flcustas>".$flcustas."</flcustas>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_MANPRT", "CONSULTA_CUSTAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	//print_r($xmlObjeto);
	//exit;

	// Se ocorrer um erro, mostra critica
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
	 	exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}

	$registros 	= $xmlObjeto->roottag->tags[0]->tags;

	//include('form_opcao_cabecalho.php');
	include('form_opcao_r.php');
	include('form_consulta_custas.php');
		
?>

<script>
	controlaOpcao();
</script>