<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Alexandre Scola (DB1)
 * DATA CRIAÇÃO : Janeiro/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de identificação jurídica da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [24/03/2010] Rodolpho Telmo  (DB1): Adequação no novo padrão
 * 002: [20/12/2010] Gabriel Capoia  (DB1): Chamada função validaPermissao
 * 003: [03/08/2015] Gabriel        (RKAM): Reformulacao cadastral
 */
?>
<?	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
	switch( $operacao ) {
		case 'CA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		case ''  : $op = "@"; break;
		default  : $op = "@"; break;
	}
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	$nrdconta = $_POST["nrdconta"] == "" ? 0  : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ? 0  : $_POST["idseqttl"];
	$flgcadas = $_POST["flgcadas"] == "" ? "" : $_POST["flgcadas"];
		
	// exibirErro('error','ação.','Alerta - Aimaro','bloqueiaFundo(divRotina)');

    if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0053.p</Bo>";
	$xml .= "		<Proc>busca_dados</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	
	// Se não retornou erro, então pegar a mensagem de alerta do Progress na variável msgAlert, para ser utilizada posteriormente
	$msgAlert = trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']);		
			
	$identificacao = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
?>
<script type="text/javascript">
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script>
<?
	include("formulario_identificacao_juridica.php");
?>
<script type="text/javascript">
	var msgAlert = '<? echo $msgAlert; ?>';
	var operacao = '<? echo $operacao; ?>';
	controlaLayout(operacao);
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(operacao);');
	}
</script>
