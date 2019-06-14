<?php 

	//************************************************************************//
	//*** Fonte: 2via_cartao.php                                           ***//
	//*** Autor: David                                                     ***//
	//*** Data : Setembro/2008                Última Alteração: 05/07/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção 2via de Cartão da rotina de Cartões de ***//
	//***             Crédito da tela ATENDA                               ***//
	//***                                                                  ***//	 
	//*** Alterações: 08/11/2010 - Adaptação Cartão PJ (David)             ***//
	//***                                                                  ***//
	//***             05/07/2011 - Alterado para layout padrão             ***//
	//**						  (Gabriel Capoia - DB1)                   ***//
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
			<legend style="margin-bottom: 5px"><? echo utf8ToHtml('Segunda Via de Cartão') ?></legend>
			
			<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv(1,1,4);return false;">
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/solicitar.gif" onClick="solicita2viaCartao();return false;">
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/entregar.gif"  onClick="entrega2viaCartao();return false;">
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/desfazer.gif" onClick="showConfirmacao('Deseja desfazer solicita&ccedil;&atilde;o de segunda via do cart&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','desfazSolicitacao2viaCartao()','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;">
			
		</fieldset>
	</form>
	
	<br />
</div>

<script type="text/javascript">
// Mostra o div da Tela com opções para 2via de cartão
$("#divOpcoesDaOpcao2").css("display","block");

// Esconde o div com opções de 2via
$("#divOpcoesDaOpcao1").css("display","none");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está atrás do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>