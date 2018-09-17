<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Jaison Fernando
	  Data : Novembro/2016                       Última Alteração: --/--/----
	                                                                   
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
    $dsoperac = (isset($_POST['dsoperac'])) ? $_POST['dsoperac'] : '';
    $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
    $iddgrupo = (isset($_POST['iddgrupo'])) ? $_POST['iddgrupo'] : 0;

    // OPCAO G
	$iddgrup2 = (isset($_POST['iddgrup2'])) ? $_POST['iddgrup2'] : 0 ;
	$nmdgrupo = (isset($_POST['nmdgrupo'])) ? $_POST['nmdgrupo'] : '';
	$indconte = (isset($_POST['indconte'])) ? $_POST['indconte'] : 0;
	$dsassunt = (isset($_POST['dsassunt'])) ? $_POST['dsassunt'] : '';
	$indperio = (isset($_POST['indperio'])) ? $_POST['indperio'] : 0;

    // OPCAO A / OPCAO E
    $vlcampos = (isset($_POST['vlcampos'])) ? $_POST['vlcampos'] : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    if ($cddopcao == 'G') {
        $nmdeacao = ($dsoperac == 'E' ? 'CONINC_EXCLUI_GRUPO' : 'CONINC_GRAVA_GRUPO');
    } else if ($cddopcao == 'A' || $cddopcao == 'E') {
        $nmdeacao = 'CONINC_GRAVA_ACE_EML';
    }

    if ($dsoperac == 'A') {
        $dsmensag = 'Altera&ccedil;&atilde;o';
    } else if ($dsoperac == 'E') {
        $dsmensag = 'Exclus&atilde;o';
    } else if ($dsoperac == 'I') {
        $dsmensag = 'Inclus&atilde;o';
    }

	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
    $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
    $xml .= "   <dsoperac>".$dsoperac."</dsoperac>";
    $xml .= "   <iddgrupo>".$iddgrupo."</iddgrupo>";
    // OPCAO G
    $xml .= "   <iddgrup2>".$iddgrup2."</iddgrup2>";
	$xml .= "   <nmdgrupo>".utf8_decode($nmdgrupo)."</nmdgrupo>";
    $xml .= "   <indconte>".$indconte."</indconte>";
    $xml .= "   <dsassunt>".utf8_decode($dsassunt)."</dsassunt>";
    $xml .= "   <indperio>".$indperio."</indperio>";
    // OPCAO A / OPCAO E
    $xml .= "   <vlcampos>".$vlcampos."</vlcampos>";
	$xml .= " </Dados>";
	$xml .= "</Root>";


	$xmlResult = mensageria($xml, 'TELA_CONINC', $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);					

	echo 'hideMsgAguardo();';

	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObject->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
	}

    echo "showError('inform','" . $dsmensag . " efetuada com sucesso!','CONINC','fechaRotina($(\'#divRotina\'));$(\'#dsoperac\', \'#frmCab\').val(\'C\');controlaOperacao(1,30);');";
?>