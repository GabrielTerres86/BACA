<?php
/*!
 * FONTE        : form_dados.php
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Julho / 2017
 * OBJETIVO     : Formlario manipulação de dados
 * --------------
 * ALTERAÇÕES   :  
 * --------------
 */ 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>

<form id="frmDados" name="frmDados" class="formulario">

	<fieldset id="fsetDados" name="fsetDados" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend><? echo utf8ToHtml('Dados') ?></legend>
		
		<label for="nmtitular"><? echo utf8ToHtml('Titular:') ?></label>
		<input id="nmtitular" maxlength="60" name="nmtitular" type="text" value="<? echo getByTagName($registro,'nmtitular_dest') ?>" onBlur="retirarAcentuacaoTedCapital(this.value);" />
		
		<label for="nrcpfcgc"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
		<input id="nrcpfcgc" name="nrcpfcgc" type="text" value="<? echo getByTagName($registro,'nrcpfcgc_dest') ?>" />
				
		<br style="clear:both" />	
		
		<label for="cdbantrf"><? echo utf8ToHtml('Banco:') ?></label>
		<input id="cdbantrf" name="cdbantrf" type="text" value="<? echo getByTagName($registro,'cdbanco_dest') ?>" />	
		<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
		<input id="dsbantrf" name="dsbantrf" type="text" value="<? echo getByTagName($registro,'dsbantrf') ?>" />
		
		<br style="clear:both" />	
		
		<label for="cdagetrf"><? echo utf8ToHtml('Agencia:') ?></label>
		<input id="cdagetrf" name="cdagetrf" type="text" value="<? echo getByTagName($registro,'cdagenci_dest') ?>" />	
		<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
		<input id="dsagetrf" name="dsagetrf" type="text" value="<? echo getByTagName($registro,'dsagetrf') ?>" />
		
		<br style="clear:both" />
		
		<label for="nrctatrf"><? echo utf8ToHtml('Conta:') ?></label>
		<input id="nrctatrf" name="nrctatrf" type="text" value="<? echo getByTagName($registro,'nrconta_dest') ?>" />	
		<input id="nrdigtrf" name="nrdigtrf" type="text" value="<? echo getByTagName($registro,'nrdigito_dest') ?>" />
		
	</fieldset>	
	
	<fieldset id="fsetSituacao" name="fsetSituacao" style="padding:0px; margin:0px; padding-bottom:10px;">
	
		<legend><? echo utf8ToHtml('Situação') ?></legend>
		
		<label for="cdsitcta"><? echo utf8ToHtml('Situação:') ?></label>
		<input id="cdsitcta" name="cdsitcta" type="text" value="<? echo getByTagName($registro,'insit_autoriza') ?>" />	
	
	</fieldset>	
	
</form>


<div id="divBotoesDados" style='text-align:center; margin-bottom: 10px; margin-top: 10px;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina(divRotina);">Voltar</a>	
	<a href="#" class="botao" id="btExcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','manterContaDestinoTedCapital(\'E\');','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesDados\').focus();','sim.gif','nao.gif');return false;">Excluir</a>	
	<a href="#" class="botao" id="btAlterar" onClick="controlaBotoesFormDadosTedCapital('A');return false;">Alterar</a>	
	
	<?if(getByTagName($registro,'insit_autoriza') == 'CANCELADO'){?>
		<a href="#" class="botao" id="btReativar" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','manterContaDestinoTedCapital(\'X\');','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesDados\').focus();','sim.gif','nao.gif');return false;">Reativar Conta</a>	
	<?}?>
	
	<a href="#" class="botao" id="btIncluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','manterContaDestinoTedCapital(\'I\');','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesDados\').focus();','sim.gif','nao.gif');return false;">Incluir</a>	
			
</div>


<div id="divBotoesAlterar" style='text-align:center; margin-bottom: 10px; margin-top: 10px;display:none;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina(divRotina);">Voltar</a>	
	<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','manterContaDestinoTedCapital(\'A\');','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesDados\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
			
</div>

<script type="text/javascript">
	
	// Controla o layout da tela
	controlaLayoutContasTedCapital('<?echo $tpoperac;?>');
							
</script>
