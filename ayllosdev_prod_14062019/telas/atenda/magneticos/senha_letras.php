<?php 

	//************************************************************************//
	//*** Fonte: senha_letras.php                                          ***//
	//*** Autor: Guilherme                                                 ***//
	//*** Data : Janeiro/2012                 Ultima Alteração: 11/01/2013 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao para alterar Senha Letras do Cartão    ***//
	//***			  Magnético 										   ***//
	//***                                                                  ***//	 
	//*** Alterações: 11/01/2013 - Requisitar cadastro de Letras ao        ***//
	//***                          entregar cartao (Lucas).                ***//	 
	//***																   ***//
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
	    !isset($_POST["tpusucar"]) ||
		!isset($_POST["operacao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];	
	$operacao = $_POST["operacao"];
	$tpusucar = $_POST["tpusucar"];
	
	if ($operacao == "E"){
	
		echo '<script type="text/javascript">';
		echo '$("#btnAlterar").css("display","none");';
		echo '$("#btnConcluir").css("display","inline");';
		echo 'hideMsgAguardo();';
		echo '</script>';
		
		$tpoperac = "2";
		
	} else {
	
		$tpoperac = "1";
		
	}
	
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}	
	
		
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
	$xmlDadosCartao .= "		<idseqttl>".$tpusucar."</idseqttl>";
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
	
	$flgletca = $xmlObjDadosCartao->roottag->tags[0]->attributes["FLGLETCA"];
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));voltarDivPrincipal(\'185\');");';
		echo '</script>';
		exit();
	}
	
	if ($tpoperac == "2"){
	
		echo '<script type="text/javascript">';
	
		if ($flgletca == "yes") {
	
			$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
			
					
			if (!($idPrincipal === false)) {
				echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
			}	else {
				echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
			}			
		
			echo '</script>';
			exit();
			
		} else {
		
			echo 'showError("inform","Necess&aacute;rio cadastramento das Letras de Seguran&ccedil;a.","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';
			echo '</script>';
			
		}
			
	}
?>

<form action="" method="post" name="frmSenhaLetrasCartaoMagnetico" id="frmSenhaLetrasCartaoMagnetico" class="formulario">
	
	<fieldset>
	<legend>Letras de Seguran&ccedil;a</legend>

	<br />
	
	<label for="dssennov">Letras de Seguran&ccedil;a:</label>
	<input name="dssennov" type="password" id="dssennov" maxlength="3" onkeypress="return enterTab(this,event);" />
	
	<br />
	
	<label for="dssencon">Confirme suas letras:</label>
	<input name="dssencon" type="password" id="dssencon" maxlength="3" />
	
	<br style="clear:both"/><br />

	</fieldset>
	
	<div id="divBotoes">
	
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" style="display:inline;" onClick="<? if($operacao == 'E'){ echo "acessaOpcaoAba('0','0','@');return false;";} else{echo "acessaOpcao();return false;";}?>">
		<input type="image" id="btnConcluir" name="btnConcluir" style="display:none;" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="<? if($operacao == 'E'){ echo "validarAlteracaoSenhaLetrasCartao('E');return false;";} else{echo "validarAlteracaoSenhaLetrasCartao('');return false;";}?>">
		<input type="image" id="btnAlterar" name="btnAlterar" style="display:inline;" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" onClick="<? if($operacao == 'E'){ echo "validarAlteracaoSenhaLetrasCartao('E');return false;";} else{echo "validarAlteracaoSenhaLetrasCartao('');return false;";}?>">
		
	</div>
	
		
</form>


<script type="text/javascript">
// Formata layout
formataSenhaLetras();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>