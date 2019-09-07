<? 
/*!
 * FONTE        : titulos_limite_alterar.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Novembro/2008
 * OBJETIVO     : Carregar dados para alterar um limite existente	             		        				   
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [08/06/2010] David           	(CECRED) : Adaptação para RATING
 * 001: [06/05/2011] Rogerius Militao	(DB1)    : Adaptação no formulário de avalista genérico
 * 002: [20/08/2015] Kelvin 			(CECRED) : Ajuste feito para não inserir caracters 
 *												   especiais na observação, conforme solicitado
 *	   										       no chamado 315453.
 * 003: [28/03/2018] Andre Avila 		(GFT) 	 : Adaptado para Propostas
 * 004: [20/05/2019] Luiz Otávio O. M. (AMCOM)   : Retirado Etapa Rating quando estiver em contigência
 * 005: [28/05/2019] Luiz Otávio O. M. (AMCOM)   : Adicionado Etapa Rating para Cooperatova Ailos (3)
 */
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();
	 	
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");

	// ********************************************
	// AMCOM - Retira Etapa Rating exceto para Ailos (coop 3)

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <cdacesso>HABILITA_RATING_NOVO</cdacesso>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_PARRAT", "CONSULTA_PARAM_CRAPPRM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjPRM = getObjectXML($xmlResult);

	$habrat = 'N';
	if (strtoupper($xmlObjPRM->roottag->tags[0]->name) == "ERRO") {
		$habrat = 'N';
	} else {
		$habrat = $xmlObjPRM->roottag->tags[0]->tags;
		$habrat = getByTagName($habrat[0]->tags, 'PR_DSVLRPRM');
	}

	if ($glbvars["cdcooper"] == 3) {
		$habrat = 'N';
	}
	// ********************************************


	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","CONTINGENCIA_IBRATAN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getClassXML($xmlResult);
	$root = $xmlObj->roottag;
	// Se ocorrer um erro, mostra crítica
	if ($root->erro){
		exibirErro('error',$root->erro->registro->dscritic->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)');
		exit;
	}

	/* 004/005 */
	// Para Central Ailos deve manter rating antigo
	if ($habrat == 'N') {
		$flctgmot = $root->dados->flctgmot;
	} else {
		$flctgmot = '0';
	}
	/* 004/005 */

	// Monta o xml de requisição
	$xmlGetDados = "";
	$xmlGetDados .= "<Root>";
	$xmlGetDados .= "	<Cabecalho>";
	$xmlGetDados .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlGetDados .= "		<Proc>busca_dados_limite_altera</Proc>";
	$xmlGetDados .= "	</Cabecalho>";
	$xmlGetDados .= "	<Dados>";
	$xmlGetDados .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDados .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDados .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDados .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDados .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDados .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDados .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDados .= "		<idseqttl>1</idseqttl>";
	$xmlGetDados .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDados .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetDados .= "	</Dados>";
	$xmlGetDados .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDados);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));

	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$dados = $xmlObjDados->roottag->tags[0]->tags[0]->tags;
	
	$avais = $xmlObjDados->roottag->tags[1]->tags;
	
	$risco = $xmlObjDados->roottag->tags[2]->tags;
	
	$registros = $avais;
	
	$flgAval01 = count($avais) == 1 || count($avais) == 2 ? true : false;
	$flgAval02 = count($avais) == 2 ? true : false;
	

	// Alimentar data rating
	for ($i = 0; $i < count($risco); $i++) { 								
		if ($risco[$i]->tags[4]->cdata <> 0) {
			?>
			<script type="text/javascript">
			dtrating = '<?php echo subDiasNaData($glbvars["dtmvtolt"],$risco[$i]->tags[4]->cdata); ?>';
			diaratin = '<?php echo $risco[$i]->tags[4]->cdata; ?>';
			vlrrisco = '<?php echo $risco[$i]->tags[3]->cdata; ?>';
			</script>
			<?php
		}
	}
	
	// Variável que armazena código da opção para utilização na include titulos_limite_formulario.php
	$cddopcao = "A";
	
	// Include para carregar formulário para gerenciamento de dados da proposta
	include("titulos_limite_formulario_propostas.php");
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<script type="text/javascript">
	var operacao = '<? echo $cddopcao ?>';
	var arrayAvalistas = new Array();
	nrAvalistas     = 0;
	contAvalistas   = 1;
	<? 
	for ($i=0; $i<count($avais); $i++) {
	    if (getByTagName($avais[$i]->tags,'nrctaava') != 0 || getByTagName($avais[$i]->tags,'nrcpfcgc') != 0) {
	?>
			var arrayAvalista<? echo $i; ?> = new Object();
			arrayAvalista<? echo $i; ?>['nrctaava'] = '<? echo getByTagName($avais[$i]->tags,'nrctaava'); ?>';
			arrayAvalista<? echo $i; ?>['cdnacion'] = '<? echo getByTagName($avais[$i]->tags,'cdnacion'); ?>';
			arrayAvalista<? echo $i; ?>['dsnacion'] = '<? echo getByTagName($avais[$i]->tags,'dsnacion'); ?>';
			arrayAvalista<? echo $i; ?>['tpdocava'] = '<? echo getByTagName($avais[$i]->tags,'tpdocava'); ?>';
			arrayAvalista<? echo $i; ?>['nmconjug'] = '<? echo getByTagName($avais[$i]->tags,'nmconjug'); ?>';
			arrayAvalista<? echo $i; ?>['tpdoccjg'] = '<? echo getByTagName($avais[$i]->tags,'tpdoccjg'); ?>';
			arrayAvalista<? echo $i; ?>['dsendre1'] = '<? echo getByTagName($avais[$i]->tags,'dsendre1'); ?>';
			arrayAvalista<? echo $i; ?>['nrfonres'] = '<? echo getByTagName($avais[$i]->tags,'nrfonres'); ?>';
			arrayAvalista<? echo $i; ?>['nmcidade'] = '<? echo getByTagName($avais[$i]->tags,'nmcidade'); ?>';
			arrayAvalista<? echo $i; ?>['nrcepend'] = '<? echo getByTagName($avais[$i]->tags,'nrcepend'); ?>';
			arrayAvalista<? echo $i; ?>['nmdavali'] = '<? echo getByTagName($avais[$i]->tags,'nmdavali'); ?>';
			arrayAvalista<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($avais[$i]->tags,'nrcpfcgc'); ?>';
			arrayAvalista<? echo $i; ?>['nrdocava'] = '<? echo getByTagName($avais[$i]->tags,'nrdocava'); ?>';
			arrayAvalista<? echo $i; ?>['nrcpfcjg'] = '<? echo getByTagName($avais[$i]->tags,'nrcpfcjg'); ?>';
			arrayAvalista<? echo $i; ?>['nrdoccjg'] = '<? echo getByTagName($avais[$i]->tags,'nrdoccjg'); ?>';
			arrayAvalista<? echo $i; ?>['dsendre2'] = '<? echo getByTagName($avais[$i]->tags,'dsendre2'); ?>';
			arrayAvalista<? echo $i; ?>['dsdemail'] = '<? echo getByTagName($avais[$i]->tags,'dsdemail'); ?>';
			arrayAvalista<? echo $i; ?>['cdufresd'] = '<? echo getByTagName($avais[$i]->tags,'cdufresd'); ?>';
			arrayAvalista<? echo $i; ?>['vlrenmes'] = '<? echo getByTagName($avais[$i]->tags,'vlrenmes'); ?>';
			arrayAvalista<? echo $i; ?>['vledvmto'] = '<? echo getByTagName($avais[$i]->tags,'vledvmto'); ?>';
			arrayAvalista<? echo $i; ?>['nrendere'] = '<? echo getByTagName($avais[$i]->tags,'nrendere'); ?>';
			arrayAvalista<? echo $i; ?>['complend'] = '<? echo getByTagName($avais[$i]->tags,'complend'); ?>';
			arrayAvalista<? echo $i; ?>['nrcxapst'] = '<? echo getByTagName($avais[$i]->tags,'nrcxapst'); ?>';
			arrayAvalista<? echo $i; ?>['inpessoa'] = '<? echo getByTagName($avais[$i]->tags,'inpessoa'); ?>';
			arrayAvalista<? echo $i; ?>['dtnascto'] = '<? echo getByTagName($avais[$i]->tags,'dtnascto'); ?>';
			arrayAvalista<? echo $i; ?>['nrctacjg'] = '<? echo getByTagName($avais[$i]->tags,'nrctacjg'); ?>';
			arrayAvalista<? echo $i; ?>['vlrencjg'] = '<? echo getByTagName($avais[$i]->tags,'vlrencjg'); ?>';
			arrayAvalistas[<? echo $i; ?>] = arrayAvalista<? echo $i; ?>;
			nrAvalistas++;
	<?	
		}
	}
	?>
	habilitaAvalista(true, operacao);
	// Motor em contingencia
	var flctgmot = <?=$flctgmot?$flctgmot:0?>;
</script>