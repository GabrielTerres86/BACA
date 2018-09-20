<?php 

	//************************************************************************//
	//*** Fonte: cancelamento.php                                          ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 &Uacute;ltima Altera&ccedil;&atilde;o: 30/06/2011 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao de Cancelamento da rotina de Conta  	 ***//
	//****						Investimento da tela ATENDA  												 ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es:                                                      ***//
	//***							30/06/2011 - Alterado para layout 	   ***//
	//***							padrão (Rogerius - DB1).			   ***//
	//***                                                                  ***//	 
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
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

<form action="" name="frmContaInv" id="frmContaInv" method="post" onSubmit="return false" class="formulario">

	<br /><br /><br /><br /><br />
	<label for="nrdocmto">N&uacute;mero do documento:</label>
	<input type="text" name="nrdocmto" id="nrdocmto" />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/ok.gif" onClick="cancelaSaque();return false;">
	
</form>
	
<script type="text/javascript">

// Formata layout
controlaLayout('cancelamento');

// Seta m&aacute;scara ao campo nrdcomto
$("#nrdocmto","#frmContaInv").setMask("INTEGER","zzz.zzz.zzz","","");

layoutOpcao();
controlaFoco();
</script>