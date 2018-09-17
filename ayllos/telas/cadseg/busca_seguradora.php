<?php
	//*********************************************************************************************//
	//*** Fonte: busca_seguradora.php                         	                                ***//
	//*** Autor: Cristian Filipe                                                                ***//
	//*** Data : Novembro/2013                                                                  ***//
	//*** Objetivo  : Lista ou cria a seguradora dependendo a opção que o usuario escolher      ***//
	//*** Alteracoes:											Ultima Alteracao: 23/01/2014	***//
	/*	  23/01/2014 - Ajustes gerais para liberacao. (Jorge)									   */
	//*********************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	
    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : ''; 
    $cdsegura = (isset($_POST['cdsegura'])) ? $_POST['cdsegura'] : '';
	
	// Verifica Permiss&atilde;o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}	
	
	
	// verifica se a opção digitada a I
	$cddopcao=="I"?$procedure="Valida_inclusao_seguradora":$procedure="Retorna_seguradoras";
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "	    <Bo>b1wgen0181.p</Bo>";
	$xmlSetPesquisa .= "        <Proc>'{$procedure}'</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetPesquisa .= "        <nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xmlSetPesquisa .= "        <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xmlSetPesquisa .= "        <dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";
	$xmlSetPesquisa .= "        <idorigem>".$glbvars['idorigem']."</idorigem>";
	$xmlSetPesquisa .= "        <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xmlSetPesquisa .= "        <cdprogra>".$glbvars['cdprogra']."</cdprogra>";
	$xmlSetPesquisa .= "        <cdsegura>".$cdsegura."</cdsegura>";	
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";
	
	// Executa script para envio do XML
	
	$xmlResult = getDataXML($xmlSetPesquisa);
	
	$xmlObjPesquisa = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
		
		$nmdcampo = $xmlObjPesquisa->roottag->tags[0]->attributes['NMDCAMPO'];
		$retornoAposErro = "$('#btVoltar','#divBotoes').show();$('#btnContinuar','#divBotoes').show();"; 
		
		if (!empty($nmdcampo)) { 
			$nmdoform = "frmInfSeguradora";
			$retornoAposErro .= "$('#cddopcao','#frmCab').val('".$cddopcao."');focaCampoErro('".$nmdcampo."','".$nmdoform."');"; 
		}else{
			$retornoAposErro .= "$('#cddopcao','#frmCab').habilitaCampo();";
			$retornoAposErro .= "estadoInicial();";
		}
		$retornoAposErro .= "hideMsgAguardo();";
		
		$msgErro = "<div style='text-align:left;'>";
		$taberros = $xmlObjPesquisa->roottag->tags[0]->tags;
		for($i=0;$i<count($taberros);$i++){
			if($i==0){
				$msgErro .= $taberros[$i]->tags[4]->cdata;
			}else{
				$msgErro .= "<br>".$taberros[$i]->tags[4]->cdata;
			}
		}	
		$msgErro .= "</div>";
		 
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		
		exit();
		
	}	
	
	$registros = $xmlObjPesquisa->roottag->tags[0]->tags;
	
	echo "var cTodosFormSeguradora = $('input[type=\"text\"],select,input[type=\"checkbox\"]','#frmInfSeguradora');"; 
	echo "var cTodosFormHistorico  = $('input[type=\"text\"],select,input[type=\"checkbox\"]','#frmInfHistorico');";
	
	echo "$('#cdsegura','#frmInfSeguradora').val('".mascara(getByTagName($registros[0]->tags, 'cdsegura'),'###.###.###')."').desabilitaCampo();";
	
	echo "$('#nmsegura','#frmInfSeguradora').val('".getByTagName($registros[0]->tags, 'nmsegura')."');";
	echo "$('#nmresseg','#frmInfSeguradora').val('".getByTagName($registros[0]->tags, 'nmresseg')."');";
	if(getByTagName($registros[0]->tags, 'flgativo') == "yes"){
		echo "$('#flgativo','#frmInfSeguradora').attr('checked', 'checked');";
	}else{
		echo "$('#flgativo','#frmInfSeguradora').removeAttr('checked');";
	}
	echo "$('#nrcgcseg','#frmInfSeguradora').val('".formatar(getByTagName($registros[0]->tags, 'nrcgcseg'), 'cnpj')."');";
	echo "$('#nrctrato','#frmInfSeguradora').val('".mascara(getByTagName($registros[0]->tags, 'nrctrato'), '##.###.###')."');";
	echo "$('#nrultpra','#frmInfSeguradora').val('".mascara(getByTagName($registros[0]->tags, 'nrultpra'), '###.###.###')."');";
	echo "$('#nrlimpra','#frmInfSeguradora').val('".mascara(getByTagName($registros[0]->tags, 'nrlimpra'), '###.###.###')."');";
	echo "$('#nrultprc','#frmInfSeguradora').val('".mascara(getByTagName($registros[0]->tags, 'nrultprc'), '###.###.###')."');";
	echo "$('#nrlimprc','#frmInfSeguradora').val('".mascara(getByTagName($registros[0]->tags, 'nrlimprc'), '###.###.###')."');";
	echo "$('#dsasauto','#frmInfSeguradora').val('".getByTagName($registros[0]->tags, 'dsasauto')."');";
	
	//segunda tela
	echo "$('#cdhstaut1','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.1'), '#.###')."');";
	echo "$('#cdhstaut2','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.2'), '#.###')."');";
	echo "$('#cdhstaut3','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.3'), '#.###')."');";
	echo "$('#cdhstaut4','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.4'), '#.###')."');";
	echo "$('#cdhstaut5','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.5'), '#.###')."');";
	echo "$('#cdhstaut6','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.6'), '#.###')."');";
	echo "$('#cdhstaut7','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.7'), '#.###')."');";
	echo "$('#cdhstaut8','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.8'), '#.###')."');";
	echo "$('#cdhstaut9','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.9'), '#.###')."');";
	echo "$('#cdhstaut10','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[4]->tags, 'cdhstaut.10'), '#.###')."');";
	
	echo "$('#cdhstcas1','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.1'), '#.###')."');";
	echo "$('#cdhstcas2','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.2'), '#.###')."');";
	echo "$('#cdhstcas3','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.3'), '#.###')."');";
	echo "$('#cdhstcas4','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.4'), '#.###')."');";
	echo "$('#cdhstcas5','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.5'), '#.###')."');";
	echo "$('#cdhstcas6','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.6'), '#.###')."');";
	echo "$('#cdhstcas7','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.7'), '#.###')."');";
	echo "$('#cdhstcas8','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.8'), '#.###')."');";
	echo "$('#cdhstcas9','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.9'), '#.###')."');";
	echo "$('#cdhstcas10','#frmInfHistorico').val('".mascara(getByTagName($registros[0]->tags[5]->tags, 'cdhstcas.10'), '#.###')."');";
	
	echo "$('#dsmsgseg','#frmInfHistorico').val('".getByTagName($registros[0]->tags, 'dsmsgseg')."');";
	
	if($cddopcao == "C"){
		echo "cTodosFormSeguradora.desabilitaCampo();";
		echo "cTodosFormHistorico.desabilitaCampo();";
		echo "$('#btSalvar', '#divBotoes').focus();";
	}else if($cddopcao == "I" || $cddopcao == "A"){
		echo "cTodosFormSeguradora.habilitaCampo();";
		echo "cTodosFormHistorico.habilitaCampo();";
		echo "$('#cdsegura','#frmInfSeguradora').desabilitaCampo();";
		echo "$('#nmsegura','#frmInfSeguradora').focus();";
	}else{
		echo "$('#btSalvar', '#divBotoes').focus();";
	}
	echo "hideMsgAguardo();";
	
?>