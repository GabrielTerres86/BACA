<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Jaison Fernando
	  Data : Novembro/2015                       Última Alteração: --/--/----
	                                                                   
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

	$acao				  = (isset($_POST['acao']))                 ? $_POST['acao']                 : ''  ;
	$cddopcao             = (isset($_POST['cddopcao']))             ? $_POST['cddopcao']             : ''  ;
	$dsvalor              = (isset($_POST['dsvalor']))              ? $_POST['dsvalor']              : ''  ;
	$qtminimo_negativacao = (isset($_POST['qtminimo_negativacao'])) ? $_POST['qtminimo_negativacao'] : ''  ;
	$qtmaximo_negativacao = (isset($_POST['qtmaximo_negativacao'])) ? $_POST['qtmaximo_negativacao'] : ''  ;
	$hrenvio_arquivo      = (isset($_POST['hrenvio_arquivo']))      ? $_POST['hrenvio_arquivo']      : ''  ;
	$vlminimo_boleto      = (isset($_POST['vlminimo_boleto']))      ? converteFloat($_POST['vlminimo_boleto']) : ''  ;
	$qtdias_vencimento    = (isset($_POST['qtdias_vencimento']))    ? $_POST['qtdias_vencimento']    : ''  ;
    $qtdias_negativacao   = (isset($_POST['qtdias_negativacao']))   ? $_POST['qtdias_negativacao']   : ''  ;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    switch ($acao) {
        case 'CNAE':
			$nmdeacao = 'ALTERA_PARAM_CNAE';
			$flserasa = 0;
			$dsmensag = 'CNAE incluido com sucesso!';
			if ($cddopcao == 'E') {
				$flserasa = 1;
				$dsmensag = 'CNAE excluido com sucesso!';
			}
            break;

        case 'UF':
            $nmdeacao   = 'ALTERA_PARAM_NEG_UF';
			$arrDados   = explode('|', $dsvalor);
			$indexcecao = $arrDados[0];
			$dsuf       = $arrDados[1];
			$dsmensag   = $cddopcao == 'A' ? 'UF alterada com sucesso!' : 'UF incluida com sucesso!';
			if ($cddopcao == 'E') {
				$nmdeacao = 'EXCLUI_PARAM_NEG';
				$dsmensag = 'UF excluida com sucesso!';
			}
            break;

        default: // PARAM
            $nmdeacao = 'ALTERA_PARAM_NEG';
			$dsmensag = 'Parametros alterados com sucesso!';
    }

	// Montar o xml de Requisicao
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	// PARAM
	$xmlCarregaDados .= "   <qtminimo_negativacao>".$qtminimo_negativacao."</qtminimo_negativacao>";
	$xmlCarregaDados .= "   <qtmaximo_negativacao>".$qtmaximo_negativacao."</qtmaximo_negativacao>";
	$xmlCarregaDados .= "   <hrenvio_arquivo>".$hrenvio_arquivo."</hrenvio_arquivo>";
	$xmlCarregaDados .= "   <vlminimo_boleto>".$vlminimo_boleto."</vlminimo_boleto>";
	$xmlCarregaDados .= "   <qtdias_vencimento>".$qtdias_vencimento."</qtdias_vencimento>";
	$xmlCarregaDados .= "   <qtdias_negativacao>".$qtdias_negativacao."</qtdias_negativacao>";
	// CNAE
	$xmlCarregaDados .= "   <cdcnae>".$dsvalor."</cdcnae>";
	$xmlCarregaDados .= "   <flserasa>".$flserasa."</flserasa>";
	// UF
	$xmlCarregaDados .= "   <indexcecao>".$indexcecao."</indexcecao>";
	$xmlCarregaDados .= "   <dsuf>".$dsuf."</dsuf>";
	// Fecha o xml de Requisicao
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados, "TELA_TAB097", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);					

	echo 'hideMsgAguardo();';

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObj->roottag->tags[0]->cdata,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
	}

    echo "showError('inform','".$dsmensag."','Tab097','fechaRotina($(\'#divRotina\'));estadoInicial();');";
?>