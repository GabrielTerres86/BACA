<? 
/*!
 * FONTE        : titulos_limite_incluir.php
 * CRIA��O      : Guilherme
 * DATA CRIA��O : Novembro/2008
 * OBJETIVO     : Carregar dados para inclus�o de um novo limite	             		        				   
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: [10/06/2010] David           (CECRED) : Adapta��o para RATING
 * 001: [04/05/2011] Rodolpho Telmo     (DB1) : Adapta��o no formul�rio de avalista gen�rico
 * 002: [21/05/2015] Reinert   		 (CECRED) : Alterado para apresentar mensagem ao realizar inclusao
 *								          		de proposta de novo limite de desconto de titulo para
 *									      		menores nao emancipados.
 * 003: [26/06/2017] Jonata             (RKAM): Ajuste para rotina ser chamada atrav�s da tela ATENDA > Produtos (P364). 
 * 004: [16/04/2018] Lombardi        (CECRED) : Incluida validacao se a adesao do produto � permitida
 *									            para o tipo de conta do coperado. PRJ366
 */
?>

<? 
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');		
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');		
	isPostMethod();		
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)');
	}	
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])||
		!isset($_POST["inconfir"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)');

	$nrdconta = $_POST["nrdconta"];
	$inconfir = $_POST["inconfir"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)');

	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos',$funcaoAposErro);
	}
	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDadosLimIncluir->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjDadosLimIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)');
	} 
	
	$qtMensagens = count($xmlObjDadosLimIncluir->roottag->tags[2]->tags);	
	$mensagem    = $xmlObjDadosLimIncluir->roottag->tags[2]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir    = $xmlObjDadosLimIncluir->roottag->tags[2]->tags[$qtMensagens - 1]->tags[0]->cdata;	

	if ($inconfir == 2) { ?>
		<script type="text/javascript">
		hideMsgAguardo();
		showConfirmacao("<? echo $mensagem ?>","Confirma&ccedil;&atilde;o - Ayllos","carregaDadosInclusaoLimiteDscTit(<? echo $inconfir ?>)","metodoBlock()","sim.gif","nao.gif");
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
	
	// Vari�vel que armazena c�digo da op��o para utiliza��o na include titulos_limite_formulario.php
	$cddopcao = "I";
	
	// Include para carregar formul�rio para gerenciamento de dados do limite
	include("titulos_limite_formulario.php");
	
?>
<script type="text/javascript">
	habilitaAvalista(true);
</script>