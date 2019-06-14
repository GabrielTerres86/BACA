<?php
/*****************************************************************
  Fonte        : form_alteracao_cadastral.php
  Criação      : Adriano
  Data criação : Maio/2013
  Objetivo     : Mostra o form de alteração cadastrla da tela INSS
  --------------
	Alterações   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
  --------------
 ****************************************************************/ 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmAlteracaoCadastral" name="frmAlteracaoCadastral" class="formulario" style="display:none;">	
			
	<fieldset id="fsetAlteracaoCadastral" name="fsetAlteracaoCadastral" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend> Altera Cadastro </legend>
		
		<label for="nrcpfcgc">C.P.F.:</label>
		<input id="nrcpfcgc" name="nrcpfcgc" type="text" ></input>
		
		<br />
		
		<label for="dsendere">Endere&ccedil;o:</label>
		<input id="dsendere" name="dsendere" type="text" ></input>
		
		<label for="nrendere">N&uacute;mero:</label>
		<input id="nrendere" name="nrendere" type="text" ></input>
		
		<br />
		
		<label for="nmbairro">Bairro:</label>
		<input id="nmbairro" name="nmbairro" type="text"></input>
		
		<label for="nrcepend">CEP:</label>
		<input id="nrcepend" name="nrcepend" type="text" ></input>
		
		<br />
		
		<label for="nmcidade">Cidade:</label>
		<input id="nmcidade" name="nmcidade" type="text" ></input>
		
		<label for="cdufende">U.F.:</label>
		<input id="cdufende" name="cdufende" type="text" ></input>
		
		<br />		
		
		<label for="nrdddtfc">Telefone:</label>
		<input id="nrdddtfc" name="nrdddtfc" type="text" ></input>
		
		<label for="nrtelefo"></label>
		<input id="nrtelefo" name="nrtelefo" type="text" ></input>
				
		<br />
		
	</fieldset>		
	
</form>

<div id="divBotoesAlteracaoCadastral" style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;">
		
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('V5');">Voltar</a>
	<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','solicitaAlteracaoCadastral(\'<?echo $cddopcao;?>\');','$(\'#btVoltar\',\'#divBotoesAlteracaoCadastral\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');return false;">Concluir</a>
	
</div>