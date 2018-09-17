<? 
/*!
 * FONTE        : valida_coaf.php
 * CRIAÇÃO      : Cristian Filipe Fernandes (GATI)
 * DATA CRIAÇÃO : 25/04/2016
 * OBJETIVO     : Rotina de validação - opção F
 *
 * ALTERACOES   : 22/12/2014 - Adicionar validação do parametro de data (Douglas - Chamado 143945)
 *
 *			      25/04/2016 - Corrigir passagem do parâmetro cddopcao conforme solicitado no
 *							   chamado 430180. (Kelvin)
 *
 */
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	// Guardo os parâmetos do POST em variáveis	
	
	$cddopcao  = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : "" ; 
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
 	
	//Monta xml Procedure Valida_nao_justificado
	$dtmvtolt = $_POST["dtmvtolt"];
	if(!isset($_POST["dtmvtolt"]) || !validaData($dtmvtolt)) {
		exibirErro('error','Data inv&aacute;lida.','Alerta - Ayllos',"focaCampoErro('dtmvtolt', 'frmInfFechamento');",false);
	}
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "    <Bo>b1wgen0173.p</Bo>";
	$xml .= "    <Proc>Valida_COAF</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "    <cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xml .= "    <nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xml .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "    <idorigem>".$glbvars['idorigem']."</idorigem>";
	$xml .= "    <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xml .= "    <cdprogra>".$glbvars['cdprogra']."</cdprogra>";
	$xml .= "    <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);

	if (!$xmlObj->roottag->tags[0]->attributes['INFOCOAT'] == "") {
		//verifica se ha erros
		$msgConfirma	= $xmlObj->roottag->tags[0]->attributes['INFOCOAT'];
	 echo exibirConfirmacao($msgConfirma,'Confirma&ccedil;&atilde;o - Ayllos', "realizaOperacao('F');","showError('error','079 - Opera&ccedil;&atilde;o n&atilde;o realizada.','Alerta - Ayllos','estadoInicial()');',false);", false);
	} else{
		echo'realizaOperacao("F");';
	}		
	//----------------------------------------------------------
	//Final da Procedure Valida_COAF

?>	