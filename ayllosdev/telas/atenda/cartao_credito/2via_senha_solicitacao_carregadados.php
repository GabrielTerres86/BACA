<?php 

	//************************************************************************//
	//*** Fonte: 2via_senha_solicitacao_carregar.php                       ***//
	//*** Autor: David                                                     ***//
	//*** Data : Novembro/2010                �ltima Altera��o: 26/08/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar op��o Solicitar para 2via de Senha da rotina ***//
	//***             de Cart�es de Cr�dito da tela ATENDA                 ***//
	//***                                                                  ***//	 
	//*** Altera��es: 06/07/2011 - Alterado para layout padr�o             ***//
	//***						  (Gabriel Capoia - DB1)                   ***//
	//***                                                                  ***//
	//***             26/08/2015 - Remover o form da impressao. (James)    ***//	
	//***                                                                  ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibeErro($msgError);		
	}

	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi��o
	$xmlGetRepresen  = "";
	$xmlGetRepresen .= "<Root>";
	$xmlGetRepresen .= "	<Cabecalho>";
	$xmlGetRepresen .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlGetRepresen .= "		<Proc>carrega_representante</Proc>";
	$xmlGetRepresen .= "	</Cabecalho>";
	$xmlGetRepresen .= "	<Dados>";
	$xmlGetRepresen .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xmlGetRepresen .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetRepresen .= "		<nrdconta>".$nrdconta."</nrdconta>";		
	$xmlGetRepresen .= "	</Dados>";
	$xmlGetRepresen .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetRepresen);

	// Cria objeto para classe de tratamento de XML
	$xmlObjRepresen = getObjectXML($xmlResult);
	
	$repsolic = explode(",",$xmlObjRepresen->roottag->tags[0]->attributes["REPRESEN"]);
	$cpfrepre = explode(",",$xmlObjRepresen->roottag->tags[0]->attributes["CPFREPRE"]);
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>
<form action="" class="formulario" name="frmSol2viaSenha" id="frmSol2viaSenha">
	<fieldset>
		<legend>Solicitar Segunda Via da Senha</legend>
		
		<label for="repsolic"><? echo utf8ToHtml('Representante Solicitante:') ?></label>
		<select name="repsolic" id="repsolic">
			<?php for ($i = 0; $i < count($repsolic); $i++) { ?>
			<option value="<?php echo $cpfrepre[$i]; ?>"<?php if ($i == 0) echo " selected"; ?>><?php echo $repsolic[$i]; ?></option>
			<?php } ?>
		</select>
	</fieldset>
</form>
<div class="divBotoes">
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(1,2,4);return false;" />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="efetuaSolicitacao2viaSenha();return false;" />
</div>

<script type="text/javascript">
// Mostra o div da Tela com op��es para 2via de cart�o
$("#divOpcoesDaOpcao3").css("display","block");

// Esconde o div com op��es de 2via
$("#divOpcoesDaOpcao2").css("display","none");

controlaLayout('frmSol2viaSenha');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� �tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>