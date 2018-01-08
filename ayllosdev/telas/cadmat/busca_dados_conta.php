<?
/*!
 * FONTE        : busca_dados_conta.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 29/09/2017
 * OBJETIVO     : Busca dados do cooperado a partir da conta informada
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */ 
?>

<?	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

	if (!validaInteiro($nrdconta) || $nrdconta == 0) exibirErro('error','Informe o número da conta.','Alerta - Ayllos','$(\'#nrdconta\', \'#frmCab\').focus()',false);

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	//$xmlResult 	= getDataXML($xml);
	$xmlResult = mensageria($xml, "TELA_CADMAT", "BUSCA_DADOS_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto 	= getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#nrdconta\', \'#frmCab\').focus()',false);
		exit();
	} 
		
	$cdagenci = getByTagname($xmlObjeto->roottag->tags,'cdagenci');
	$dtadmiss = getByTagname($xmlObjeto->roottag->tags,'dtadmiss');
	$nrmatric = getByTagname($xmlObjeto->roottag->tags,'nrmatric');
	$nrdconta = formataContaDVsimples(getByTagname($xmlObjeto->roottag->tags,'nrdconta'));
	$inpessoa = getByTagname($xmlObjeto->roottag->tags,'inpessoa');
	$dtdemiss = getByTagname($xmlObjeto->roottag->tags,'dtdemiss');
	$dstipsai = getByTagname($xmlObjeto->roottag->tags,'dstipsai');
	$dsinctva = getByTagname($xmlObjeto->roottag->tags,'dsinctva');
	$cdmotdem = getByTagname($xmlObjeto->roottag->tags,'cdmotdem');
	$dsmotdem = getByTagname($xmlObjeto->roottag->tags,'dsmotdem');
	$nmresage = getByTagname($xmlObjeto->roottag->tags,'nmresage');
	$nrcpfcgc = getByTagname($xmlObjeto->roottag->tags,'nrcpfcgc');
	$nmpessoa = getByTagname($xmlObjeto->roottag->tags,'nmpessoa');
	$cdempres = getByTagname($xmlObjeto->roottag->tags,'cdempres');
	$nmresemp = getByTagname($xmlObjeto->roottag->tags,'nmresemp');
	
	// Monta o xml de requisição
	$xmlMatric  = '';
	$xmlMatric .= '<Root>';
	$xmlMatric .= '	<Cabecalho>';
	$xmlMatric .= '		<Bo>b1wgen0052.p</Bo>';
	$xmlMatric .= '		<Proc>busca_dados</Proc>';
	$xmlMatric .= '	</Cabecalho>';
	$xmlMatric .= '	<Dados>';
	$xmlMatric .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlMatric .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlMatric .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlMatric .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlMatric .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlMatric .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlMatric .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlMatric .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xmlMatric .= '		<idseqttl>1</idseqttl>';
	$xmlMatric .= '	</Dados>';
	$xmlMatric .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xmlMatric);
	$xmlObjeto 	= getObjectXML($xmlResult);		

	// Se ocorrer um erro, mostra mensagem
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Cadmat','estadoInicial();',false);
		exit();
	} 
	
	$registro	  = ( isset($xmlObjeto->roottag->tags[0]->tags[0]->tags) ) ? $xmlObjeto->roottag->tags[0]->tags[0]->tags : array();	
	
	$rowidass = getByTagName($registro,'rowidass');
	$inmatric = getByTagName($registro,'inmatric');
	$tpdocptl = getByTagName($registro,'tpdocptl');
	$nrdocptl = getByTagName($registro,'nrdocptl');
	$nmttlrfb = getByTagName($registro,'nmttlrfb');	
	$cdsitcpf = getByTagName($registro,'cdsitcpf');
	$dtcnscpf = getByTagName($registro,'dtcnscpf');
	$dsdemail = getByTagName($registro,'dsdemail');
	$nrcepcor = getByTagName($registro,'nrcepcor');
	$dsendcor = getByTagName($registro,'dsendcor');
	$nrendcor = getByTagName($registro,'nrendcor');
	$complcor = getByTagName($registro,'complcor');
	$nmbaicor = getByTagName($registro,'nmbaicor');
	$cdufcorr = getByTagName($registro,'cdufcorr');
	$nmcidcor = getByTagName($registro,'nmcidcor');
	$idoricor = getByTagName($registro,'idoricor');
	
	// Colocar informações recebidas nos campos da tela	
	echo "$('#cdagenci','#frmCadmat').val('$cdagenci');";
	echo "$('#dtadmiss','#frmCadmat').val('$dtadmiss');";
	echo "$('#nrmatric','#frmCadmat').val('$nrmatric');";
	echo "$('#nrdconta','#frmCadmat').val('$nrdconta');";
	echo "$('#dtdemiss','#frmCadmat').val('$dtdemiss');";
	echo "$('#dstipsai','#frmCadmat').val('$dstipsai');";
	echo "$('#dsinctva','#frmCadmat').val('$dsinctva');";
	if ($cdmotdem > 0) { echo "$('#cdmotdem','#frmCadmat').val('$cdmotdem');"; }
	echo "$('#dsmotdem','#frmCadmat').val('$dsmotdem');";
	echo "$('#nmresage','#frmCadmat').val('$nmresage');";
	echo "$('#nrcpfcgc','#frmCadmat').val('$nrcpfcgc');";
	echo "$('#nmprimtl','#frmCadmat').val('$nmpessoa');";
	echo "$('#rowidass','#frmCadmat').val('$rowidass');";
	echo "$('#tpdocptl','#frmCadmat').val('$tpdocptl');";
	echo "$('#nrdocptl','#frmCadmat').val('$nrdocptl');";
	echo "$('#nmttlrfb','#frmCadmat').val('$nmttlrfb');";
	echo "$('#cdsitcpf','#frmCadmat').val('$cdsitcpf');";
	echo "$('#dtcnscpf','#frmCadmat').val('$dtcnscpf');";
	echo "$('#dsdemail','#frmCadmat').val('$dsdemail');";
	echo "$('#nrcepcor','#frmCadmat').val('$nrcepcor');";
	echo "$('#dsendcor','#frmCadmat').val('$dsendcor');";
	echo "$('#nrendcor','#frmCadmat').val('$nrendcor');";
	echo "$('#complcor','#frmCadmat').val('$complcor');";
	echo "$('#nmbaicor','#frmCadmat').val('$nmbaicor');";
	echo "$('#cdufcorr','#frmCadmat').val('$cdufcorr');";
	echo "$('#nmcidcor','#frmCadmat').val('$nmcidcor');";
	echo "$('#idoricor','#frmCadmat').val('$idoricor');";
	echo "$('#flgtermo','#frmCadmat').val('$flgtermo');";
	echo "$('#flgdigit','#frmCadmat').val('$flgdigit');";

	if ($inpessoa == 1){
		//PF 
		$dsnacion = getByTagName($registro,'dsnacion');
		$inhabmen = getByTagName($registro,'inhabmen');
		$dthabmen = getByTagName($registro,'dthabmen');
		$cdestcvl = getByTagName($registro,'cdestcv2');
		$tpnacion = getByTagName($registro,'tpnacion');
		$cdnacion = getByTagName($registro,'cdnacion');
		$cdoedptl = getByTagName($registro,'cdoedptl');
		$cdufdptl = getByTagName($registro,'cdufdptl');
		$dtemdptl = getByTagName($registro,'dtemdptl');
		$dtnasctl = getByTagName($registro,'dtnasctl');
		$nmconjug = getByTagName($registro,'nmconjug');
		$nmmaettl = getByTagName($registro,'nmmaettl');
		$nmpaittl = getByTagName($registro,'nmpaittl');
		$dsnatura = getByTagName($registro,'dsnatura');
		$cdufnatu = getByTagName($registro,'cdufnatu');
		$nrdddres = getByTagName($registro,'nrdddres');
		$nrtelres = getByTagName($registro,'nrtelres');
		$cdopetfn = getByTagName($registro,'cdopetfn');
		$nrdddcel = getByTagName($registro,'nrdddcel');
		$nrtelcel = getByTagName($registro,'nrtelcel');
		$nrcepend = getByTagName($registro,'nrcepend');
		$dsendere = getByTagName($registro,'dsendere');
		$nrendere = getByTagName($registro,'nrendere');
		$complend = getByTagName($registro,'complend');
		$nmbairro = getByTagName($registro,'nmbairro');
		$cdufende = getByTagName($registro,'cdufende');
		$nmcidade = getByTagName($registro,'nmcidade');
		$idorigee = getByTagName($registro,'idorigee');
		$cdocpttl = getByTagName($registro,'cdocpttl');
		$cdsexotl = getByTagName($registro,'cdsexotl');
		$idorgexp = getByTagName($registro,'idorgexp');
		
		// Colocar informações recebidas nos campos da tela
		echo "$('#pessoaFi', '#frmCab').prop('checked', true);";
		echo "$('#pessoaJu', '#frmCab').prop('checked', false);";
		echo "$('#dsnacion','#frmCadmat').val('$dsnacion');";
		echo "$('#inhabmen','#frmCadmat').val('$inhabmen');";
		echo "$('#dthabmen','#frmCadmat').val('$dthabmen');";
		echo "$('#cdestcvl','#frmCadmat').val('$cdestcvl');";
		echo "$('#tpnacion','#frmCadmat').val('$tpnacion');";
		echo "$('#cdnacion','#frmCadmat').val('$cdnacion');";
		echo "$('#cdoedptl','#frmCadmat').val('$cdoedptl');";
		echo "$('#cdufdptl','#frmCadmat').val('$cdufdptl');";
		echo "$('#dtemdptl','#frmCadmat').val('$dtemdptl');";
		echo "$('#dtnasctl','#frmCadmat').val('$dtnasctl');";
		echo "$('#nmconjug','#frmCadmat').val('$nmconjug');";
		echo "$('#nmmaettl','#frmCadmat').val('$nmmaettl');";
		echo "$('#nmpaittl','#frmCadmat').val('$nmpaittl');";
		echo "$('#dsnatura','#frmCadmat').val('$dsnatura');";
		echo "$('#cdufnatu','#frmCadmat').val('$cdufnatu');";
		echo "$('#nrdddres','#frmCadmat').val('$nrdddres');";
		echo "$('#nrtelres','#frmCadmat').val('$nrtelres');";
		echo "$('#cdopetfn','#frmCadmat').val('$cdopetfn');";
		echo "$('#nrdddcel','#frmCadmat').val('$nrdddcel');";
		echo "$('#nrtelcel','#frmCadmat').val('$nrtelcel');";
		echo "$('#nrcepend','#frmCadmat').val('$nrcepend');";
		echo "$('#dsendere','#frmCadmat').val('$dsendere');";
		echo "$('#nrendere','#frmCadmat').val('$nrendere');";
		echo "$('#complend','#frmCadmat').val('$complend');";
		echo "$('#nmbairro','#frmCadmat').val('$nmbairro');";
		echo "$('#cdufende','#frmCadmat').val('$cdufende');";
		echo "$('#nmcidade','#frmCadmat').val('$nmcidade');";
		echo "$('#idorigee','#frmCadmat').val('$idorigee');";
		echo "$('#cdocpttl','#frmCadmat').val('$cdocpttl');";
		echo "$('#cdsexotl','#frmCadmat').val('$cdsexotl');";
		echo "$('#idorgexp','#frmCadmat').val('$idorgexp');";		
		echo "$('#cdempres','#frmCadmat').val('$cdempres');";		
		echo "$('#nmresemp','#frmCadmat').val('$nmresemp');";		
	}else{
		// PJ
		$nmfansia = getByTagName($registro,'nmfansia');
		$nrcepend = getByTagName($registro,'nrcepend');
		$dsendere = getByTagName($registro,'dsendere');
		$nrendere = getByTagName($registro,'nrendere');
		$complend = getByTagName($registro,'complend');
		$nmbairro = getByTagName($registro,'nmbairro');
		$cdufende = getByTagName($registro,'cdufende');
		$nmcidade = getByTagName($registro,'nmcidade');
		$idorigee = getByTagName($registro,'idorigee');
		$nrdddtfc = getByTagName($registro,'nrdddtfc');
		$nrtelefo = getByTagName($registro,'nrtelefo');
		$nrinsest = getByTagName($registro,'nrinsest');
		$nrlicamb = getByTagName($registro,'nrlicamb');
		$natjurid = getByTagName($registro,'natjurid');
		$cdseteco = getByTagName($registro,'cdseteco');
		$cdrmativ = getByTagName($registro,'cdrmativ');
		$cdcnae   = getByTagName($registro,'cdclcnae');
		$dtiniatv = getByTagName($registro,'dtiniatv');
		
		// Colocar informações recebidas nos campos da tela
		echo "$('#pessoaFi', '#frmCab').prop('checked', false);";
		echo "$('#pessoaJu', '#frmCab').prop('checked', true);";
		echo "$('#nmfansia','#frmCadmat').val('$nmfansia');";
		echo "$('#nrcepend','#frmCadmat').val('$nrcepend');";
		echo "$('#dsendere','#frmCadmat').val('$dsendere');";
		echo "$('#nrendere','#frmCadmat').val('$nrendere');";
		echo "$('#complend','#frmCadmat').val('$complend');";
		echo "$('#nmbairro','#frmCadmat').val('$nmbairro');";
		echo "$('#cdufende','#frmCadmat').val('$cdufende');";
		echo "$('#nmcidade','#frmCadmat').val('$nmcidade');";
		echo "$('#idorigee','#frmCadmat').val('$idorigee');";
		echo "$('#nrdddtfc','#frmCadmat').val('$nrdddtfc');";
		echo "$('#nrtelefo','#frmCadmat').val('$nrtelefo');";
		echo "$('#nrinsest','#frmCadmat').val('$nrinsest');";
		echo "$('#nrlicamb','#frmCadmat').val('$nrlicamb');";
		echo "$('#natjurid','#frmCadmat').val('$natjurid');";
		echo "$('#cdseteco','#frmCadmat').val('$cdseteco');";
		echo "$('#cdrmativ','#frmCadmat').val('$cdrmativ');";
		echo "$('#cdcnae','#frmCadmat').val('$cdcnae');";
		echo "$('#dtiniatv','#frmCadmat').val('$dtiniatv');";

	}

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
    $xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
		
	$xmlResult = mensageria($xml, "TELA_CADMAT", "VERIFICA_BOTOES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto 	= getObjectXML($xmlResult);		
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#nrdconta\', \'#frmCab\').focus()',false);
		exit();
	}
	
	$flgsaqpr = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	$flgdesli = $xmlObjeto->roottag->tags[0]->tags[1]->cdata;

	// Alimenta as variaveis com flag de visualizacao dos botoes saque parcial e desligamento
	echo "flgsaqpr = $flgsaqpr;";
	echo "flgdesli = $flgdesli;";
	
	echo "formataTitular();";
	echo "trocaBotoes();";
	echo "cNrdconta.desabilitaCampo().removeClass('campoErro');";
?>
