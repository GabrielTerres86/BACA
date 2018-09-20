<?php 

	 /************************************************************************
	    Fonte: imprimir_extrato.php
	    Autor: Guilherme
	    Data : Fevereiro/2008                  Última Alteração: 09/07/2012

	    Objetivo  : Imprimir extrato da Conta/dv

	    Alterações: 02/10/2009 - Incluir opção para listagem de depósitos 
                            	 identificados (David).
								 
					02/09/2010 - Efetuar validação da impressão (David).	
 				    29/06/2011 - Alterado para layout padrão (Rogerius - DB1).
					09/07/2012 - Retirado campo "redirect" popup. (Jorge)
					
					31/05/2013 - Retirado o campo inisenta (Daniel).
	  ************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}
	
	$dtiniper = "01/".substr($glbvars["dtmvtolt"],3,2)."/".substr($glbvars["dtmvtolt"],6);
	$dtfimper = $glbvars["dtmvtolt"];
		
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>

<form action="<?php echo $UrlSite; ?>telas/atenda/dep_vista/gerar_extrato.php" name="frmExtrato" id="frmExtrato" class="formulario" method="post">

	<input type="hidden" name="nrdconta" id="nrdconta" value="">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	
	<br /><br /><br /><br />

	<label for="dtiniper">Per&iacute;odo:</label>
	<input type="text" name="dtiniper" id="dtiniper" value="<?php echo $dtiniper; ?>">
	
	<label for="dtfimper">&agrave;</label>
	<input type="text" name="dtfimper" id="dtfimper" value="<?php echo $dtfimper; ?>">

	<br />
<!--	
	<label for="inisenta">Tarifar?</label>
	<select name="inisenta" id="inisenta">
	<option value="0" selected>Sim</option>
	<option value="1">N&atilde;o</option>							
	</select>

	<br />
-->	
	<label for="inisenta">Listar?</label>
	<select name="inrelext" id="inrelext" >
	<option value="1" selected>Somente Extrato</option>
	<option value="2">Cheques</option>
	<option value="3">Dep&oacute;sitos Identificados</option>
	<option value="4">Todos</option>
	</select>
	
	<br style="clear:both" />

	<label for="botao"></label>
	<input type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" onClick="validarImpressao();return false;">

</form>


<script type="text/javascript">

//
controlaLayout('frmExtrato');

// Seta máscara aos campos dtiniper e dtfimper
$("#dtiniper,#dtfimper","#frmExtrato").setMask("DATE","","","divRotina");

$("#dtiniper","#frmExtrato").focus();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
