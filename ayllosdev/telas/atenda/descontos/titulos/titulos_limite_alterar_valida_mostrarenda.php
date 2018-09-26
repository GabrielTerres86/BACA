<?php 

	/************************************************************************
	 Fonte: titulos_limite_alterar_valida_mostrarenda.php
	 Autor: Guilherme                                                 
	 Data : Dezembro/2008                Última Alteração: 07/06/2010
	                                                                  
	 Objetivo  : Validar dados do primeiro passo e mostrar formulario de 
				 rendas e observações
	                                                                  	 
	 Alterações: 07/06/2010 - Adaptação para RATING (David).
	************************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");

	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["diaratin"]) ||
		!isset($_POST["vllimite"]) ||
		!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"]) ||
		!isset($_POST["dtrating"]) ||
		!isset($_POST["cddlinha"]) ||
		!isset($_POST["vlrrisco"]) ||
		!isset($_POST["inconfir"]) || 
		!isset($_POST["inconfi2"]) ||
		!isset($_POST["inconfi4"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$diaratin = $_POST["diaratin"];
	$vllimite = $_POST["vllimite"];
	$dtrating = $_POST["dtrating"];
	$vlrrisco = $_POST["vlrrisco"];
	$cddlinha = $_POST["cddlinha"];
	$inconfir = $_POST["inconfir"];
	$inconfi2 = $_POST["inconfi2"];
	$inconfi4 = $_POST["inconfi4"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se a data do rating é válida
	if (!validaData($dtrating)) {
		exibeErro("Data de rating inv&aacute;lida.");
	}	

	// Monta o xml de requisição
	$xmlGetDadosLimAlterar  = "";
	$xmlGetDadosLimAlterar .= "<Root>";
	$xmlGetDadosLimAlterar .= "	<Cabecalho>";
	$xmlGetDadosLimAlterar .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlGetDadosLimAlterar .= "		<Proc>valida_proposta_dados</Proc>";
	$xmlGetDadosLimAlterar .= "	</Cabecalho>";
	$xmlGetDadosLimAlterar .= "	<Dados>";
	$xmlGetDadosLimAlterar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosLimAlterar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosLimAlterar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosLimAlterar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosLimAlterar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosLimAlterar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosLimAlterar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosLimAlterar .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosLimAlterar .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetDadosLimAlterar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDadosLimAlterar .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlGetDadosLimAlterar .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlGetDadosLimAlterar .= "		<diaratin>".$diaratin."</diaratin>";
	$xmlGetDadosLimAlterar .= "		<vllimite>".$vllimite."</vllimite>";
	$xmlGetDadosLimAlterar .= "		<dtrating>".$dtrating."</dtrating>";
	$xmlGetDadosLimAlterar .= "		<vlrrisco>".$vlrrisco."</vlrrisco>";
	$xmlGetDadosLimAlterar .= "		<cddopcao>A</cddopcao>";
	$xmlGetDadosLimAlterar .= "		<cddlinha>".$cddlinha."</cddlinha>";
	$xmlGetDadosLimAlterar .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlGetDadosLimAlterar .= "		<inconfi2>".$inconfi2."</inconfi2>";
	$xmlGetDadosLimAlterar .= "		<inconfi4>".$inconfi4."</inconfi4>";
	$xmlGetDadosLimAlterar .= "	</Dados>";
	$xmlGetDadosLimAlterar .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosLimAlterar);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosLimAlterar = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosLimAlterar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosLimAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 

	$qtMensagens = count($xmlObjDadosLimAlterar->roottag->tags[0]->tags);
	$mensagem    = $xmlObjDadosLimAlterar->roottag->tags[0]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir    = $xmlObjDadosLimAlterar->roottag->tags[0]->tags[$qtMensagens - 1]->tags[0]->cdata;

	?>
    inconfir = 01;
	inconfi2 = 11;
	<?php
	if ($inconfir == 2) {
	?>
			hideMsgAguardo();
			inconfir = "<?php echo $inconfir; ?>";
			showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","validaPrimeiroPassoAlteracao(inconfir,inconfi2)","metodoBlock()","sim.gif","nao.gif");
	<?php
	exit();
	} elseif ($inconfir == 12) {
	?>
			hideMsgAguardo();
			inconfi2 = "<?php echo $inconfir; ?>";
			showConfirmacao("<?php echo $mensagem; ?>","Confirma&ccedil;&atilde;o - Aimaro","validaPrimeiroPassoAlteracao(inconfir,inconfi2)","metodoBlock()","sim.gif","nao.gif");
	<?php
	exit();
	}
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>
// Mostrar <div> da renda
$("#divDscTit_Renda").css("display","block");

// Esconder <div> do primeiro passo
$("#divDscTit_Limite").css("display","none");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

<?php if ($inconfir == 72 || $inconfir == 19) { ?>
// Mostra informação e continua
showError("inform","<?php echo $mensagem; ?>","Alerta - Aimaro","metodoBlock()");
<?php } ?>
