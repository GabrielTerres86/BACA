<? 
/*!
 * FONTE        : principal.php
 * CRIA��O      : Gabriel Capoia (DB1)
 * DATA CRIA��O : Abril 2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Ativo/Passivo da tela de CONTAS
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1).
 *                05/08/2015 - Gabriel (RKAM) : Reformulacao cadastral.
 */	
?>
<?	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	
	switch( $operacao ) {
		case 'CA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		case ''  : $op = "@"; break;
		default  : $op = "@"; break;
	}
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "") exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
			
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	$nrdconta = $_POST["nrdconta"] == "" ? 0  : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ? 0  : $_POST["idseqttl"];
	$flgcadas = $_POST["flgcadas"] == "" ? '' : $_POST["flgcadas"];

	
	// Verifica se o n�mero da conta e o titular s�o inteiros v�lidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
	if ($idseqttl==0) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
	
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0066.p</Bo>";
	$xml .= "		<Proc>busca_dados</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
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
	$xmlObjAtivo = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjAtivo->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
	
	$ativoPassivo = $xmlObjAtivo->roottag->tags[0]->tags[0]->tags;
	
	// Se n�o retornou erro, ent�o pegar a mensagem de alerta do Progress na vari�vel msgAlert, para ser utilizada posteriormente
	$msgAlert = trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']);	
	
?>
<script type="text/javascript">
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script> 
<?
	include('formulario_ativo_passivo.php');
?>
<script type='text/javascript'>
	var msgAlert = '<? echo $msgAlert; ?>';
	var operacao = '<? echo $operacao;  ?>';
	controlaLayout(operacao);
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(operacao);');
	}else{
		controlaFoco(operacao);
	}
</script>
