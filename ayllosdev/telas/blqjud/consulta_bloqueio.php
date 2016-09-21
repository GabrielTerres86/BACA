<?php

	//************************************************************************//
	//*** Fonte: consulta_bloqueio.php                                     ***//
	//*** Autor: Guilherme / SUPERO                                        ***//
	//*** Data : Maio/2013                   Última Alteração: 18/12/2014  ***//
	//***                                                                  ***//
	//*** Objetivo  : Exibir os dados obtidos na consulta dos              ***//	
	//***             processamentos do BLOQUEIO JUDICIAL.                 ***//
	//***                                                                  ***//
	//***                                                                  ***//
	//*** Alterações: 06/09/2013 - Incluido tag <cddopcao> como parametro  ***//
	//***             			   (Lucas R.)       					   ***//
	//***                          									       ***//
	//***             17/09/2014 - Retirado tt-grid. 					   ***//
	//***						   (Jorge/Gielow - SD 175038)			   ***//
	//***                          									       ***//
	//***             18/12/2014 - Ajuste para mostrar tabela no retorno.  ***//
	//***						   (Jorge/Gielow - SD 228463)			   ***//
	//************************************************************************//
	
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica permiss&atilde;o
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C");
		
	$nroficon = $_POST["nroficon"];
	$nrctacon = $_POST["nrctacon"];
	$operacao = $_POST["operacao"];
	$opcao    = $_POST["cddopcao"];
	
	// Monta o xml de requisição
	$xmlConsulta  = "";
	$xmlConsulta .= "<Root>";
	$xmlConsulta .= "	<Cabecalho>";
	$xmlConsulta .= "		<Bo>b1wgen0155.p</Bo>";
	$xmlConsulta .= "		<Proc>consulta-bloqueio-jud</Proc>";
	$xmlConsulta .= "	</Cabecalho>";
	$xmlConsulta .= "	<Dados>";
	$xmlConsulta .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "		<operacao>".$operacao."</operacao>";
	$xmlConsulta .= "		<cddopcao>".$opcao."</cddopcao>";	
	$xmlConsulta .= "		<nrctacon>".$nrctacon."</nrctacon>";
	$xmlConsulta .= "		<nroficon>".$nroficon."</nroficon>";
	$xmlConsulta .= "	</Dados>";
	$xmlConsulta .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjConsulta = getObjectXML($xmlResult);
	
	$msgErro = $xmlObjConsulta->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsulta->roottag->tags[0]->name) == "ERRO") { 
		echo "<script>";
		echo "$('#divAcaojud').css({'display':'none'});";
		echo "$('#divDesbloqueio').css({'display':'none'});";
		echo "$('#divConsulta').css({'display':'block'});";
		echo "controlaBotoes(2);";
		echo "</script>";
		
		exibirErro('error',$msgErro,'Alerta - BLQJUD','hideMsgAguardo();$(\'#nroficon\',\'#frmConsulta\').focus();',true);				
	}		
	$dados = $xmlObjConsulta->roottag->tags[0]->tags;
	
	echo "<script>";
	echo "arrbloqueios.length = 0;"; //limpando array
	$seq = 0;
	foreach( $dados as $banco) {
		echo "arrbloqu".$seq." = new Object();";
		echo "arrbloqu".$seq."['flblcrft'] = '".getByTagName($banco->tags,'FLBLCRFT')."';";
		echo "arrbloqu".$seq."['nrdconta'] = '".getByTagName($banco->tags,'NRDCONTA')."';";
		echo "arrbloqu".$seq."['fldestrf'] = '".getByTagName($banco->tags,'FLDESTRF')."';";
		echo "arrbloqu".$seq."['fldesblq'] = '".getByTagName($banco->tags,'FLDESBLQ')."';";
		echo "arrbloqu".$seq."['dtblqfim'] = '".getByTagName($banco->tags,'DTBLQFIM')."';";
		echo "arrbloqu".$seq."['nroficio'] = '".getByTagName($banco->tags,'NROFICIO')."';";
		echo "arrbloqu".$seq."['nrproces'] = '".getByTagName($banco->tags,'NRPROCES')."';";
		echo "arrbloqu".$seq."['dsjuizem'] = '".getByTagName($banco->tags,'DSJUIZEM')."';";
		echo "arrbloqu".$seq."['dsresord'] = '".getByTagName($banco->tags,'DSRESORD')."';";
		echo "arrbloqu".$seq."['dtenvres'] = '".getByTagName($banco->tags,'DTENVRES')."';";
		echo "arrbloqu".$seq."['vltotblq'] = '".number_format(str_replace(",",".",getByTagName($dados[0]->tags,'VLTOTBLQ')),2,",",".")."';";
		echo "arrbloqu".$seq."['dsinfadc'] = '".getByTagName($banco->tags,'DSINFADC')."';";
		echo "arrbloqu".$seq."['nrofides'] = '".getByTagName($banco->tags,'NROFIDES')."';";
		echo "arrbloqu".$seq."['dtenvdes'] = '".getByTagName($banco->tags,'DTENVDES')."';";
		echo "arrbloqu".$seq."['dsinfdes'] = '".getByTagName($banco->tags,'DSINFDES')."';";
		echo "arrbloqueios[".$seq."] = arrbloqu".$seq.";";
		$seq = $seq + 1;
	}	
	echo "$('#divConsulta').css({'display':'block'});";
	echo "$('#nroficon','#frmConsulta').desabilitaCampo();";
	echo "$('#nrctacon','#frmConsulta').desabilitaCampo();";
	echo "</script>";
				
	if ($operacao == "C" || $operacao == "D" || $operacao == "A") {
		include('form_consulta_dados.php'); 
		if($operacao == "C" || $operacao == "D"){
			include('form_desbloqueio.php');	
		}
		echo "<script>$('#div_tabblqjud').css({'display':'block'});layoutConsulta();</script>";
	}
	// selecinando a primeira linha do grid
	echo "<script>if(arrbloqueios.length > 0){ selecionaBloqueio(0);} hideMsgAguardo();</script>";
	
?>
