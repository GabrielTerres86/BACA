<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Jorge I. Hamaguchi
 * DATA CRIAÇÃO : 01/03/2014
 * OBJETIVO     : Rotinas da tela DEVDOC
 * --------------
 * ALTERAÇÕES   : 22/09/2014 - Inclusão da coluna Ag Fav (Marcos-Supero)
 * -------------- 
 */ 
	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	// Recebe o POST
	$cddopcao = (isset($_POST['cddopcao']))      ? $_POST['cddopcao'] : 'D' ;
	$nrdocmto = (isset($_POST['nrdocmto']))      ? $_POST['nrdocmto'] : 0  ;
	$dtmvtodc = (isset($_POST['dtmvtolt']))      ? $_POST['dtmvtolt'] : '' ;
	$vldocmto = (isset($_POST['vldocmto']))      ? $_POST['vldocmto'] : 0  ;
	$cdbandoc = (isset($_POST['cdbandoc']))      ? $_POST['cdbandoc'] : 0  ;
	$cdagedoc = (isset($_POST['cdagedoc']))      ? $_POST['cdagedoc'] : 0  ;
	$nrctadoc = (isset($_POST['nrctadoc']))      ? $_POST['nrctadoc'] : 0  ;
	$cdmotdev = (isset($_POST['cdmotdev']))      ? $_POST['cdmotdev'] : 0  ;
	$nriniseq = (isset($_POST['nriniseq']))      ? $_POST['nriniseq'] : '' ;
	$nrregist = (isset($_POST['nrregist']))      ? $_POST['nrregist'] : '' ;
	$operacao = (isset($_POST['operacao']))      ? $_POST['operacao'] : '' ;
	$documtos = (isset($_POST['documtos']))      ? $_POST['documtos'] : '' ;
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		echo "<script>showError('error',\"".$msgErro."\",'Alerta - Ayllos',\"\");</script>";
	}
	
	if($operacao == "C"){
		$procedure = 'consulta_doc';
	}else if($operacao == "A"){
		$procedure = 'atualiza_doc';
	}else if($operacao == "S"){
		$procedure = 'salva_docs';
	}else{
		$procedure = 'busca_crapddc';
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0187.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>';	
	$xml .= '		<dtmvtodc>'.$dtmvtodc.'</dtmvtodc>';
	$xml .= '		<vldocmto>'.$vldocmto.'</vldocmto>';
	$xml .= '		<cdbandoc>'.$cdbandoc.'</cdbandoc>';
	$xml .= '		<cdagedoc>'.$cdagedoc.'</cdagedoc>';
	$xml .= '		<nrctadoc>'.$nrctadoc.'</nrctadoc>';
	$xml .= '		<cdmotdev>'.$cdmotdev.'</cdmotdev>';
	$xml .= '		<documtos>'.$documtos.'</documtos>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';	
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		$retornoAposErro = "$('#btVoltar','#divBotoes').show();$('#btnContinuar','#divBotoes').show();"; 
		
		if (!empty($nmdcampo)) { 
			$nmdoform = "frmDetalheDoc";
			$retornoAposErro .= "focaCampoErro('".$nmdcampo."','".$nmdoform."');"; 
		}
		
		$retornoAposErro .= "hideMsgAguardo();";
		
		$msgErro = "<div style='text-align:left;'>";
		$taberros = $xmlObjeto->roottag->tags[0]->tags;
		for($i=0;$i<count($taberros);$i++){
			if($i==0){
				$msgErro .= $taberros[$i]->tags[4]->cdata;
			}else{
				$msgErro .= "<br>".$taberros[$i]->tags[4]->cdata;
			}
		}	
		$msgErro .= "</div>";
		
		echo "<script>showError('error',\"".$msgErro."\",'Alerta - Ayllos',\"".$retornoAposErro."\");</script>";
		exit();
	}
	
	$devolucoes = $xmlObjeto->roottag->tags[0]->tags;
	$qtregist   = $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	
	if($operacao == "C"){
	
		include('janela_devdoc.php');
		
		echo "<script type='text/javascript'>";
		echo "var form = '#frmDetalheDoc';";
		echo "$('#cdmotdev',form).val('".getByTagName($devolucoes[0]->tags,'cdmotdev')."');"; 
		echo "$('#nrdocmto',form).val('".getByTagName($devolucoes[0]->tags,'nrdocmto')."');"; 
		echo "$('#dtmvtolt',form).val('".getByTagName($devolucoes[0]->tags,'dtmvtolt')."');"; 
		echo "$('#vldocmto',form).val('".getByTagName($devolucoes[0]->tags,'vldocmto')."');"; 
		echo "$('#cdagenci',form).val('".getByTagName($devolucoes[0]->tags,'cdagenci')."');"; 
		echo "$('#nrdconta',form).val('".getByTagName($devolucoes[0]->tags,'nrdconta')."');"; 
		echo "$('#nmfavore',form).val('".getByTagName($devolucoes[0]->tags,'nmfavore')."');"; 
		echo "$('#nrcpffav',form).val('".getByTagName($devolucoes[0]->tags,'nrcpffav')."');"; 
		echo "$('#nrctadoc',form).val('".getByTagName($devolucoes[0]->tags,'nrctadoc')."');"; 
		echo "$('#nmemiten',form).val('".getByTagName($devolucoes[0]->tags,'nmemiten')."');"; 
		echo "$('#nrcpfemi',form).val('".getByTagName($devolucoes[0]->tags,'nrcpfemi')."');"; 
		echo "$('#cdbandoc',form).val('".getByTagName($devolucoes[0]->tags,'cdbandoc')."');"; 
		echo "$('#cdagedoc',form).val('".getByTagName($devolucoes[0]->tags,'cdagedoc')."');"; 
		echo "atualizaSeletor();";
		echo "controlaLayout();";
		echo "exibeRotina($('#divRotina'));";
		if(getByTagName($devolucoes[0]->tags,'flgpcctl') == "no"){
			echo "$('#cdmotdev',form).habilitaCampo().focus();";
			echo "$('a',form).show();";
			echo "$('#btSalvar','#divDetalheDoc').show();";
		}else{
			echo "$('#cdmotdev',form).desabilitaCampo();";
			echo "$('a',form).hide();";
			echo "$('#btSalvar','#divDetalheDoc').hide();";
		}
		echo "</script>";
		
	}else if($operacao == "A"){
		echo "<script>showError('inform','Documento salvo com sucesso!','Alerta - Ayllos','estadoInicial();');</script>";
	}else if($operacao == "S"){
		echo "<script>showError('inform','Documentos salvos com sucesso!','Alerta - Ayllos','estadoInicial();');</script>";
	}else{
		include('tab_devdoc.php');
	}
	
?>

