<? 
/*!
 * FONTE         : principal.php
 * CRIA��O       : Gabriel Capoia (DB1)
 * DATA CRIA��O  : 05/05/2010 
 * OBJETIVO      : Mostrar opcao Principal da rotina de Impress�es da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 * ALTERACOES   : 23/07/2013 - Inclus�o da op��o de Cart�o Assinatura (Jean Michel).
 *				  02/09/2015 - Projeto Reformulacao cadastral		  
 *						  	   (Tiago Castro - RKAM)
 * 
 */
 ?>
 
 <?
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");	
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	// Verifica permiss�es de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','fechaRotina(divRotina)');
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)');

	// Guardo os par�metos do POST em vari�veis	
	$nrdconta = $_POST["nrdconta"] == "" ?  0  : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ?  0  : $_POST["idseqttl"];
	$inpessoa = $_POST["inpessoa"] == "" ?  0  : $_POST["inpessoa"];
	
	// Verifica se o n�mero da conta e o titular s�o inteiros v�lidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
	
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0063.p</Bo>";
	$xml .= "		<Proc>busca_tprelatorio</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<dsdepart>".$glbvars["dsdepart"]."</dsdepart>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjImp = getObjectXML($xmlResult);
	
?>

<div id="divImpressoes">	
	<div id="completo">Completo</div>
	<div id="ficha_cadastral">Ficha Cadastral</div>
	<div id="abertura">Abertura</div>
	<div id="financeiro">Financeiro</div>
	<? if ($inpessoa == 1) { ?>
	<div id="declaracao_pep">Declara&ccedil;&atilde;o PEP</div>
	<? } ?>
	<div id="cartao_assinatura">Cart&atilde;o Assinatura</div>
	<div id="btVoltar" onClick="fechaRotina(divRotina);return false;">Cancelar</div>
	<input type="hidden" id="inpessoa" name="inpessoa" value="<?echo $inpessoa;?>" />
</div>

<script type="text/javascript">		
	
	var relatorios = new Object();
	
	<? for($i = 0; $i <= 7; $i++ ){ ?>
		
	 var relatorio = new Object();	 
		 relatorio['msg']  = '<?echo $xmlObjImp->roottag->tags[0]->tags[$i]->tags[1]->cdata;?>';
		 relatorio['flag'] = '<?echo $xmlObjImp->roottag->tags[0]->tags[$i]->tags[2]->cdata;?>';
		
		 relatorios['<?echo strtolower(str_replace(' ','_',trim($xmlObjImp->roottag->tags[0]->tags[$i]->tags[0]->cdata)));?>'] = relatorio;
		
	<?}?>
	var inpessoa = "<? echo $inpessoa; ?>";	
	
	controlaLayout(inpessoa);
</script>