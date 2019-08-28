<? 
/*!
 * FONTE        : titulos_limite_incluir.php
 * CRIAÇÃO      : Guilherme
 * DATA CRIAÇÃO : Novembro/2008
 * OBJETIVO     : Carregar dados para inclusão de um novo limite	             		        				   
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [10/06/2010] David           (CECRED) : Adaptação para RATING
 * 001: [04/05/2011] Rodolpho Telmo     (DB1) : Adaptação no formulário de avalista genérico
 * 002: [21/05/2015] Reinert   		 (CECRED) : Alterado para apresentar mensagem ao realizar inclusao
 *								          		de proposta de novo limite de desconto de titulo para
 *									      		menores nao emancipados.
 * 003: [26/06/2017] Jonata             (RKAM): Ajuste para rotina ser chamada através da tela ATENDA > Produtos (P364).
 * 004: [16/04/2018] Lombardi        (CECRED) : Incluida validacao se a adesao do produto é permitida
 *									            para o tipo de conta do coperado. PRJ366
 * 005: [20/05/2019] Luiz Otávio OM (AMCOM)   : Retirado Etapa Rating
 * 006: [29/05/2019] Luiz Otávio OM (AMCOM)   : Adicionado Etapa Rating para Cooperatova Ailos (3)
 * 007: [17/07/2019] Jefferson G      (Mouts) : Ajustes referente a reformulação da tela avalista - PRJ 438 - Sprint 16
 */

	define('cooperativaCetralAilosEtapaRating', 3);

	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');		
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');		
	isPostMethod();		
	
	require_once("../../../../includes/carrega_permissoes.php");

	setVarSession("opcoesTela",$opcoesTela);

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)');
	}	
	
	$tipo = (isset($_POST['tipo'])) ? $_POST['tipo'] : "CONTRATO";
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])||
		!isset($_POST["inconfir"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)');

	$nrdconta = $_POST["nrdconta"];
	$inconfir = $_POST["inconfir"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)');

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdprodut>".   37    ."</cdprodut>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro',$funcaoAposErro);
	}
	
	// Monta o xml de requisição
	$xmlGetDadosLimIncluir  = "";
	$xmlGetDadosLimIncluir .= "<Root>";
	$xmlGetDadosLimIncluir .= "	<Cabecalho>";
	$xmlGetDadosLimIncluir .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlGetDadosLimIncluir .= "		<Proc>busca_dados_limite_incluir</Proc>";
	$xmlGetDadosLimIncluir .= "	</Cabecalho>";
	$xmlGetDadosLimIncluir .= "	<Dados>";
	$xmlGetDadosLimIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosLimIncluir .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosLimIncluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosLimIncluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosLimIncluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDadosLimIncluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDadosLimIncluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosLimIncluir .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosLimIncluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosLimIncluir .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlGetDadosLimIncluir .= "	</Dados>";
	$xmlGetDadosLimIncluir .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosLimIncluir);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosLimIncluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosLimIncluir->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjDadosLimIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)');
	} 
	
	$qtMensagens = count($xmlObjDadosLimIncluir->roottag->tags[2]->tags);	
	$mensagem    = $xmlObjDadosLimIncluir->roottag->tags[2]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir    = $xmlObjDadosLimIncluir->roottag->tags[2]->tags[$qtMensagens - 1]->tags[0]->cdata;	

	if ($inconfir == 2) { ?>
		<script type="text/javascript">
		hideMsgAguardo();
		showConfirmacao("<? echo $mensagem ?>","Confirma&ccedil;&atilde;o - Aimaro","carregaDadosInclusaoLimiteDscTit(<? echo $inconfir ?>)","metodoBlock()","sim.gif","nao.gif");
		</script>
		<? exit();
	}
	
	$risco       = $xmlObjDadosLimIncluir->roottag->tags[0]->tags;
	$dados       = $xmlObjDadosLimIncluir->roottag->tags[1]->tags[0]->tags;
	$parametro 	 = $xmlObjDadosLimIncluir->roottag->tags[2]->tags[0]->tags;
	$tabvllimite = $parametro[1]->cdata;
	
	// Alimentar data rating
	for ($i = 0; $i < count($risco); $i++) { 								
		if ($risco[$i]->tags[4]->cdata <> 0) {
			?>
			<script type="text/javascript">
				dtrating = '<? echo subDiasNaData($glbvars["dtmvtolt"],$risco[$i]->tags[4]->cdata); ?>';
				diaratin = '<? echo $risco[$i]->tags[4]->cdata; ?>';
				vlrrisco = '<? echo $risco[$i]->tags[3]->cdata; ?>';
			</script>
			<?
		}
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

	/* 006 */
	if ($glbvars["cdcooper"] == cooperativaCetralAilosEtapaRating) {
	$flctgmot = $root->dados->flctgmot;
	$flctgest = $root->dados->flctgest;
	} else {
		$flctgmot = 0;
		$flctgest = 0;
	}
	/* 006 */

	// Variável que armazena código da opção para utilização na include titulos_limite_formulario.php
	$cddopcao = "I";
	
	// Include para carregar formulário para gerenciamento de dados do limite
	include("titulos_limite_formulario.php");
	
?>
<script type="text/javascript">
	habilitaAvalista(true, operacao);
	/*Motor em contingencia*/
	var flctgmot = <?=$flctgmot?$flctgmot:0?>;
</script>