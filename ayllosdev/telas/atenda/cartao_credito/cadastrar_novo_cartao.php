<?
/*!
 * FONTE        : cadastrar_novo_cartao.php
 * CRIAÇÃO      : Guilherme (CECRED)
 * DATA CRIAÇÃO : Março/2007
 * OBJETIVO     : Cadastrar Novo Cartão de Crédito - rotina de Cartão de Crédito da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [04/11/2010] David           (CECRED) : Adaptação para Cartão PJ
 * 001: [06/05/2011] Rodolpho Telmo     (DB1) : Adaptação para Zoom Endereço e Avalista genérico
 * 002: [08/09/2011] Adriano		 (CECRED) : Incluido a chamada para a procedure alerta_fraude.
 * 003: [18/06/2012] Jorge Hamaguchi (CECRED) : Adiicionado confirmacao para gerar impressao.
 * 004: [10/07/2012] Guilherme Maba  (CECRED) : Incluído parâmetro nmextttl no xml da requisição.
 * 005: [16/07/2012] Jorge Hamaguchi (CECRED) : Ajustado eval de saída, quando ocorrer erro e saida normal.
 * 006: [12/04/2013] Adriano		 (CECRED) : Retirado a chamada da procedure alerta_fraude
 * 007: [02/05/2014] Jean Michel     (CECRED) : Incluido novos parametros para cartoes bancoob
 * 008: [03/07/2014] Lucas Lunelli   (CECRED) : Alteração para impedir impressão quando cartão BANCOOB.
 * 009: [24/09/2014] Renato - Supero (CECRED) : Adicionar parametro nmempres no cadastro de novos cartões
 * 010: [09/10/2015] Gabriel         (RKAM)   : Reformulacao cadastral.
 * 013: [13/10/2015] James           (CECRED) : Desenvolvimento do projeto 126.
         17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 

 */	  
 
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
	$params = array('nrdconta','inpessoa','dsgraupr','nrcpfcgc','nmtitcrd','nmempres','nrdoccrd','dtnasccr','dsadmcrd','cdadmcrd','dscartao',
                    'vlsalari','vlsalcon','vloutras','vlalugue','dddebito','vllimpro','flgimpnp','vllimdeb','nrrepinc',
                    'nrctaav1','nmdaval1','nrcpfav1','tpdocav1','dsdocav1','nmdcjav1','cpfcjav1','tdccjav1','doccjav1','ende1av1','ende2av1','nrcepav1','nmcidav1','cdufava1','nrfonav1','emailav1',
                    'nrctaav2','nmdaval2','nrcpfav2','tpdocav2','dsdocav2','nmdcjav2','cpfcjav2','tdccjav2','doccjav2','ende1av2','ende2av2','nrcepav2','nmcidav2','cdufava2','nrfonav2','emailav2',
                    'redirect','nrender1','complen1','nrcxaps1','nrender2','complen2','nrcxaps2','nmextttl', 'tpdpagto','tpenvcrd','dsrepres','dsrepinc');					

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {
			exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro,false);
		}
	}
	
	$nrdconta = $_POST['nrdconta'];
	$inpessoa = $_POST['inpessoa'];
	
	$dsgraupr = $_POST['dsgraupr'];
	$nrcpfcgc = $_POST['nrcpfcgc'];
	$nmtitcrd = $_POST['nmtitcrd'];
	$nmempres = $_POST['nmempres'];
	$nmextttl = $_POST['nmextttl'];
	$nrdoccrd = $_POST['nrdoccrd'];
	$dtnasccr = $_POST['dtnasccr'];
	$dsadmcrd = $_POST['dsadmcrd'];
	$cdadmcrd = $_POST['cdadmcrd'];
	$dscartao = $_POST['dscartao'];
	$vlsalari = $_POST['vlsalari'];
	$vlsalcon = $_POST['vlsalcon'];
	$vloutras = $_POST['vloutras'];
	$vlalugue = $_POST['vlalugue'];
	$vllimpro = $_POST['vllimpro'];
	$dddebito = $_POST['dddebito'];
	$flgimpnp = $_POST['flgimpnp'];
	$vllimdeb = $_POST['vllimdeb'];
	$nrrepinc = $_POST['nrrepinc'];
	$dsrepinc = $_POST['dsrepinc'];
	
	$nrctaav1 = $_POST['nrctaav1'];
	$nmdaval1 = $_POST['nmdaval1'];
	$nrcpfav1 = $_POST['nrcpfav1'];
	$tpdocav1 = $_POST['tpdocav1'];
	$dsdocav1 = $_POST['dsdocav1'];
	$nmdcjav1 = $_POST['nmdcjav1'];
	$cpfcjav1 = $_POST['cpfcjav1'];
	$tdccjav1 = $_POST['tdccjav1'];
	$doccjav1 = $_POST['doccjav1'];
	$ende1av1 = $_POST['ende1av1'];
	$ende2av1 = $_POST['ende2av1'];
	$nrcepav1 = $_POST['nrcepav1'];
	$nmcidav1 = $_POST['nmcidav1'];
	$cdufava1 = $_POST['cdufava1'];
	$nrfonav1 = $_POST['nrfonav1'];	
	$emailav1 = $_POST['emailav1'];	
	$nrender1 = $_POST['nrender1'];	
	$complen1 = $_POST['complen1'];	
	$nrcxaps1 = $_POST['nrcxaps1'];	

	$nrctaav2 = $_POST['nrctaav2'];
	$nmdaval2 = $_POST['nmdaval2'];
	$nrcpfav2 = $_POST['nrcpfav2'];
	$tpdocav2 = $_POST['tpdocav2'];
	$dsdocav2 = $_POST['dsdocav2'];
	$nmdcjav2 = $_POST['nmdcjav2'];
	$cpfcjav2 = $_POST['cpfcjav2'];
	$tdccjav2 = $_POST['tdccjav2'];
	$doccjav2 = $_POST['doccjav2'];
	$ende1av2 = $_POST['ende1av2'];
	$ende2av2 = $_POST['ende2av2'];
	$nrcepav2 = $_POST['nrcepav2'];
	$nmcidav2 = $_POST['nmcidav2'];
	$cdufava2 = $_POST['cdufava2'];
	$nrfonav2 = $_POST['nrfonav2'];
	$emailav2 = $_POST['emailav2'];
	$nrender2 = $_POST['nrender2'];	
	$complen2 = $_POST['complen2'];	
	$nrcxaps2 = $_POST['nrcxaps2'];	
	
	$tpdpagto = $_POST['tpdpagto'];	
	$tpenvcrd = $_POST['tpenvcrd'];
	$dsrepres = $_POST['dsrepres'];
	$flgdebit = $_POST['flgdebit'];
	
	$nrctrcrd = $_POST['nrctrcrd'];
	
	$executandoProdutos = $_POST['executandoProdutos'];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) exibirErro('error','Tipo de pessoa inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se a data de nascimento do titular do cartão é uma data válida
	if (!validaData($dtnasccr)) exibirErro('error','Data de nascimento inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se o código da admi é um inteiro válido
	if (!validaInteiro($cdadmcrd)) exibirErro('error','C&oacute;digo da Administradora inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se valor do salário do titular da conta é um decimal válido
	if (!validaDecimal($vlsalari)) exibirErro('error','Valor do Sal&aacute;rio do Titular inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se valor do salário do conjuge é um decimal válido
	if (!validaDecimal($vlsalcon)) exibirErro('error','Valor do Sal&aacute;rio do C&ocirc;njuge inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);

	// Verifica se valor de outras é um decimal válido
	if (!validaDecimal($vloutras)) exibirErro('error','Valor de Outras Rendas inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se valor do aluguel é um decimal válido
	if (!validaDecimal($vlalugue)) exibirErro('error','Valor do Aluguel inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);

	// Verifica se valor do limite proposto é um decimal válido
	if (!validaDecimal($vllimpro)) exibirErro('error','Valor do Limite Proposto inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Valida impressão de nota promissória
	if ($flgimpnp <> "yes" && $flgimpnp <> "no") exibirErro('error','Indicador de impress&atilde;o da nota promiss&oacute;ria inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);

	// Verifica se valor do limite de débito é um decimal válido
	if (!validaDecimal($vllimdeb) && $vllimdeb != 0 ) exibirErro('error','Valor do Limite de D&eacute;bito inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se CPF do representante é um inteiro válido
	if (!validaInteiro($nrrepinc)) exibirErro('error','CPF do representante inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);

	// Verifica se número da conta do 1° avalista é um inteiro válido
	if (!validaInteiro($nrctaav1)) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se número da conta do 2° avalista é um inteiro válido
	if (!validaInteiro($nrctaav2)) exibirErro('error','Conta/dv do 2o Avalista inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se CPF do 1° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav1)) exibirErro('error','CPF do 1o Avalista inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se CPF do Conjugê do 1° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav1)) exibirErro('error','CPF do C&ocirc;njuge do 1o Avalista inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se CPF do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav2)) exibirErro('error','CPF do 2o Avalista inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se CPF do Conjugê do 2° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav2)) exibirErro('error','CPF do C&ocirc;njuge do 2o Avalista inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se CEP do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcepav1)) exibirErro('error','CEP do 1o Avalista inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se CEP do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcepav2)) exibirErro('error','CEP do 2o Avalista inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica se o CPF/CNPJ &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfcgc)) exibirErro('error','N&uacute;mero de CPF/CNPJ inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica tipo de pagamento
	if (!validaInteiro($tpdpagto)) exibirErro('error','Forma de pagamento inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
	// Verifica tipo de envio
	if (!validaInteiro($tpenvcrd)) exibirErro('error','Tipo de Envio inv&aacute;lido.','Alerta - Aimaro',$funcaoAposErro,false);	
	
	// Verifica tipo de envio
	if (!validaInteiro($nrdoccrd)) exibirErro('error','Identidade inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);	
	

	// Se for uma alteração validamos se a senha já foi informada
	if (!empty($nrctrcrd)) {
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= " </Dados>";
		$xml .= "</Root>";
		$admresult = mensageria($xml, "ATENDA_CRD", "BUSCAR_ASSINATURA_REPRESENTANTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$objectResult = simplexml_load_string($admresult);

		$alguemAssinou = false;
		foreach($objectResult->Dados->representantes->representante as $representante){   
			if( ($representante->assinou == "S")){
				$alguemAssinou = true;
			}
		}
	}


	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>cadastra_novo_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<idseqttl>1</idseqttl>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<dsgraupr>".$dsgraupr."</dsgraupr>";
	$xmlSetCartao .= "		<nrcpfcpf>".$nrcpfcgc."</nrcpfcpf>";
	$xmlSetCartao .= "		<nmextttl>".$nmextttl."</nmextttl>";
	$xmlSetCartao .= "		<nmtitcrd>".$nmtitcrd."</nmtitcrd>";
	$xmlSetCartao .= "		<nmempres>".$nmempres."</nmempres>";
	$xmlSetCartao .= "		<nrdoccrd>".$nrdoccrd."</nrdoccrd>";
	$xmlSetCartao .= "		<dtnasccr>".$dtnasccr."</dtnasccr>";
	$xmlSetCartao .= "		<dsadmcrd>".$dsadmcrd."</dsadmcrd>";
	$xmlSetCartao .= "		<cdadmcrd>".$cdadmcrd."</cdadmcrd>";
	$xmlSetCartao .= "		<dscartao>".$dscartao."</dscartao>";
	$xmlSetCartao .= "		<vlsalari>".$vlsalari."</vlsalari>";
	$xmlSetCartao .= "		<vlsalcon>".$vlsalcon."</vlsalcon>";
	$xmlSetCartao .= "		<vloutras>".$vloutras."</vloutras>";
	$xmlSetCartao .= "		<vlalugue>".$vlalugue."</vlalugue>";
	$xmlSetCartao .= "		<dddebito>".$dddebito."</dddebito>";
	$xmlSetCartao .= "		<vllimpro>".$vllimpro."</vllimpro>";
	$xmlSetCartao .= "		<flgimpnp>".$flgimpnp."</flgimpnp>";
	$xmlSetCartao .= "		<vllimdeb>".$vllimdeb."</vllimdeb>";
	$xmlSetCartao .= "		<nrrepinc>".$nrrepinc."</nrrepinc>";	
	$xmlSetCartao .= "		<tpdpagto>".$tpdpagto."</tpdpagto>";
	$xmlSetCartao .= "		<tpenvcrd>".$tpenvcrd."</tpenvcrd>";
	$xmlSetCartao .= "		<nrctaav1>".$nrctaav1."</nrctaav1>";
	$xmlSetCartao .= "		<nmdaval1>".$nmdaval1."</nmdaval1>";
	$xmlSetCartao .= "		<nrcpfav1>".$nrcpfav1."</nrcpfav1>";
	$xmlSetCartao .= "		<tpdocav1>".$tpdocav1."</tpdocav1>";
	$xmlSetCartao .= "		<dsdocav1>".$dsdocav1."</dsdocav1>";
	$xmlSetCartao .= "		<nmdcjav1>".$nmdcjav1."</nmdcjav1>";
	$xmlSetCartao .= "		<cpfcjav1>".$cpfcjav1."</cpfcjav1>";
	$xmlSetCartao .= "		<tdccjav1>".$tdccjav1."</tdccjav1>";
	$xmlSetCartao .= "		<doccjav1>".$doccjav1."</doccjav1>";
	$xmlSetCartao .= "		<ende1av1>".$ende1av1."</ende1av1>";
	$xmlSetCartao .= "		<ende2av1>".$ende2av1."</ende2av1>";
	$xmlSetCartao .= "		<nrcepav1>".$nrcepav1."</nrcepav1>";
	$xmlSetCartao .= "		<nmcidav1>".$nmcidav1."</nmcidav1>";
	$xmlSetCartao .= "		<cdufava1>".$cdufava1."</cdufava1>";
	$xmlSetCartao .= "		<nrfonav1>".$nrfonav1."</nrfonav1>";
	$xmlSetCartao .= "		<emailav1>".$emailav1."</emailav1>";
	$xmlSetCartao .= "		<nrender1>".$nrender1."</nrender1>";
	$xmlSetCartao .= "		<complen1>".$complen1."</complen1>";
	$xmlSetCartao .= "		<nrcxaps1>".$nrcxaps1."</nrcxaps1>";	
	$xmlSetCartao .= "		<nrctaav2>".$nrctaav2."</nrctaav2>";
	$xmlSetCartao .= "		<nmdaval2>".$nmdaval2."</nmdaval2>";
	$xmlSetCartao .= "		<nrcpfav2>".$nrcpfav2."</nrcpfav2>";
	$xmlSetCartao .= "		<tpdocav2>".$tpdocav2."</tpdocav2>";
	$xmlSetCartao .= "		<dsdocav2>".$dsdocav2."</dsdocav2>";
	$xmlSetCartao .= "		<nmdcjav2>".$nmdcjav2."</nmdcjav2>";
	$xmlSetCartao .= "		<cpfcjav2>".$cpfcjav2."</cpfcjav2>";
	$xmlSetCartao .= "		<tdccjav2>".$tdccjav2."</tdccjav2>";
	$xmlSetCartao .= "		<doccjav2>".$doccjav2."</doccjav2>";
	$xmlSetCartao .= "		<ende1av2>".$ende1av2."</ende1av2>";
	$xmlSetCartao .= "		<ende2av2>".$ende2av2."</ende2av2>";
	$xmlSetCartao .= "		<nrcepav2>".$nrcepav2."</nrcepav2>";
	$xmlSetCartao .= "		<nmcidav2>".$nmcidav2."</nmcidav2>";
	$xmlSetCartao .= "		<cdufava2>".$cdufava2."</cdufava2>";
	$xmlSetCartao .= "		<nrfonav2>".$nrfonav2."</nrfonav2>";
	$xmlSetCartao .= "		<emailav2>".$emailav2."</emailav2>";
	$xmlSetCartao .= "		<nrender2>".$nrender2."</nrender2>";
	$xmlSetCartao .= "		<complen2>".$complen2."</complen2>";
	$xmlSetCartao .= "		<nrcxaps2>".$nrcxaps2."</nrcxaps2>";	
	$xmlSetCartao .= "		<dsrepres>".$dsrepres."</dsrepres>";	
	$xmlSetCartao .= "		<dsrepinc>".$dsrepinc."</dsrepinc>";	
	$xmlSetCartao .= "		<flgdebit>".$flgdebit."</flgdebit>";	
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	
	// Executa script para envio do XML
	//echo $xmlSetCartao."<br>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {		
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro,false);	
	} 	

	// Mostra se BO retornar mensagem de atualização de cadastro
	$idconfir = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$dsmensag = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
	
	// Número do novo contrato
	$nrctrcrd = ($nrctrcrd > 0) ? $nrctrcrd : $xmlObjCartao->roottag->tags[1]->tags[0]->tags[0]->cdata;

	
	/* Busca se a Cooper / PA esta ativa para usar o novo formato de comunicacao com o WS Bancoob.
	   Procedimento temporario ate que todas as cooperativas utilizem */
	$adxml = "<Root>";
	$adxml .= " <Dados>";
	$adxml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$adxml .= "   <cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$adxml .= " </Dados>";
	$adxml .= "</Root>";

	$result = mensageria($adxml, "ATENDA_CRD", "BUSCA_PARAMETRO_PA_CARTAO", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$oObj = simplexml_load_string($result);
	$bAtivoPiloto = false;
	if($oObj->Dados->ativo){
		$bAtivoPiloto = ($oObj->Dados->ativo == '1');
	}
	/* FIM procedimento temporario */
	
	
	
	$cecredCartoes = array(11,12,13,14,15,16,17,18);
	if(in_array(  intval($cdadmcrd),$cecredCartoes) && $bAtivoPiloto){

		echo "hideMsgAguardo();";
		if(isset($nrctrcrd) && isset($cdadmcrd)) {
			if ($alguemAssinou) {
				echo "enviarBancoob(".$nrctrcrd.")";
			} else {
			echo "solicitaSenha($nrctrcrd, $cdadmcrd);";
			}
		} else {
			exibirErro('error',utf8ToHtml("O Contrato não pôde ser gerado."),'Alerta - Aimaro',$funcaoAposErro,false);
		}
			
		echo "/* $xmlResult   */";
		return;
	}
	// Efetua a impressão PF ou PJ
	if ($inpessoa == "1") {
		$opcao = "3";
	} else {
		$opcao = "10";
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	if ($executandoProdutos == 'true') {
		echo "callafterCartaoCredito = \"encerraRotina();\";";
	} else {
		echo "callafterCartaoCredito = \"acessaOpcaoAba(".count($glbvars["opcoesTela"]).",0,\'".$glbvars["opcoesTela"][0]."\');\";";
	}
	
	$confmsg = "Deseja visualizar a impress&atilde;o?";
	$conftit = "Confirma&ccedil;&atilde;o - Aimaro";
	$confsim = "gerarImpressao(2,".$opcao.",".$cdadmcrd.",".$nrctrcrd.",0);";	
	$msgdconf = 'showConfirmacao("'.$confmsg.'","'.$conftit.'","'.$confsim.'",callafterCartaoCredito,"sim.gif","nao.gif");';	
	
	// Mostra a mensagem de informação para verificar atualização cadastral se for adm BB
	if ($idconfir == 1) {
		$evalresponse = "showError('inform','".$dsmensag."','Alerta - Aimaro','".$msgdconf."');";
	}else{
		$evalresponse = $msgdconf;
	}
	
	// BANCOOB
	if ($cdadmcrd >= 10 &&
		$cdadmcrd <= 80 && 
		$executandoProdutos != 'true'){
		$evalresponse = 'acessaOpcaoAba("'.count($glbvars["opcoesTela"]).'",0,"'.$glbvars["opcoesTela"][0].'");';	
	}
	
	echo $evalresponse;
	
?>
