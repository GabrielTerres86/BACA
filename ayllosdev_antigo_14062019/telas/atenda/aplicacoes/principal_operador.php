<?php 

	/*******************************************************************************
	 Fonte: principal_operador.php                                      
	 Autor:                                                             
	 Data : 08/05/2015   		                 Ultima Alteracao:          
	                                                                         
	 Objetivo  : Mostra div para digitar senha do operador que vai autorizar a 
	             operacao de resgate.
	                                                                          
	 Alteracoes:  
							  
	*******************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	

?>

<div id="divOperador">

	<form action="" method="post" name="frmSenhaOperad" id="frmSenhaOperad" class="formulario" onSubmit="return false;">
	
		<fieldset>
			<legend>Autorizar opera&ccedil;&atilde;o</legend>
			<label for="cdopera2">Operador:</label>
			<input name="cdopera2" type="text" id="cdopera2" autocomplete="no" value="" />
			<br/>
			<label for="cddsenh2">Senha:</label>
			<input name="cddsenh2" type="password" id="cddsenh2" autocomplete="no" value="" />						
		</fieldset>
				
	</form>

	<div id="divBotoes" style="margin-top:5px; margin-bottom :10px; text-align: center;">
		
		<a href="#" class="botao" id="btnVoltar" onClick="voltarDivResgate();">Voltar</a>	
		<a href="#" class="botao" id="btConcluir" onClick="cadastrarResgate(\'yes\');return false;" >Concluir</a>		

	</div>
	
</div>