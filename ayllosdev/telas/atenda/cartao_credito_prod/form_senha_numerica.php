<?
/*
   FONTE        : form_senha_numerica.php
   CRIAÇÃO      : James Prust Júnior
   DATA CRIAÇÃO : 12/08/2015
   OBJETIVO     : Formulario da tela de cadastro de senha numerica
   ALTERACOES   : 
*/	
?> 
<form name="frmSenhaNumericaTAA" id="frmSenhaNumericaTAA" class="formulario">
	
	<fieldset>
	<legend>Senha N&uacute;merica TAA</legend>
		
		<br />
		
		<label for="dssentaa">Nova Senha:</label>
		<input name="dssentaa" type="password" id="dssentaa" onkeypress="return enterTab(this,event);" />
		
		<br />
		
		<label for="dssencfm">Confirma Senha:</label>
		<input name="dssencfm" type="password" id="dssencfm" />
		
		<br style="clear:both"/><br />

	</fieldset>
</form>
<div id="divBotoes">
	<? if ($operacao == 'liberarAcessoTaa'){ ?>
		
		<a class="botao" onclick="opcaoTAA(); return false;" href="#">Voltar</a>
		<a class="botao" onClick="showConfirmacao('Deseja liberar o acesso ao sistema TAA?','Confirma&ccedil;&atilde;o - Aimaro','liberarCartaoCreditoTAA();','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" href="#">Concluir</a>
	
	<? }else if ($operacao == 'cadastrarSenhaNumericaTaa'){ ?>
	
		<a class="botao" onclick="opcaoTAA(); return false;" href="#">Voltar</a>
		<a class="botao" onClick="showConfirmacao('Deseja cadastrar senha num&eacute;rica do TAA?','Confirma&ccedil;&atilde;o - Aimaro','alteraSenhaNumericaTAA();','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" href="#">Concluir</a>
	
	<? }else if ($operacao == 'entregarCartao'){ ?>
			
		<a class="botao" onclick="voltaDiv(0,1,4); return false;" href="#">Cancelar</a>
		<a class="botao" onClick="showConfirmacao('Deseja cadastrar senha num&eacute;rica do TAA?','Confirma&ccedil;&atilde;o - Aimaro','liberarCartaoCreditoTAA(\'<?php echo $operacao ?>\');','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" href="#">Continuar</a>
		
	<? } ?>

	
</div>