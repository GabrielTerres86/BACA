<?
/*!
 * FONTE        : validar_novo.php
 * CRIA��O      : Guilherme
 * DATA CRIA��O : Marco/2008
 * OBJETIVO     : Validar Novo Cart�o de Cr�dito - rotina de Cart�o de Cr�dito da tela ATENDA
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: [03/11/2010] David       (CECRED) : Adapta��es para Cart�o PJ
 * 001: [10/05/2011] Rodolpho    (DB1) : Adapta��es para o formul�rio gen�rico de avalistas
 * 002: [01/04/2013] Adriano     (CECRED) : Incluido os parametros idorigem, nmdatela, cdoperad na chamada da procedure valida_nova_proposta
 * 003: [02/05/2014] Jean Michel (CECRED) : Incluido novos parametros para cartoes bancoob
 * 004: [23/10/2014] Vanessa     (CECRED) : Retirada da tela avalista conforme SD 204632
 * 005: [23/10/2014] Vanessa     (CECRED) : Obrigar o Preecnhimeto do campo forma de Pagamento SD 236434
 * 006: [09/10/2015] James		 (CECRED) : Desenvolvimento do projeto 126.
 * 007: [17/06/2016] Rafael M.   (RKAM)   : - M181 - Alterar o CDAGENCI para passar o CDPACTRA
 * 008: [29/06/2016] Kelvin      (CECRED) : Ajuste para que o campo "Plastico da Empresa" seja obrigat�rio. SD 476461
 * 009: [09/12/2016] Kelvin		 (CECRED) : Ajuste realizado conforme solicitado no chamado 574068. 										  
 */
?>

