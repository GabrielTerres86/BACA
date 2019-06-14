<?php
/*!
 * FONTE        : principal.php
 * CRIA��O      : Alexandre Scola (DB1)
 * DATA CRIA��O : Janeiro/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de filia��o da tela de CONTAS
 * --------------
 * ALTERA��ES   :
 * --------------
 * 001: [02/04/2010] Rodolpho Telmo  (DB1): Adequa��o ao novo padr�o
 * 002: [20/12/2010] Gabriel Capoia  (DB1): Adicionado chamada validaPermissao 
 * 003: [02/09/2015] Gabriel (RKAM)       : Reformulacao Cadastral.
 * 004: [13/07/2016] Carlos R. Correcao da forma de recuperacao da msgalert do XML de dados. SD 479874. 
 */	

	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;	
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];

	switch( $operacao ) {
		case 'CA': $op = "A"; break;
		case 'AC': $op = "@"; break;
		case ''  : $op = "@"; break;
		default  : $op = "@"; break;
	}
		
	// Verifica permiss�es de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op,false)) <> "") { 
		$metodo =  ($flgcadas == 'M') ? 'acessaOpcaoAbaDados(6,6,\'@\');' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Aimaro',$metodo,false);
	}
	
		// Carrega permiss�es do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

	$qtOpcoesTela = count($opcoesTela);

	// Carregas as op��es da Rotina de Bens
	$flgAcesso           = (in_array("@", $glbvars["opcoesTela"]));
	$flgAlterarFiliacao  = (in_array("A", $glbvars["opcoesTela"]));
	
	// Verifica se o n�mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	$nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"] == "" ? 0 : $_POST["idseqttl"];
	


	// Verifica se o n�mero da conta e o titular s�o inteiros v�lidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
	if ($idseqttl==0) exibirErro('error','Seq. Titular n&atilde;o foi informada.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
	
	// Monta o xml de requisi��o
	$xmlGetFiliacao  = "";
	$xmlGetFiliacao .= "<Root>";
	$xmlGetFiliacao .= "	<Cabecalho>";
	$xmlGetFiliacao .= "		<Bo>b1wgen0054.p</Bo>";
	$xmlGetFiliacao .= "		<Proc>busca_dados</Proc>";
	$xmlGetFiliacao .= "	</Cabecalho>";
	$xmlGetFiliacao .= "	<Dados>";
	$xmlGetFiliacao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetFiliacao .= "		<cdagenci>1</cdagenci>";
	$xmlGetFiliacao .= "		<nrdcaixa>1</nrdcaixa>";
	$xmlGetFiliacao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetFiliacao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetFiliacao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetFiliacao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetFiliacao .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlGetFiliacao .= "	</Dados>";
	$xmlGetFiliacao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetFiliacao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjFiliacao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjFiliacao->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjFiliacao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	
	$filiacao = $xmlObjFiliacao->roottag->tags[0]->tags[0]->tags;
	$msgAlert  = ( isset($xmlObjFiliacao->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjFiliacao->roottag->tags[0]->attributes['MSGALERT']) : '';
	
	//Verifico se conta � titular em outra conta. Se atributo vier preenchido, muda opera��o para 'SC' => Somente Consulta
	$msgConta = trim($xmlObjFiliacao->roottag->tags[0]->attributes['MSGCONTA']);
	if( $msgConta != '' ) $operacao = 'SC';
	
	include('formulario_filiacao.php');
	
?>
<script type='text/javascript'>
	
	var msgConta   = '<? echo $msgConta; ?>';
	var msgAlert   = '<? echo $msgAlert; ?>';
	var operacao   = '<? echo $operacao;  ?>';
	var flgAlterarFiliacao = '<? echo $flgAlterarFiliacao;   ?>';
	
	controlaLayoutFiliacao(operacao);
	if ( msgConta != '' ) { 
		showError('inform',msgConta,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFocoFiliacao(\''+operacao+'\');');
	}else if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFocoFiliacao(\''+operacao+'\');');
	}
	
</script>
