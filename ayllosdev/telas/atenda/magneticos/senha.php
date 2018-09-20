<?php 

	//************************************************************************//
	//*** Fonte: senha.php                                                 ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2008                 Ultima Alteração: 05/01/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao para alterar Senha do Cartão Magnético ***//
	//***                                                                  ***//	 
	//*** Alterações: 15/07/2009 - Passar para próximo campo com ENTER     ***//
	//***                        - Padronização de botões (Guilherme).     ***//	
	//***																   ***//
	//*** 	          13/07/2011 - Alterado para layout padrão 			   ***//
	//***    						(Rogerius - DB1). 					   ***//	
	//***																   ***//
	//***			  22/12/2011 - Ajuste para inclusão das opções   	   ***//
	//***						   Numérica, Solicitar Letras (Adriano).   ***//
	//***																   ***//
	//***			  05/01/2012 - Ajuste para alterar senha do cartao     ***//
	//***						   ao solicitar entrega (Adriano).   	   ***//
	//***																   ***//
	//***			  15/10/2015 - Incluido width na function 			   ***//
	//***						   voltarDivPrincipal (Jean Michel)        ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || 
	    !isset($_POST["nrcartao"]) ||
		!isset($_POST["operacao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];	
	$operacao = $_POST["operacao"];
	
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}	
	
	if  ($operacao == "E"){
		$tpoperac = 2;
	}else {$tpoperac = 1;}
	
		
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosCartao  = "";
	$xmlDadosCartao .= "<Root>";
	$xmlDadosCartao .= "	<Cabecalho>";
	$xmlDadosCartao .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlDadosCartao .= "		<Proc>verifica-senha-atual</Proc>";
	$xmlDadosCartao .= "	</Cabecalho>";
	$xmlDadosCartao .= "	<Dados>";
	$xmlDadosCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosCartao .= "		<idseqttl>1</idseqttl>";
	$xmlDadosCartao .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlDadosCartao .= "		<tpoperac>".$tpoperac."</tpoperac>";
	$xmlDadosCartao .= "	</Dados>";
	$xmlDadosCartao .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosCartao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosCartao = getObjectXML($xmlResult);
	
		
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$flgsenat = $xmlObjDadosCartao->roottag->tags[0]->attributes["FLGSENAT"];
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));voltarDivPrincipal(\'185\');");';
		echo '</script>';
		exit();
	}	

	
		
?>



<form action="" method="post" name="frmSenhaCartaoMagnetico" id="frmSenhaCartaoMagnetico" class="formulario">
	
	<fieldset>
	<legend>Senha</legend>

	<br />
	
	<?php if (strtolower($flgsenat) == "yes") { ?>

		<label for="nrsenatu">Senha Atual:</label>
		<input name="nrsenatu" type="password" id="nrsenatu" onkeypress="return enterTab(this,event);" />
	<?php } else { ?>
		<input name="nrsenatu" type="hidden" id="nrsenatu" value="20000">
	<?php } ?>
	
	<br />
	
	<label for="nrsencar">Nova Senha:</label>
	<input name="nrsencar" type="password" id="nrsencar" onkeypress="return enterTab(this,event);" />
	
	<br />
	
	<label for="nrsencon">Confirma Senha:</label>
	<input name="nrsencon" type="password" id="nrsencon" />
	
	<br style="clear:both"/><br />

	</fieldset>
	
	<div id="divBotoes">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="<? if($operacao == 'E'){ echo "voltarDivPrincipal('185',490);return false;";} else{echo "acessaOpcao();return false;";}?>">
		
		<? if($operacao == 'E'){ ?>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="<?= "validaSenhaCartaoMagnetico(); return false;" ?>">
		<? } else{ ?>
			<input type="image" id="btnAlterar" name="btnAlterar" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" onClick="<?= "validarAlteracaoSenhaCartao('');return false;" ?>">
		<? } ?>
		
	</div>
</form>


<script type="text/javascript">
// Formata layout
formataSenha();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>