<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro,false);
	}	
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) ||
	    !isset($_POST["inpessoa"]) ||
        !isset($_POST["dsgraupr"]) ||
        !isset($_POST["nmtitcrd"]) ||
        !isset($_POST["dsadmcrd"]) ||
        !isset($_POST["dscartao"]) ||
        !isset($_POST["vllimpro"]) ||
	    !isset($_POST["vllimdeb"]) ||
        !isset($_POST["nrcpfcgc"]) ||
        !isset($_POST["dddebito"]) ||
        !isset($_POST["dtnasccr"]) ||
        !isset($_POST["nrdoccrd"]) ||
		!isset($_POST["dsrepinc"]) ||
        !isset($_POST["flgimpnp"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}	

	$nrdconta = $_POST["nrdconta"];
	$inpessoa = $_POST["inpessoa"];
	$dsgraupr = $_POST["dsgraupr"];
	$nmtitcrd = $_POST["nmtitcrd"];
	$dsadmcrd = $_POST["dsadmcrd"];
	$dscartao = $_POST["dscartao"];
	$vllimpro = str_replace( ".", ",", $_POST["vllimpro"]);
	$vllimdeb = $_POST["vllimdeb"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$dddebito = $_POST["dddebito"];
	$dtnasccr = $_POST["dtnasccr"];
	$nrdoccrd = $_POST["nrdoccrd"];
	$flgimpnp = $_POST["flgimpnp"];
	$dsrepinc = $_POST["dsrepinc"];
	$tpdpagto = $_POST["tpdpagto"];
	$dsrepres = $_POST["dsrepres"];
	$nmempres = $_POST["nmempres"];
	
	//Bloqueado solicitacao de novo cartao para cooperativa transulcred SD 574068
	if($glbvars["cdcooper"] == 17) exibirErro('error','Solicita&ccedil;&atilde;o n&atilde;o autorizada.','Alerta - Ayllos',$funcaoAposErro,false);
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	
	// Verifica se tipo de pessoa � um inteiro v�lido
	if (!validaInteiro($inpessoa)) exibirErro('error','Tipo de pessoa inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	
	// Verifica se valor do limite � um decimal v�lido
	if (!validaDecimal($vllimpro)) exibirErro('error','Valor do Limite de Cr&eacute;dito inv&aacute;lido ERRO.','Alerta - Ayllos',$funcaoAposErro,false);
	
	// Verifica se valor do limite � um decimal v�lido
	if (!validaDecimal($vllimdeb)) exibirErro('error','Valor do Limite de D&eacute;bito inv&aacute;lido.','Alerta - Ayllos',$funcaoAposErro,false);

	// Verifica se valor do limite � um decimal v�lido
	if (!validaInteiro($nrcpfcgc)) exibirErro('error','N&uacute;mero de CPF inv&aacute;lido.','Alerta - Ayllos',$funcaoAposErro,false);
	
	// Verifica se data de nascimento � uma data v�lida
	if (!validaData($dtnasccr)) exibirErro('error','Data de nascimento inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	
	// Verifica se a forma de pagamento foi selecionada
	if ($tpdpagto == 0) exibirErro('error','Forma de Pagamento inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	
	// Verifica se a empresa do plastico foi informada
	if (empty($nmempres) && $inpessoa == 2) exibirErro('error','Empresa do Plastico deve ser informada.','Alerta - Ayllos',$funcaoAposErro,false);
	
    // Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_nova_proposta</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<dsgraupr>".$dsgraupr."</dsgraupr>";
	$xmlSetCartao .= "		<nmtitcrd>".$nmtitcrd."</nmtitcrd>";
	$xmlSetCartao .= "		<dsadmcrd>".$dsadmcrd."</dsadmcrd>";
	$xmlSetCartao .= "		<dscartao>".$dscartao."</dscartao>";
	$xmlSetCartao .= "		<vllimpro>".$vllimpro."</vllimpro>";
	$xmlSetCartao .= "		<vllimdeb>".$vllimdeb."</vllimdeb>";
	$xmlSetCartao .= "		<nrcpfcpf>".$nrcpfcgc."</nrcpfcpf>";
	$xmlSetCartao .= "		<dddebito>".$dddebito."</dddebito>";
	$xmlSetCartao .= "		<dtnasccr>".$dtnasccr."</dtnasccr>";
	$xmlSetCartao .= "		<nrdoccrd>".$nrdoccrd."</nrdoccrd>";
	$xmlSetCartao .= "		<dsrepinc>".$dsrepinc."</dsrepinc>";
	$xmlSetCartao .= "		<dsrepres>".$dsrepres."</dsrepres>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

    // Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$funcaoAposErro,false);	
	} 	

	// Mostra se Bo retornar mensagem de atualiza��o de cadastro
	$idconfir = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$dsmensag = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
	
	if ($inpessoa <> "1") {
	
		echo 'habilitaAvalista(true);';
		echo 'hideMsgAguardo();';
		echo 'bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);';		
		
		// Mostra mensagem de confirma��o para finalizar a opera��o
		echo "showConfirmacao('".(trim($dsmensag) <> "" ? $dsmensag."<br><br>" : "")."Deseja cadastrar a proposta de novo cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Ayllos','cadastrarNovoCartao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');";		
		exit();
		
	} else {
	   
		/*  RETIRADA DA TELA AVALISTA CONFORME SD 204632
		echo '$("#divDadosNovoCartao").css("display","none");';
		echo '$("#divDadosAvalistas").css("display","block");';
		echo 'habilitaAvalista(true);';
		echo 'hideMsgAguardo();';
		echo 'bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);';*/
		
		// Esconde mensagem de aguardo
		echo 'hideMsgAguardo();';
		echo 'bloqueiaFundo(divRotina);';
		echo 'showConfirmacao("Deseja cadastrar a proposta de novo cart&atilde;o de cr&eacute;dito?","Confirma&ccedil;&atilde;o - Ayllos","cadastrarNovoCartao()","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
		

		// Mostra a mensagem de informa��o para verificar atualiza��o cadastral se for adm BB
		if ($idconfir == 1) {
			echo 'showError("inform","'.$dsmensag.'","Alerta - Ayllos","bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false)");';		
		} 	
	}
	
?>