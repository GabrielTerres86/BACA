<?php 

	//************************************************************************//
	//*** Fonte: 2via_senha.php                                            ***//
	//*** Autor: David                                                     ***//
	//*** Data : Setembro/2008                �ltima Altera��o: 06/07/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar op��o 2via de Senha da rotina de Cart�es de  ***//
	//***             Cr�dito da tela ATENDA                               ***//
	//***                                                                  ***//	 
	//*** Altera��es: 05/11/2010 - Adapta��o Cart�o PJ (David)             ***//
	//***                                                                  ***//	 
	//***             06/07/2011 - Alterado para layout padr�o             ***//
	//***						  (Gabriel Capoia - DB1)                   ***//
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
	if (!isset($_POST["inpessoa"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}

	$inpessoa = $_POST["inpessoa"];

	// Verifica se tipo de pessoa � um inteiro v�lido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lida.");
	}	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
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
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/desfazer.gif" onClick="showConfirmacao('Deseja desfazer solicita&ccedil;&atilde;o de segunda via da senha?','Confirma&ccedil;&atilde;o - Ayllos','desfazSolicitacao2viaSenha()','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" />
			
		</fieldset>
	</form>
</div>

<script type="text/javascript">
// Mostra o div da Tela com op��es para 2via de cart�o
$("#divOpcoesDaOpcao2").css("display","block");

// Esconde o div com op��es de 2via
$("#divOpcoesDaOpcao1").css("display","none");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� �tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>