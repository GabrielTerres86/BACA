<?php
	/*********************************************************************
	 Fonte: manter_rotina.php
	 Autor: Jean Calao - Mout´S
	 Data : Mai/2017                Ultima Alteracao: 24/05/2017

	 Objetivo  : Tratar as requisicoes da tela PARTRP

	 Alteracoes:
	**********************************************************************/

	session_start();

	// Includes para controle da session, variaveis globais de controle, e biblioteca de funcoes
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$dsvlrprm1 = $_POST["dsvlrprm1"];
	$dsvlrprm2 = $_POST["dsvlrprm2"];
	$dsvlrprm3 = $_POST["dsvlrprm3"];
	$dsvlrprm4 = $_POST["dsvlrprm4"];
	$dsvlrprm5 = $_POST["dsvlrprm5"];
	$dsvlrprm6 = $_POST["dsvlrprm6"];
	$dsvlrprm7 = $_POST["dsvlrprm7"];
	$dsvlrprm8 = $_POST["dsvlrprm8"];
	$dsvlrprm9 = $_POST["dsvlrprm9"];
	$dsvlrprm10 = $_POST["dsvlrprm10"];
	$dsvlrprm11 = $_POST["dsvlrprm11"];
	$dsvlrprm12 = $_POST["dsvlrprm12"];
	$dsvlrprm13 = $_POST["dsvlrprm13"];
	$dsvlrprm14 = $_POST["dsvlrprm14"];
	$dsvlrprm15 = $_POST["dsvlrprm15"];
	$dsvlrprm16 = $_POST["dsvlrprm16"];
	$dsvlrprm17 = $_POST["dsvlrprm17"];
	$dsvlrprm18 = $_POST["dsvlrprm18"];
	$dsvlrprm19 = $_POST["dsvlrprm19"];
	$dsvlrprm20 = $_POST["dsvlrprm20"];
	$dsvlrprm21 = $_POST["dsvlrprm21"];
	$dsvlrprm22 = $_POST["dsvlrprm22"];
	$dsvlrprm23 = $_POST["dsvlrprm23"];
	$dsvlrprm24 = $_POST["dsvlrprm24"];
	$dsvlrprm25 = $_POST["dsvlrprm25"];
	
	
	$dsvlprmgl  = $dsvlrprm3 .';'.$dsvlrprm4.';'.$dsvlrprm5.';'.$dsvlrprm6.';'.$dsvlrprm7.';'.$dsvlrprm8.';'.$dsvlrprm9.';'.$dsvlrprm10.';'.$dsvlrprm11.';';
	$dsvlprmgl .= $dsvlrprm12 .';'.$dsvlrprm13.';'.$dsvlrprm14.';'.$dsvlrprm15.';'.$dsvlrprm16.';'.$dsvlrprm17.';'.$dsvlrprm18.';'.$dsvlrprm19.';'.$dsvlrprm20.';';
	$dsvlprmgl .= $dsvlrprm21 .';'.$dsvlrprm22.';'.$dsvlrprm23.';'.$dsvlrprm24.';'.$dsvlrprm25;
	
    // Verifica Permissao
	if (($msgError = validaPermissao($glbvars["nmdatela"],"","A")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','voltar()',false);
	}

	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "    <dsvlrprm1>".$dsvlrprm1."</dsvlrprm1>";
	$xml .= "    <dsvlrprm2>".$dsvlrprm2."</dsvlrprm2>";
	$xml .= "    <dsvlprmgl>".$dsvlprmgl."</dsvlprmgl>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
		

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PARTRP", "TRFPRJ_GRAVA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
    
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') { 
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$cdCmpErr = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
        
		// Aqui estao todos os tratamentos de erro retornados pelo Oracle
		if ($cdCmpErr > 0) {
			switch ($cdCmpErr) {

				case 51:
					$dsComand = 'Cdsvlrprm6.focus();Cdsvlrprm6.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico transferencia Valor Principal deve ser um hist&oacute;rico de cr&eacute;dito!';
					break;
				case 52:
					$dsComand = 'Cdsvlrprm7.focus();Cdsvlrprm7.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico Estorno valor principal deve ser um hist&oacute;rico de d&eacute;bito!';
					break;
				case 53:
					$dsComand = 'Cdsvlrprm8.focus();Cdsvlrprm8.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico transferencia juros + 60 deve ser um hist&oacute;rico de cr&eacute;dito!';
					break;
				case 54:
					$dsComand = 'Cdsvlrprm9.focus();Cdsvlrprm9.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico estorno juros + 60 deve ser um hist&oacute;rico de d&eacute;bito!';
					break;
				case 61:
					$dsComand = 'Cdsvlrprm6.focus();Cdsvlrprm6.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 62:
					$dsComand = 'Cdsvlrprm7.focus();Cdsvlrprm7.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 63:
					$dsComand = 'Cdsvlrprm8.focus();Cdsvlrprm8.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				case 64:
					$dsComand = 'Cdsvlrprm9.focus();Cdsvlrprm9.addClass(\'campoErro\');';
					$msgErro  = 'Hist&oacute;rico inexistente!';
					break;
				default:
					$dsComand = '';
			}
		}

		exibirErro('error',$msgErro,'Alerta - Ayllos',$dsComand,false);
	}

?>
