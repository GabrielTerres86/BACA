<?
/*!
 * FONTE        : validar_novo.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Marco/2008
 * OBJETIVO     : Validar Novo Cartão de Crédito - rotina de Cartão de Crédito da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [03/11/2010] David       (CECRED) : Adaptações para Cartão PJ
 * 001: [10/05/2011] Rodolpho    (DB1) : Adaptações para o formulário genérico de avalistas
 * 002: [01/04/2013] Adriano     (CECRED) : Incluido os parametros idorigem, nmdatela, cdoperad na chamada da procedure valida_nova_proposta
 * 003: [02/05/2014] Jean Michel (CECRED) : Incluido novos parametros para cartoes bancoob
 * 004: [23/10/2014] Vanessa     (CECRED) : Retirada da tela avalista conforme SD 204632
 * 005: [23/10/2014] Vanessa     (CECRED) : Obrigar o Preecnhimeto do campo forma de Pagamento SD 236434
 * 006: [09/10/2015] James		 (CECRED) : Desenvolvimento do projeto 126.
 * 007: [17/06/2016] Rafael M.   (RKAM)   : - M181 - Alterar o CDAGENCI para passar o CDPACTRA
 * 008: [29/06/2016] Kelvin      (CECRED) : Ajuste para que o campo "Plastico da Empresa" seja obrigatório. SD 476461
 * 009: [09/12/2016] Kelvin		 (CECRED) : Ajuste realizado conforme solicitado no chamado 574068. 										  
 * 010: [29/03/2018] Lombardi	 (CECRED) : Ajuste para chamar a rotina de senha do coordenador. PRJ366.
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
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro,false);
	}	
	
	// Verifica se os parâmetros necessários foram informados
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
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro,false);
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
	$flgdebit = $_POST['flgdebit'];
	$cdadmcrd = $_POST['cdadmcrd'];
	$nrctrcrd = isset($_POST['nrctrcrd']) ? $_POST['nrctrcrd'] : '';
	
	//Bloqueado solicitacao de novo cartao para cooperativa transulcred SD 574068
	if($glbvars["cdcooper"] == 17) exibirErro('error','Solicita&ccedil;&atilde;o n&atilde;o autorizada.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) exibirErro('error','Tipo de pessoa inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se valor do limite é um decimal válido
	if (!validaDecimal($vllimpro)) exibirErro('error','Valor do Limite de Cr&eacute;dito inv&aacute;lido ERRO.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se valor do limite é um decimal válido
	if (!validaDecimal($vllimdeb)) exibirErro('error','Valor do Limite de D&eacute;bito inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);

	// Verifica se valor do limite é um decimal válido
	if (!validaInteiro($nrcpfcgc)) exibirErro('error','N&uacute;mero de CPF inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se data de nascimento é uma data válida
	if (!validaData($dtnasccr)) exibirErro('error','Data de nascimento inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se a forma de pagamento foi selecionada
	if ($tpdpagto == 0) exibirErro('error','Forma de Pagamento inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se a empresa do plastico foi informada
	if (empty($nmempres) && $inpessoa == 2) exibirErro('error','Empresa do Plastico deve ser informada.','Alerta - Aimaro',$funcaoAposErro,false);
	
	if ($cdadmcrd > 17 && $cdadmcrd < 16) { // se não for debito
	$xml  = "";
    $xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdadmcrd>".$cdadmcrd."</cdadmcrd>";
	$xml .= "   <tplimcrd>0</tplimcrd>"; // Concessao
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResultLimite = mensageria($xml, "ATENDA_CRD", "BUSCA_CONFIG_LIM_CRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjectLimite = getObjectXML($xmlResultLimite);
	$xmlDadosLimite = $xmlObjectLimite->roottag->tags[0];

	if (strtoupper($xmlDadosLimite->tags[0]->name) == 'ERRO') {
	    $msgErro = $xmlDadosLimite->tags[0]->tags[0]->tags[4]->cdata;
	    if ($msgErro == "") {
	        $msgErro = $xmlDadosLimite->tags[0]->cdata;
	    }

			exibirErro('error',utf8ToHtml($msgErro),'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);

	}else{
	    $vllimmin = number_format(getByTagName($xmlDadosLimite->tags, "VR_VLLIMITE_MINIMO"), 2, '.', '');
		$vllimmax = number_format(getByTagName($xmlDadosLimite->tags, "VR_VLLIMITE_MAXIMO"), 2, '.', '');
	}
	
	if(str_replace(',','.',$vllimpro) > $vllimmax){
			exibirErro('error',utf8ToHtml('Não é possível solicitar um valor de limite acima do limite da categoria.'),'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
	}
	if(str_replace(',','.',$vllimpro) < $vllimmin){
			exibirErro('error',utf8ToHtml('Valor do limite solicitado abaixo do limite mínimo.'),'Alerta - Aimaro','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))',false);
		}
	}
	
    // Monta o xml de requisição
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
	$xmlSetCartao .= "		<flgdebit>".$flgdebit."</flgdebit>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	echo "/* \n $xmlSetCartao \n*/";
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

    // Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	$ignorarErro =  $xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata =="Situacao de Conta nao permite produtos de credito." && $cdadmcrd == '16';
	
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO" && !$ignorarErro ) {
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro,false);	
	} 	

	// Mostra se Bo retornar mensagem de atualização de cadastro
	$idconfir = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$dsmensag = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
	$solcoord = $xmlObjCartao->roottag->tags[0]->attributes["SOLCOORD"];
	
	$executar = "";
	
	if ($inpessoa <> "1") {
	
		$executar .= "habilitaAvalista(true);";
		$executar .= "hideMsgAguardo();";
		$executar .= "bloqueiaFundo(divRotina,\"nrctaav1\",\"frmNovoCartao\",false);";		
		
		// Mostra mensagem de confirmação para finalizar a operação
		if (empty($nrctrcrd)) {
			$executar .= "showConfirmacao(\"".(trim($dsmensag) <> "" ? $dsmensag."<br><br>" : "")."Deseja cadastrar a proposta de novo cart&atilde;o de cr&eacute;dito?\",\"Confirma&ccedil;&atilde;o - Aimaro\",\"cadastrarNovoCartao()\",\"bloqueiaFundo(divRotina)\",\"sim.gif\",\"nao.gif\");";
		} else {
			$executar .= "showConfirmacao(\"".(trim($dsmensag) <> "" ? $dsmensag."<br><br>" : "")."Deseja alterar a proposta do cart&atilde;o de cr&eacute;dito?\",\"Confirma&ccedil;&atilde;o - Aimaro\",\"cadastrarNovoCartao()\",\"bloqueiaFundo(divRotina)\",\"sim.gif\",\"nao.gif\");";
		}
		
	} else {
	   
		/*  RETIRADA DA TELA AVALISTA CONFORME SD 204632
		echo '$("#divDadosNovoCartao").css("display","none");';
		echo '$("#divDadosAvalistas").css("display","block");';
		echo 'habilitaAvalista(true);';
		echo 'hideMsgAguardo();';
		echo 'bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);';*/
		
		// Esconde mensagem de aguardo
		$executar .= "hideMsgAguardo();";
		$executar .= "bloqueiaFundo(divRotina);";
		if (empty($nrctrcrd)) {
			$executar .= "showConfirmacao(\"Deseja cadastrar a proposta de novo cart&atilde;o de cr&eacute;dito?\",\"Confirma&ccedil;&atilde;o - Aimaro\",\"cadastrarNovoCartao()\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
		} else {
			$executar .= "showConfirmacao(\"Deseja alterar a proposta do cart&atilde;o de cr&eacute;dito?\",\"Confirma&ccedil;&atilde;o - Aimaro\",\"cadastrarNovoCartao()\",\"blockBackground(parseInt($(\\\"#divRotina\\\").css(\\\"z-index\\\")))\",\"sim.gif\",\"nao.gif\");";
		}
		

		// Mostra a mensagem de informação para verificar atualização cadastral se for adm BB
		if ($idconfir == 1  && $dsmensag != 0) {
			$executar .= "showError(\"inform\",\"".$dsmensag."\",\"Alerta - Aimaro\",\"bloqueiaFundo(divRotina,\\\"nrctaav1\\\",\\\"frmNovoCartao\\\",false)\");";
		} 	
		} 	
	
	//echo 'alert(\''.$executar.'\');'; exit();
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[1]->name) == "ERRO") {
		
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		$executar = str_replace("\"","\\\"", str_replace("\\", "\\\\", $executar));
		
		exibirErro("error",$xmlObjCartao->roottag->tags[1]->tags[0]->tags[4]->cdata,"Alerta - Aimaro", ($solcoord == 1 ? "senhaCoordenador(\\\"".$executar."\\\");" : ""),false);
		
	} else {
		echo $executar;
	}
	
?>