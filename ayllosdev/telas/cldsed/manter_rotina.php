<? 
/*!
 * FONTE        : manter_rotina.php							Última alteração: 10/
 * CRIAÇÃO      : Cristian Filipe Fernandes        
 * DATA CRIAÇÃO : 21/11/2013
 * OBJETIVO     : Rotina para manter as operações da tela CLDSED
 * --------------
 * ALTERAÇÕES   : 06/01/2014 - Adicionado os campos de data para realizar as validações de fechamento nas opção "F" e "J" (Douglas - Chamado 143945)

				  08/08/2016 - Ajuste para inclusão de controle de paginação
							  (Adriano - SD 495725).

				  10/02/2017 - Adicionando funcao para elimitar caracteres invalidos ao carregar informacoes
							   conforme solicitado no chamado 582636.
 * -------------- 
 */
 
    session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();		
	
	// Inicializa
	$procedure 		= "";
	$retornoAposErro= "";
	
	// Recebe a operação que está sendo realizada
	$cddopcao  = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : "" ; 
	$opvaljus  = (isset($_POST["opvaljus"])) ? $_POST["opvaljus"] : "" ; 

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibirErro("error",$msgError,"Alerta - Ayllos","",false);
	}
	
	$flextjus  = (isset($_POST["flextjus"])) ? $_POST["flextjus"] : "";
	$dtmvtolt  = (isset($_POST["dtmvtolt"])) ? $_POST["dtmvtolt"] : "";
	$nrdrowid  = (isset($_POST["nrdrowid"])) ? $_POST["nrdrowid"] : "";
	$cddjusti  = (isset($_POST["cddjusti"])) ? $_POST["cddjusti"] : "";
	$dsdjusti  = (isset($_POST["dsdjusti"])) ? $_POST["dsdjusti"] : "";
	$dsobsctr  = (isset($_POST["dsobsctr"])) ? $_POST["dsobsctr"] : "";
	$opeenvcf  = (isset($_POST["opeenvcf"])) ? $_POST["opeenvcf"] : "";
	$infrepcf  = (isset($_POST["infrepcf"])) ? $_POST["infrepcf"] : "";
	$dtrefini  = (isset($_POST["dtrefini"])) ? $_POST["dtrefini"] : "";
	$dtreffim  = (isset($_POST["dtreffim"])) ? $_POST["dtreffim"] : "";
	$cdincoaf  = (isset($_POST["cdincoaf"])) ? $_POST["cdincoaf"] : "";
	$nrdconta  = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";
	$cdstatus  = (isset($_POST["cdstatus"])) ? $_POST["cdstatus"] : "";
	$nriniseq  = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 0;
	$nrregist  = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 0;

	// Dependendo da operação, utilizar uma procedure diferente e realizar as validações dos campos correspondentes
	switch($cddopcao) {
		case "C": 
			$procedure = "Carrega_creditos";
			// Para a opção é necessário validar apenas a data e se o campo com Justificativa foi preenchido
			if( !validaData($dtmvtolt) ){
				exibirErro("error","Data inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('dtmvtolt', 'frmInfConsultaMovimentacao');",false);
			}

			if( $flextjus <> "no" && $flextjus <> "yes"){
				exibirErro("error","Com Justificativa inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('flextjus', 'frmInfConsultaMovimentacao');",false);
			}
		break;
		
		case "J": 
			$procedure = "Justifica_movimento";
			// Validação dos campos de justificativa
			if( !validaData($dtmvtolt) ){
				exibirErro("error","Data inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('dtmvtolt', 'frmInfConsultaMovimentacao');",false);
			}
			
			if( $flextjus <> "no" && $flextjus <> "yes"){
				exibirErro("error","Com Justificativa inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('flextjus', 'frmInfConsultaMovimentacao');",false);
			}
			
			if( !validaInteiro($cddjusti) && !($cddjusti > 0)){
				exibirErro("error","Justificativa inv&aacute;lido.","Alerta - Ayllos","focaCampoErro('cddjusti', 'frmInfConsultaMovimentacao');",false);
			}
			
			if( !validaInteiro($dsdjusti) && $dsdjusti == ""){
				exibirErro("error","Descri&ccedil;&atilde;o da Justificativa inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('dsdjusti', 'frmInfConsultaMovimentacao');",false);
			}
			
			if( !validaInteiro($cdincoaf) && !($cdincoaf > 0)){
				exibirErro("error","COAF inv&aacute;lido.","Alerta - Ayllos","focaCampoErro('cdincoaf', 'frmInfConsultaMovimentacao');",false);
			}
			
			if( !validaInteiro($cdstatus) && !($cdstatus > 0)){
				exibirErro("error","Status inv&aacute;lido.","Alerta - Ayllos","focaCampoErro('cdstatus', 'frmInfConsultaMovimentacao');",false);
			}
			
			if( $nrdrowid == ""){
				exibirErro("error","Identificador Inv&aacute;lido.","Alerta - Ayllos","",false);
			}
			
			if( $infrepcf == ""){
				exibirErro("error","COAF (Informar/N&atilde;o Informar) inv&aacute;lido.","Alerta - Ayllos","focaCampoErro('infrepcf', 'frmInfConsultaMovimentacao');",false);
			}
		break;
		
		
		case "F": 
			$procedure = "Efetiva_fechamento";
			//Para o fechamento é necessário apenas a data de movimentação informado em tela
			if( !validaData($dtmvtolt) ){
				exibirErro("error","Data inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('dtmvtolt', 'frmInfFechamento');",false);
			}
		break;
		
		case "X": 
			$procedure = "Cancela_fechamento";
			//Para o cancelamento do fechamento é necessário apenas a data de movimentação informado em tela
			if( !validaData($dtmvtolt) ){
				exibirErro("error","Data inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('dtmvtolt', 'frmInfFechamento');",false);
			}
		break;
		
		case "P": 
			$procedure = "Carrega_pesquisa";
			// Validação para carregar a pesquisa
			if( !validaInteiro($cdincoaf) && !($cdincoaf > 0)){
				exibirErro("error","COAF inv&aacute;lido.","Alerta - Ayllos","focaCampoErro('cdincoaf', 'frmInfConsultaDetalheMov');",false);
			}
			
			if( !validaInteiro($cdstatus) && !($cdstatus > 0)){
				exibirErro("error","Status inv&aacute;lido.","Alerta - Ayllos","focaCampoErro('cdstatus', 'frmInfConsultaDetalheMov');",false);
			}
			//Validação para as datas inicial e final
			if( !validaData($dtrefini) ){
				exibirErro("error","Data in&iacute;cio inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('dtrefini', 'frmInfConsultaDetalheMov');",false);
			}
			
			if( !validaData($dtreffim) ){
				exibirErro("error","Data final inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('dtreffim', 'frmInfConsultaDetalheMov');",false);
			}
		break;
		
		case "T": 
			$procedure = "Carrega_atividade";
			
			//Validação para as datas inicial e final
			if( !validaData($dtrefini) ){
				exibirErro("error","Data in&iacute;cio inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('dtrefini', 'frmInfListaMovimentacoes');",false);
			}
			
			if( !validaData($dtreffim) ){
				exibirErro("error","Data final inv&aacute;lida.","Alerta - Ayllos","focaCampoErro('dtreffim', 'frmInfListaMovimentacoes');",false);
			}
		break;
		
		default:
			exibirErro("error","Op&ccedil;&atilde;o inv&aacute;lida.","Alerta - Ayllos","estadoInicial();",false);
	}

	// Rotinas de validação para a Opção F
	if($cddopcao == "F") {
		/* Validação 	*/
		// Monta o xml de requisi&ccedil;&atilde;o
		$xmlSetPesquisa  = "";
		$xmlSetPesquisa .= "<Root>";
		$xmlSetPesquisa .= "  <Cabecalho>";
		$xmlSetPesquisa .= "	    <Bo>b1wgen0173.p</Bo>";
		$xmlSetPesquisa .= "        <Proc>Valida_nao_justificado</Proc>";
		$xmlSetPesquisa .= "  </Cabecalho>";
		$xmlSetPesquisa .= "  <Dados>";
		$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlSetPesquisa .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlSetPesquisa .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlSetPesquisa .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xmlSetPesquisa .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlSetPesquisa .= "        <cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
		$xmlSetPesquisa .= "        <cdbccxlt>".$glbvars["cdbccxlt"]."</cdbccxlt>";
		$xmlSetPesquisa .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		$xmlSetPesquisa .= "        <teldtmvtolt>".$dtmvtolt."</teldtmvtolt>";
		$xmlSetPesquisa .= "  </Dados>";
		$xmlSetPesquisa .= "</Root>";
		
		$xmlResult = getDataXML($xmlSetPesquisa );
		$xmlObjPesquisa = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
			$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$erros = exibirErro("error",$msgErro,"Alerta - Ayllos","focaCampoErro('dtmvtolt', 'frmInfFechamento');",false);
			die;
		}
	
		/* Validação 	*/
	}
	// Rotinas de validação para a Opção J
	if($opvaljus == "J")
	{
			
		/* Validação 	*/
		// Monta o xml de requisi&ccedil;&atilde;o
		$xmlSetPesquisa  = "";
		$xmlSetPesquisa .= "<Root>";
		$xmlSetPesquisa .= "  <Cabecalho>";
		$xmlSetPesquisa .= "	    <Bo>b1wgen0173.p</Bo>";
		$xmlSetPesquisa .= "        <Proc>valida_fechamento</Proc>";
		$xmlSetPesquisa .= "  </Cabecalho>";
		$xmlSetPesquisa .= "  <Dados>";
		$xmlSetPesquisa .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlSetPesquisa .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlSetPesquisa .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlSetPesquisa .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlSetPesquisa .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xmlSetPesquisa .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
		$xmlSetPesquisa .= "        <cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
		$xmlSetPesquisa .= "        <cdbccxlt>".$glbvars["cdbccxlt"]."</cdbccxlt>";
		$xmlSetPesquisa .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
		$xmlSetPesquisa .= "        <teldtmvtolt>".$dtmvtolt."</teldtmvtolt>";
		$xmlSetPesquisa .= "  </Dados>";
		$xmlSetPesquisa .= "</Root>";
		
		$xmlResult = getDataXML($xmlSetPesquisa );
		$xmlObjPesquisa = getObjectXML($xmlResult);
		// Se ocorrer um erro, mostra cr&iacute;tica
		if (strtoupper($xmlObjPesquisa->roottag->tags[0]->name) == "ERRO") {
			$msgErro	= $xmlObjPesquisa->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$erros = exibirErro("error",$msgErro,"Alerta - Ayllos","focaCampoErro('dtmvtolt', 'frmInfConsultaMovimentacao');",false);
			die;
		}
		/* Validação 	*/
	}
	// Rotinas de validação para a Opção F 

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0173.p</Bo>";
	$xml .= "        <Proc>".$procedure."</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "        <cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
	
	/*Valida Opção que utilizara o DTMVTOLT com parametro passado pela tela*/
	if($cddopcao == "C")
		$xml .= "        <dtmvtolt>".$dtmvtolt."</dtmvtolt>";
	else
		$xml .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
		
	$xml .="         <flextjus>".$flextjus."</flextjus>";
	$xml .="         <nrdrowid>".$nrdrowid."</nrdrowid>";
	$xml .="         <cddjusti>".$cddjusti."</cddjusti>";
	$xml .="         <dsdjusti>".$dsdjusti."</dsdjusti>";
	$xml .="         <dsobsctr>".$dsobsctr."</dsobsctr>";
	$xml .="         <opeenvcf>".$opeenvcf."</opeenvcf>";
	$xml .="         <infrepcf>".$infrepcf."</infrepcf>";
	$xml .="         <dtrefini>".$dtrefini."</dtrefini>";
	$xml .="         <dtreffim>".$dtreffim."</dtreffim>";
	$xml .="         <cdincoaf>".$cdincoaf."</cdincoaf>";
	$xml .="         <nrdconta>".$nrdconta."</nrdconta>";
	$xml .="         <cdstatus>".$cdstatus."</cdstatus>";
	$xml .= "        <teldtmvtolt>".$dtmvtolt."</teldtmvtolt>";	
	$xml .= "        <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "        <nrregist>".$nrregist."</nrregist>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML(removeCaracteresInvalidos($xmlResult));

	$qtregist  = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro("error",$msgErro,"Alerta - Ayllos",$retornoAposErro,false);
	}
	
	$pesquisa = $xmlObjeto->roottag->tags[0]->tags;
	
	switch ($cddopcao){
		case "C":
			//Inclui tabela dos registros
			include("tab_carrega_creditos.php");
		break;

		case "P":
			//Inclui tabela dos registros
			include("tab_carrega_pesquisa.php");
		break;

		case "T":
			//Inclui tabela dos registros
			include("tab_carrega_atividade.php");
		break;

		case "F":
			exibirErro("inform","Fechamento realizado com sucesso","Alerta - Ayllos","estadoInicial();",false);
		break;

		case "X":
			exibirErro("inform","Fechamento desfeito ","Alerta - Ayllos","estadoInicial();",false);
		break;

		case "J":
			exibirErro("inform","Movimento Justificado","Alerta - Ayllos","estadoInicial();",false);
		break;
	}
?>
