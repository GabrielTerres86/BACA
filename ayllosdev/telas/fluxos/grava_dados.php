<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Jaison Fernando
	  Data : Outubro/2016                       Última Alteração: --/--/----
	                                                                   
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

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
    $dtrefere = (isset($_POST['dtrefere'])) ? $_POST['dtrefere'] : '';
    $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$vldiv085 = (isset($_POST['vldiv085'])) ? converteFloat($_POST['vldiv085']) : 0 ;
	$vldiv001 = (isset($_POST['vldiv001'])) ? converteFloat($_POST['vldiv001']) : 0 ;
	$vldiv756 = (isset($_POST['vldiv756'])) ? converteFloat($_POST['vldiv756']) : 0 ;
	$vldiv748 = (isset($_POST['vldiv748'])) ? converteFloat($_POST['vldiv748']) : 0 ;
	$vldivtot = (isset($_POST['vldivtot'])) ? converteFloat($_POST['vldivtot']) : 0 ;
	$vlresgat = (isset($_POST['vlresgat'])) ? converteFloat($_POST['vlresgat']) : 0 ;
    $vlaplica = (isset($_POST['vlaplica'])) ? converteFloat($_POST['vlaplica']) : 0 ;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
    $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "   <dtrefere>".$dtrefere."</dtrefere>";
	$xml .= "   <vldiv085>".$vldiv085."</vldiv085>";
    $xml .= "   <vldiv001>".$vldiv001."</vldiv001>";
    $xml .= "   <vldiv756>".$vldiv756."</vldiv756>";
    $xml .= "   <vldiv748>".$vldiv748."</vldiv748>";
    $xml .= "   <vldivtot>".$vldivtot."</vldivtot>";
    $xml .= "   <vlresgat>".$vlresgat."</vlresgat>";
    $xml .= "   <vlaplica>".$vlaplica."</vlaplica>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, 'TELA_FLUXOS', 'FLUXOS_GRAVA_DADOS', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);					

	echo 'hideMsgAguardo();';

	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObject->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
	}

    echo "showError('inform','Valores alterados com sucesso!','FLUXOS','fechaRotina($(\'#divRotina\'));controlaOperacao();');";
?>