<?php 

	//************************************************************************//
	//*** Fonte: saque.php                                                 ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 &Uacute;ltima Altera&ccedil;&atilde;o: 30/06/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao de Saque da rotina de Conta 					 ***//
	//****						Investimento da tela ATENDA  												 ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es: 06/10/2008 - Validar aplica&ccedil;&otilde;es bloqueadas (David).  ***//
	//***             				30/06/2011 - Alterado para layout      ***//
	//***						    padrão (Rogerius - DB1).			   ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
		exibeErro($msgError);		
	}	
			
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>
<div id="divSaqueContaInv">
	
	<form action="" name="frmContaInv" id="frmContaInv" method="post" class="formulario">
		
		<br /><br /><br /><br /><br />
		<label for="vlresgat">Valor do Saque:</label>
		<input type="text" name="vlresgat" id="vlresgat" />
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/ok.gif" onClick="confirmaSaque(1);return false;">
	
	</form>
	
</div>

<script type="text/javascript">

// Formata layout
controlaLayout('saque');

// Seta m&aacute;scara ao campo vlresgat
$("#vlresgat","#frmContaInv").setMask("DECIMAL","zzz.zzz.zz9,99","","");

layoutOpcao();
controlaFoco();
</script>