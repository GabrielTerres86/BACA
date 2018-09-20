<?php 

	//************************************************************************//
	//*** Fonte: imprimir_extrato.php                                      ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 Última Alteração: 09/07/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Imprimir extrato da Conta Investimento               ***//
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//***				30/06/2011 - Alterado para layout 	   			   ***//
	//***				padrão (Rogerius - DB1).			   			   ***//
	//***																   ***//
	//***				09/07/2012 - Retirado campo "redirect". (Jorge)    ***//
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
		
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
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

<form action="<?php echo $UrlSite; ?>telas/atenda/conta_investimento/gerar_extrato.php" name="frmContaInv" id="frmContaInv" class="formulario" method="post">

	<input type="hidden" name="nrdconta" id="nrdconta" value="">
	<input type="hidden" name="nrctainv" id="nrctainv" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<br /><br /><br /><br /><br />

	<label for="dtiniper">Per&iacute;odo:</label>
	<input type="text" name="dtiniper" id="dtiniper" />
	<label for="dtfimper">&agrave;</label>
	<input type="text" name="dtfimper" id="dtfimper" />
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" onClick="imprimirExtrato();return false;">
	
</form>

<script type="text/javascript">

// Formata Layout
controlaLayout('imprimir_extrato');

// Seta máscara aos campos dtiniper e dtfimper
$("#dtiniper,#dtfimper","#frmContaInv").setMask("DATE","","","divRotina");

layoutOpcao();
controlaFoco();
</script>