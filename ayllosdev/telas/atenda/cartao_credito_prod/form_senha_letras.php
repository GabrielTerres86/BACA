<?
/*
   FONTE        : form_senha_letras.php
   CRIAÇÃO      : James Prust Júnior
   DATA CRIAÇÃO : 12/08/2015
   OBJETIVO     : Formulario da tela de cadastro de senha letras
   ALTERACOES   : 
*/	
?> 
<form method="post" name="frmSenhaLetrasTAA" id="frmSenhaLetrasTAA" class="formulario">
	
	<fieldset>
	<legend>Letras de Seguran&ccedil;a</legend>

		<br />
	
		<label for="dssennov">Letras de Seguran&ccedil;a:</label>
		<input name="dssennov" type="password" id="dssennov" maxlength="3" onkeypress="return enterTab(this,event);" />
		
		<br />
		
		<label for="dssencon">Confirme suas letras:</label>
		<input name="dssencon" type="password" id="dssencon" maxlength="3" />

		<br style="clear:both"/><br />
		
	</fieldset>
</form>
<div id="divBotoes">

	<? if (($operacao == 'cadastrarSenhaLetrasTaa') || ($operacao == 'liberarAcessoTaa')){ ?>
	
		<a class="botao" onclick="opcaoTAA(); return false;" href="#">Voltar</a>
		<a class="botao" onClick="showConfirmacao('Deseja cadastrar letras de seguran&ccedil;a do TAA?','Confirma&ccedil;&atilde;o - Aimaro','alteraSenhaLetrasTAA(\'<?php echo $operacao ?>\');','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" href="#">Concluir</a>
		
	<? } else if ($operacao == 'entregarCartao'){ ?>

		<a class="botao" onclick="voltaDiv(0,1,4); return false;" href="#">Cancelar</a>
		<a class="botao" onClick="showConfirmacao('Deseja cadastrar letras de seguran&ccedil;a do TAA?','Confirma&ccedil;&atilde;o - Aimaro','alteraSenhaLetrasTAA(\'<?php echo $operacao ?>\');','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))','sim.gif','nao.gif');return false;" href="#">Continuar</a>

	<? } ?>	
	
</div>