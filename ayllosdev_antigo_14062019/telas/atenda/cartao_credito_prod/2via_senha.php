<?php 

	//************************************************************************//
	//*** Fonte: 2via_senha.php                                            ***//
	//*** Autor: David                                                     ***//
	//*** Data : Setembro/2008                Última Alteração: 06/07/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção 2via de Senha da rotina de Cartões de  ***//
	//***             Crédito da tela ATENDA                               ***//
	//***                                                                  ***//	 
	//*** Alterações: 05/11/2010 - Adaptação Cartão PJ (David)             ***//
	//***                                                                  ***//	 
	//***             06/07/2011 - Alterado para layout padrão             ***//
	//***						  (Gabriel Capoia - DB1)                   ***//
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
	if (!isset($_POST["inpessoa"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$inpessoa = $_POST["inpessoa"];

	// Verifica se tipo de pessoa é um inteiro válido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lida.");
	}	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<div id="divBotoes">
	<form class="formulario">
		<fieldset>
			<legend>Segunda Via de Senha</legend>
			
			<input type="image" id="btVoltar"src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(1,1,4);return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/solicitar.gif" onClick="<?php if ($inpessoa == "1") { echo "efetuaSolicitacao2viaSenha();"; } else { echo "solicitar2viaSenha();"; } ?>return false;" />
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/desfazer.gif" onClick="showConfirmacao('Deseja desfazer solicita&ccedil;&atilde;o de segunda via da senha?','Confirma&ccedil;&atilde;o - Aimaro','desfazSolicitacao2viaSenha()','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" />
			
		</fieldset>
	</form>
</div>

<script type="text/javascript">
// Mostra o div da Tela com opções para 2via de cartão
$("#divOpcoesDaOpcao2").css("display","block");

// Esconde o div com opções de 2via
$("#divOpcoesDaOpcao1").css("display","none");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>