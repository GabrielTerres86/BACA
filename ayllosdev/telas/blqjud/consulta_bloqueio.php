<?php

	//**************************************************************************//
	//*** Fonte: consulta_bloqueio.php                                       ***//
	//*** Autor: Guilherme / SUPERO                                          ***//
	//*** Data : Maio/2013                   Última Alteração: 08/02/2017    ***//
	//***                                                                    ***//
	//*** Objetivo  : Exibir os dados obtidos na consulta dos                ***//	
	//***             processamentos do BLOQUEIO JUDICIAL.                   ***//
	//***                                                                    ***//
	//***                                                                    ***//
	//*** Alterações: 06/09/2013 - Incluido tag <cddopcao> como parametro    ***//
	//***             			   (Lucas R.)       					     ***//
	//***                          									         ***//
	//***             17/09/2014 - Retirado tt-grid. 					     ***//
	//***						   (Jorge/Gielow - SD 175038)			     ***//
	//***                          									         ***//
	//***             18/12/2014 - Ajuste para mostrar tabela no retorno.    ***//
	//***						   (Jorge/Gielow - SD 228463)			     ***//
	//***                                                                    ***//
	//***             29/07/2016 - Ajuste para controle de permissão sobre   ***//
	//***                          as subrotinas de cada opção	             ***//
    //***                         (Adriano - SD 492902).                     ***//
	//***                                                                    ***//
	//***             08/02/2017 - Chamda da funcao RemoveCaracteresInvalido ***// 
	//*** 						   para ajustar o problema do chamado		 ***//
	//***	  					   562089 (Kelvin)							 ***//                                                    
  //***                                                                      ***//
  //***             29/09/2017 - Melhoria 460 - (Andrey Formigari - Mouts)   ***//
	//****************************************************************************//
	
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$operacao = $_POST["operacao"];
	$opcao    = $_POST["cddopcao"];
	$nroficon = $_POST["nroficon"];
	$nrctacon = $_POST["nrctacon"];

	// Verifica permiss&atilde;o
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$opcao);

	$nmrotina = $glbvars["nmrotina"];
	 
	switch ($opcao){

		case 'B': $glbvars["nmrotina"] = "BLQ JUDICIAL"; break;
		case 'C': $glbvars["nmrotina"] = "BLQ CAPITAL"; break;
		case 'T': $glbvars["nmrotina"] = "TRF JUDICIAL"; break;		
		
	}

	// Verifica permiss&atilde;o da subrotina
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$operacao);

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
	
	$glbvars["nmrotina"] = $nmrotina;

	// Cria objeto para classe de tratamento de XML
	$xmlObjConsulta = getObjectXML(removeCaracteresInvalidos($xmlResult));
	
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
	
  // Monta o xml de requisição
	$xmlConsultaOficio  = "";
	$xmlConsultaOficio .= "<Root>";
	$xmlConsultaOficio .= "	<Cabecalho>";
	$xmlConsultaOficio .= "		<Bo>b1wgen0155.p</Bo>";
	$xmlConsultaOficio .= "		<Proc>consulta-bloqueio-jud-oficio</Proc>";
	$xmlConsultaOficio .= "	</Cabecalho>";
	$xmlConsultaOficio .= "	<Dados>";
	$xmlConsultaOficio .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsultaOficio .= "		<nrctacon>".$nrctacon."</nrctacon>";
	$xmlConsultaOficio .= "		<nroficon>".$nroficon."</nroficon>";
	$xmlConsultaOficio .= "	</Dados>";
	$xmlConsultaOficio .= "</Root>";
	
	$xmlResultOficio = getDataXML($xmlConsultaOficio);
	$xmlObjConsultaOficio = getObjectXML($xmlResultOficio);
	$oficios = $xmlObjConsultaOficio->roottag->tags[0]->tags;
	
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
		echo "arrbloqu".$seq."['idmodali'] = '".getByTagName($banco->tags,'IDMODALI')."';";
		echo "arrbloqu".$seq."['vlbloque'] = '".number_format(str_replace(",",".",getByTagName($banco->tags,'VLBLOQUE')),2,",",".")."';";
		echo "arrbloqueios[".$seq."] = arrbloqu".$seq.";";

		$seq = $seq + 1;
	}	
	echo "$('#divConsulta').css({'display':'block'});";
	echo "$('#nroficon','#frmConsulta').desabilitaCampo();";
	echo "$('#nrctacon','#frmConsulta').desabilitaCampo();";
	echo "</script>";
				
	if ($operacao == "C" || $operacao == "D" || $operacao == "A") {
		include('form_consulta_oficio.php');
		include('form_consulta_dados.php'); 
		if($operacao == "C" || $operacao == "D"){
			//include('form_desbloqueio.php');
		}
		echo "<script>$('#div_tabblqjud').css({'display':'block'});layoutConsulta();</script>";
	}
	
	//Busca a primeira linha no grid de ofícios e a seleciona. Ao selecionar, preenche com o valor total bloqueado o campo de desbloqueio
	$tmp_nroficio = '';
	$tmp_nrdconta = '';
	if (count($oficios) > 0) { 
		$oficio = $oficios[0];
		$tmp_nroficio = preg_replace("/[^0-9]/", "", getByTagName($oficio->tags,'NROFICIO'));
		$tmp_nrdconta = getByTagName($oficio->tags,'NRDCONTA');
	}

	echo "<script>if(arrbloqueios.length > 0){ selecionaOficio('$tmp_nroficio','$tmp_nrdconta');} hideMsgAguardo();</script>";

	
?>
