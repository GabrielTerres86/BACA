<?php 

	/********************************************************************************************
	 Fonte: resgatar_varias.php                                       
	 Autor: Fabr&iacute;cio                                                     
	 Data : Agosto/2011                                          Última alteração: 30/04/2014
	                                                                  
	 Objetivo  : Acessar operação Resgate da Rotina de Aplicações da     
	             tela ATENDA                                          
	                                                                  
	 Alterações: 01/12/2010 - Alterado a chamada da BO b1wgen0004.p  
	                          para a BO b1wgen0081.p (Adriano).
							  
							  
			     30/04/2014 - Ajuste referente ao projeto Captação:
							  - Layout dos botões							  
						      (Adriano). 
							  
	*******************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nraplica"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nraplica = $_POST["nraplica"];
	
	// Procura indíce da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	if ($idPrincipal === false) {
		$idPrincipal = 0;
	}
			
	?>
	var strHTML = "";
	strHTML += '<form action="" method="post" name="frmResgataValorParcial" id="frmResgataValorParcial" class="formulario" onSubmit="return false;">';
	strHTML += '	<fieldset>'; 
	strHTML += '	<legend>Resgate da Aplicação nº <?php echo $nraplica; ?></legend>';
	strHTML += '		<label for="vlresgat">Valor do Resgate:</label>';
	strHTML += '		<input name="vlresgat" type="text" id="vlresgat" autocomplete="no" value="0,00">';
	strHTML += '		<br />';
	strHTML += '	</fieldset>';
	strHTML += '	<div id="divBotoes">';
	strHTML += '		<a href="#" class="botao" id="btVoltar" onClick="voltarDivAutoManual();return false;">Voltar</a>';
	strHTML += '		<a href="#" class="botao" id="btProsseguir" onClick="setValorParcialResgate();return false;">Prosseguir</a>';			
	strHTML += '	</div>';
	strHTML += '</form>';
	
	$("#divResgateParcial").html(strHTML);
	formataResgateParcial();
	$("#vlresgat","#frmResgataValorParcial").setMask("DECIMAL","zzz.zzz.zz9,99","","");
	
	$("#divAutoManual").css("display","none");
	$("#divResgateParcial").css("display","block");
	
	<?php				
		
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
		
?>