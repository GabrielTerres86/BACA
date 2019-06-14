<?php 

	//************************************************************************//
	//*** Fonte: 2via_senha_solicitacao_carregar.php                       ***//
	//*** Autor: David                                                     ***//
	//*** Data : Novembro/2010                Última Alteração: 26/08/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção Solicitar para 2via de Senha da rotina ***//
	//***             de Cartões de Crédito da tela ATENDA                 ***//
	//***                                                                  ***//	 
	//*** Alterações: 06/07/2011 - Alterado para layout padrão             ***//
	//***						  (Gabriel Capoia - DB1)                   ***//
	//***                                                                  ***//
	//***             26/08/2015 - Remover o form da impressao. (James)    ***//	
	//***                                                                  ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"2")) <> "") {
		exibeErro($msgError);		
	}

	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisição
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
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
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
// Mostra o div da Tela com opções para 2via de cartão
$("#divOpcoesDaOpcao3").css("display","block");

// Esconde o div com opções de 2via
$("#divOpcoesDaOpcao2").css("display","none");

controlaLayout('frmSol2viaSenha');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>