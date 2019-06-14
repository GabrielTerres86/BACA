<? 
/*!
 * FONTE        : titulos_limite_alterar.php
 * CRIA��O      : Guilherme
 * DATA CRIA��O : Novembro/2008
 * OBJETIVO     : Carregar dados para alterar um limite existente	             		        				   
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: [08/06/2010] David           	(CECRED) : Adapta��o para RATING
 * 001: [06/05/2011] Rogerius Militao	(DB1)    : Adapta��o no formul�rio de avalista gen�rico
 * 002: [20/08/2015] Kelvin 			(CECRED) : Ajuste feito para n�o inserir caracters 
 *												   especiais na observa��o, conforme solicitado
 *	   										       no chamado 315453.
 * 003: [28/03/2018] Andre Avila 		(GFT) 	 : Adaptado para Propostas
 */
?>

<?php 
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	 	
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");


	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o n�mero do contrato � um inteiro v�lido
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
	// Se ocorrer um erro, mostra cr�tica
	if ($root->erro){
		exibirErro('error',$root->erro->registro->dscritic->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)');
		exit;
	}
	$flctgmot = $root->dados->flctgmot;

	// Monta o xml de requisi��o
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
	
	// Vari�vel que armazena c�digo da op��o para utiliza��o na include titulos_limite_formulario.php
	$cddopcao = "A";
	
	// Include para carregar formul�rio para gerenciamento de dados da proposta
	include("titulos_limite_formulario_propostas.php");
	
	// Fun��o para exibir erros na tela atrav�s de javascript
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
	habilitaAvalista(true, operacao);
	// Motor em contingencia
	var flctgmot = <?=$flctgmot?$flctgmot:0?>;
</script>