<?php
/*
 * FONTE        : gera_imprime_Arq_pesquisa.php				Última alteração: 05/08/2016
 * CRIAÇÃO      : Cristian Filipe Fernandes (GATI)
 * DATA CRIAÇÃO : 16/09/2013
 * OBJETIVO     : Rotina para impressao da pesquisa - opção P

      Alterações: 05/08/2016 - Ajuste para gerar o arquivo para impressão de forma correta
							   (Adriano - SD 495725).

				  09/09/2016 - Ajuste de permissão na opção P, conforme solicitado no chamado 509376 (Kelvin).


 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Guardo os parâmetos do POST em variáveis
	$nrdconta  = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
	$cdincoaf  = isset($_POST["cdincoaf"]) ? $_POST["cdincoaf"] : 0;
	$cdstatus  = isset($_POST["cdstatus"]) ? $_POST["cdstatus"] : 0;
	$dtrefini  = isset($_POST["dtrefini"]) ? $_POST["dtrefini"] : '';
	$dtreffim  = isset($_POST["dtreffim"]) ? $_POST["dtreffim"] : '';
	$saida     = isset($_POST["saida"]) ? $_POST["saida"] : '';
	$nmarquivo = isset($_POST["nmarquivo"]) ? $_POST["nmarquivo"] : '';
	$dsiduser = session_id();

	validaDados();

	// Monta o xml de requisição
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "    <Bo>b1wgen0173.p</Bo>";
	$xmlSetPesquisa .= "    <Proc>Gera_imprime_arq_pesquisa</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xmlSetPesquisa .= "    <cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xmlSetPesquisa .= "    <nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xmlSetPesquisa .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xmlSetPesquisa .= "    <idorigem>".$glbvars['idorigem']."</idorigem>";
	$xmlSetPesquisa .= "    <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xmlSetPesquisa .= "    <cdprogra>".$glbvars['cdprogra']."</cdprogra>";
	$xmlSetPesquisa .= "    <cdincoaf>".$cdincoaf."</cdincoaf>";
	$xmlSetPesquisa .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetPesquisa .= "    <cdstatus>".$cdstatus."</cdstatus>";
	$xmlSetPesquisa .= "    <dtrefini>".$dtrefini."</dtrefini>";
	$xmlSetPesquisa .= "    <dtreffim>".$dtreffim."</dtreffim>";
	$xmlSetPesquisa .= "    <tpdsaida>".$saida."</tpdsaida>";
	$xmlSetPesquisa .= "    <dsiduser>".$dsiduser."</dsiduser>";

	if($saida == 'A'){
		$xmlSetPesquisa .= "     <nmarquiv>".$nmarquivo."</nmarquiv>";	
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
			
		if( !validaInteiro($GLOBALS["nrdconta"])){
			exibirErro('error','N&uacute;mero da conta inv&aacute;lida.','Alerta - Ayllos','$(\'input,select\',\'#frmInfConsultaDetalheMov\').habilitaCampo();focaCampoErro(\'nrdconta\',\'frmInfConsultaDetalheMov\');',false);
		}

		if( !validaInteiro($GLOBALS["cdincoaf"])){
			exibirErro('error','COAF inv&aacute;lida.','Alerta - Ayllos','$(\'input,select\',\'#frmInfConsultaDetalheMov\').habilitaCampo();focaCampoErro(\'cdincoaf\',\'frmInfConsultaDetalheMov\');',false);
		}

		if( !validaData($GLOBALS["dtrefini"])){
			exibirErro('error','Data de inicio inv&aacute;lida.','Alerta - Ayllos','$(\'input,select\',\'#frmInfConsultaDetalheMov\').habilitaCampo();focaCampoErro(\'dtrefini\',\'frmInfConsultaDetalheMov\');',false);
		}

		if( !validaData($GLOBALS["dtreffim"])){
			exibirErro('error','Data final inv&aacute;lida.','Alerta - Ayllos','$(\'input,select\',\'#frmInfConsultaDetalheMov\').habilitaCampo();focaCampoErro(\'dtreffim\',\'frmInfConsultaDetalheMov\');',false);
		}

		if( !validaInteiro($GLOBALS['cdstatus'])){
			exibirErro('error','Status inv&aacute;lido.','Alerta - Ayllos','$(\'input,select\',\'#frmInfConsultaDetalheMov\').habilitaCampo();focaCampoErro(\'cdstatus\',\'frmInfConsultaDetalheMov\');',false);
		}

		if( $GLOBALS["saida"] == "A" && $GLOBALS['nmarquivo'] == ""){
			exibirErro('error','Nome do arquivo inv&aacute;lido.','Alerta - Ayllos','$(\'input,select\',\'#frmInfConsultaDetalheMov\').habilitaCampo();focaCampoErro(\'nmarquivo\',\'frmInfConsultaDetalheMov\');',false);
	}

		if( $GLOBALS['saida'] == ""){
			exibirErro('error','Sa&Iacute;da do arquivo inv&aacute;lido.','Alerta - Ayllos','$(\'input,select\',\'#frmInfConsultaDetalheMov\').habilitaCampo();focaCampoErro(\'saida\',\'frmInfConsultaDetalheMov\');',false);
			
	}

	}
?>
