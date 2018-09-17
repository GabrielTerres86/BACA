<?php 
/*!
 * FONTE        : gera_imprime_Arq_atividade.php				Última alteração: 05/08/2016
 * CRIAÇÃO      : Cristian Filipe Fernandes (GATI)
 * DATA CRIAÇÃO : 16/09/2013 
 * OBJETIVO     : Rotina para impressao da atividade - opção T
   
      Alterações: 05/08/2016 - Ajuste para gerar o arquivo para impressão de forma correta
							   (Adriano - SD 495725).

 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	$cddopcao = (isset($_POST["opcao"])) ? $_POST["opcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Guardo os parâmetos do POST em variáveis
	$dtrefini  = isset($_POST["dtrefini"]) ? $_POST["dtrefini"] : '';
	$dtreffim  = isset($_POST["dtreffim"]) ? $_POST["dtreffim"] : '';
	$saida     = isset($_POST["saida"]) ? $_POST["saida"] : '';
	$nmarquivo = isset($_POST["nmarquivo"]) ? $_POST["nmarquivo"] : '';
	$excel     = isset($_POST["excel"]) ? $_POST["excel"] : '';
	$dsiduser = session_id();

	validaDados();
	
	// Monta o xml de requisição
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "    <Bo>b1wgen0173.p</Bo>";
	$xmlSetPesquisa .= "    <Proc>Gera_imprime_arq_atividade</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xmlSetPesquisa .= "    <cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xmlSetPesquisa .= "    <nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xmlSetPesquisa .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xmlSetPesquisa .= "    <idorigem>".$glbvars['idorigem']."</idorigem>";
	$xmlSetPesquisa .= "    <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xmlSetPesquisa .= "    <cdprogra>".$glbvars['cdprogra']."</cdprogra>";
	$xmlSetPesquisa .= "    <dtrefini>".$dtrefini."</dtrefini>";
	$xmlSetPesquisa .= "    <dtreffim>".$dtreffim."</dtreffim>";
	$xmlSetPesquisa .= "    <tpdsaida>".$saida."</tpdsaida>";
	$xmlSetPesquisa .= "    <dsiduser>".$dsiduser."</dsiduser>";
	if($saida == "A"){
		$xmlSetPesquisa .= "    <nmarquiv>".$nmarquivo."</nmarquiv>";	
		$xmlSetPesquisa .= "    <gerexcel>".$excel."</gerexcel>";	
	}
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa);
	$xmlObj = getObjectXML($xmlResult);
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	}
	
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);					
		
	} 
	
	if($saida == "I"){
		// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
		$nmarqpdf = $xmlObj->roottag->tags[0]->attributes["NMARQPDF"];
		
		echo 'Gera_Impressao("'.$nmarqpdf.'","btnVoltar();");';				
			
	}

	echo "fechaRotina($('#divRotina'));";
	echo "estadoInicial();";

	function validaDados(){

		if( !validaData($GLOBALS["dtrefini"])){
			exibirErro('error','Data de inicio inv&aacute;lida.','Alerta - Ayllos','$(\'input,select\',\'#frmInfListaMovimentacoes\').habilitaCampo();focaCampoErro(\'dtrefini\',\'frmInfListaMovimentacoes\');',false);
		}

		if( !validaData($GLOBALS["dtreffim"])){
			exibirErro('error','Data final inv&aacute;lida.','Alerta - Ayllos','$(\'input,select\',\'#frmInfListaMovimentacoes\').habilitaCampo();focaCampoErro(\'dtreffim\',\'frmInfListaMovimentacoes\');',false);
		}

		if( $GLOBALS["saida"] == "A" && $GLOBALS['nmarquivo'] == ""){
			exibirErro('error','Nome do arquivo inv&aacute;lido.','Alerta - Ayllos','$(\'input,select\',\'#frmInfListaMovimentacoes\').habilitaCampo();focaCampoErro(\'nmarquivo\',\'frmInfListaMovimentacoes\');',false);
		}

		if( $GLOBALS['saida'] == ""){
			exibirErro('error','Sa&Iacute;da do arquivo inv&aacute;lido.','Alerta - Ayllos','$(\'input,select\',\'#frmInfListaMovimentacoes\').habilitaCampo();focaCampoErro(\'saida\',\'frmInfListaMovimentacoes\');',false);
			
	}
	
	}
?>