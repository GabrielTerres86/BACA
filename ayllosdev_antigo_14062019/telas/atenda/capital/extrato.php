<?php 

	//************************************************************************//
	//*** Fonte: extrato.php                                               ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 Ultima Alteracoes 05/04/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao Extrato da rotina de Capital da tela   ***//
	//***             ATENDA                                               ***//
	//***                                                                  ***//	 
	//*** Alteracoes 04/09/2009 - Incluir campos para informar periodo de  ***//
	//***                          consulta (David).                       ***//
	//***            05/04/2011 - Alterar para layout padrão - (André DB1) ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variaveis globais de controle, e biblioteca de funcoes	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"E")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o numero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtiniper = isset($_POST["dtiniper"]) && validaData($_POST["dtiniper"]) ? $_POST["dtiniper"] : "01/01/".substr($glbvars["dtmvtolt"],6,4);
	$dtfimper = isset($_POST["dtfimper"]) && validaData($_POST["dtfimper"]) ? $_POST["dtfimper"] : $glbvars["dtmvtolt"];
	
	// Verifica se o numero da conta e um inteiro valido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisicao
	$xmlGetExtrato  = "";
	$xmlGetExtrato .= "<Root>";
	$xmlGetExtrato .= "	<Cabecalho>";
	$xmlGetExtrato .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlGetExtrato .= "		<Proc>extrato_cotas</Proc>";
	$xmlGetExtrato .= "	</Cabecalho>";
	$xmlGetExtrato .= "	<Dados>";
	$xmlGetExtrato .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetExtrato .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetExtrato .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetExtrato .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetExtrato .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetExtrato .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetExtrato .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetExtrato .= "		<idseqttl>1</idseqttl>";
	$xmlGetExtrato .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetExtrato .= "		<dtiniper>".$dtiniper."</dtiniper>";
	$xmlGetExtrato .= "		<dtfimper>".$dtfimper."</dtfimper>";
	$xmlGetExtrato .= "	</Dados>";
	$xmlGetExtrato .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetExtrato);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjExtrato = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra critica
	if (strtoupper($xmlObjExtrato->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExtrato->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$aux_vlsldant = $xmlObjExtrato->roottag->tags[0]->attributes["VLSLDANT"];
	$extrato      = $xmlObjExtrato->roottag->tags[0]->tags;
	
	// Funçao para exibir erros na tela atravede javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>

<form action="" method="post" name="frmExtCapital" id="frmExtCapital" class="formulario">

	<label for="dtperiod"><? echo utf8ToHtml('Período:') ?></label>
	<input name="dtiniper" id="dtiniper" type="text" value="<?php echo $dtiniper; ?>" />
	
	<label for="dtperime"><? echo utf8ToHtml('à') ?></label>

	<input name="dtfimper" id="dtfimper" type="text" value="<?php echo $dtfimper; ?>" />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/pesquisar.gif" onClick="acessaOpcaoAba(<?php echo count($glbvars["opcoesTela"]); ?>,<?php echo array_search("E",$glbvars["opcoesTela"]); ?>,'E');return false;" />
	
</form>

<br />

<? include('tabela_extrato.php'); ?>


<script type="text/javascript">
// Seta máscara aos campos dtiniper e dtfimper
$("#dtiniper,#dtfimper","#frmExtCapital").setMask("DATE","","","divRotina");

$("#dtiniper","#frmExtCapital").unbind("blur");
$("#dtiniper","#frmExtCapital").bind("blur",function() {
	if ($(this).val() != "") {
		var newDate1 = new Date();
		var newDate2 = new Date();
			
		newDate1.setFullYear($(this).val().substr(6,4),($(this).val().substr(3,2) - 1),$(this).val().substr(0,2));
		newDate2.setFullYear(2005,0,1);
		
		if (newDate2 > newDate1) {
			$(this).val("");
			showError("error","Data inicial inv&aacute;lida. Deve ser maior ou igual a 01/01/2005.","Alerta - Aimaro","$('#dtiniper','#frmExtCapital').focus();blockBackground(parseInt($('#divRotina').css('z-index')))");
			return false;
		}	
	}
	
	return true;
});

// Aumenta tamanho do div onde o conteudo da opca sera visualizado
$("#divConteudoOpcao").css("height","175px");

controlaLayout('EXTRATO');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteudo que esta aas do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>