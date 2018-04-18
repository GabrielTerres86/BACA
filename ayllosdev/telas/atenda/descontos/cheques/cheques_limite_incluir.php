<? 
/*!
 * FONTE        : cheques_limite_incluir.php
 * CRIA��O      : Guilherme
 * DATA CRIA��O : Mar�o/2009
 * OBJETIVO     : Carregar dados para inclus�o de um novo limite
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: [14/06/2010] David         CECRED) : Adapta��o para RATING
 * 001: [05/05/2011] Rodolpho Telmo  (DB1) : Adapta��o Zoom Endere�o e Avalista Gen�rico
 * 002: [30/11/2012] Adriano	  (CECRED) : Realizado chamada da procedure ver_capital.
 * 003: [12/05/2015] Reinert      (CECRED) : Alterado para apresentar mensagem ao realizar inclusao
 *									         de proposta de novo limite de desconto de cheque para
 *										     menores nao emancipados.	 
 * 004: [13/04/2018] Lombardi     (CECRED) : Incluida validacao se a adesao do produto � permitida
 *									         para o tipo de conta do coperado. PRJ366
 */
?>

<? 	
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();			
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro);
	}	
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"])||
		!isset($_POST["inconfir"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro);

	$nrdconta = $_POST["nrdconta"];
	$inconfir = $_POST["inconfir"];

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro);
	
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdprodut>".   36    ."</cdprodut>";
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
	$xmlGetDadosLimIncluir .= "		<Bo>b1wgen0009.p</Bo>";
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
		exibirErro('error',$xmlObjDadosLimIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$funcaoAposErro);
	} 
	
	$qtMensagens = count($xmlObjDadosLimIncluir->roottag->tags[2]->tags);	
	$mensagem    = $xmlObjDadosLimIncluir->roottag->tags[2]->tags[$qtMensagens - 1]->tags[1]->cdata;
	$inconfir    = $xmlObjDadosLimIncluir->roottag->tags[2]->tags[$qtMensagens - 1]->tags[0]->cdata;	

	if ($inconfir == 2) { ?>
		<script type="text/javascript">
		hideMsgAguardo();
		showConfirmacao("<? echo $mensagem ?>","Confirma&ccedil;&atilde;o - Ayllos","carregaDadosInclusaoLimiteDscChq(<? echo $inconfir ?>)","metodoBlock()","sim.gif","nao.gif");
		</script>
		<? exit();
	}
	
	// Monta o xml de requisi��o
	$xmlVerCapital  = "";
	$xmlVerCapital .= "<Root>";
	$xmlVerCapital .= "	<Cabecalho>";
	$xmlVerCapital .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlVerCapital .= "		<Proc>ver_capital</Proc>";
	$xmlVerCapital .= "	</Cabecalho>";
	$xmlVerCapital .= "	<Dados>";
	$xmlVerCapital .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlVerCapital .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlVerCapital .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlVerCapital .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlVerCapital .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlVerCapital .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlVerCapital .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlVerCapital .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlVerCapital .= "		<vllanmto>0</vllanmto>";	
	$xmlVerCapital .= "		<idseqttl>1</idseqttl>";
	$xmlVerCapital .= "	</Dados>";
	$xmlVerCapital .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResultVerCapital = getDataXML($xmlVerCapital);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjVerCapital = getObjectXML($xmlResultVerCapital);
	
	$erros = $xmlObjVerCapital->roottag->tags[0]->tags;
	
	// Se ocorrer um erro, mostra cr�tica
	if(count($erros) > 0){
		exibirErro('error',$xmlObjVerCapital->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$funcaoAposErro);
		
	} 
	
	
	$risco     = $xmlObjDadosLimIncluir->roottag->tags[0]->tags;
	$dados     = $xmlObjDadosLimIncluir->roottag->tags[1]->tags[0]->tags;
	$parametro = $xmlObjDadosLimIncluir->roottag->tags[3]->tags[0]->tags; // 2	
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
	
	// Vari�vel que armazena c�digo da op��o para utiliza��o na include cheques_limite_formulario.php
	$cddopcao = "I";
	
	// Include para carregar formul�rio para gerenciamento de dados do limite
	include("cheques_limite_formulario.php");	
?>
<script type="text/javascript">
	habilitaAvalista(true);
</script>