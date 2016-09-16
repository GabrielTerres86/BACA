<? 
/*!
 * FONTE        : form_mensagem.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 06/02/2015 
 * OBJETIVO     : Tela para incluir/alterar as mensagens positivas  e de atencao 
 * --------------
 * ALTERAÇÕES   : 
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmMensagem" name="frmMensagem" class="formulario" onSubmit="return false;">

	<input name="nrseqqac" id="nrseqqac" type="hidden" value="<? echo $nrseqqac; ?>" />

	<fieldset>
	
		<legend><? echo utf8ToHtml('Mensagens'); ?></legend>
		
		<label for="inmensag"><? echo utf8ToHtml('Tipo de mensagem:'); ?></label>	
		<select id="inmensag" name="inmensag">
			<option value="1" <?php echo ($operacao == 'mensagem_positiv') ? 'selected' : '' ?> >Mensagem positiva</option>
			<? if ($operacao == 'mensagem_atencao') { ?>
				<option value="2" <? echo ($inmensag == 2 || $inmensag == '') ? 'selected' : '' ?>  >Mensagem de aten&ccedil;&atilde;o</option>
			<? } ?>
		</select>
		
		<br /><br />
		
		<label for="dsmensag"><? echo utf8ToHtml('Mensagem:');  ?></label>	
		<textarea name="dsmensag" id="dsmensag"> <? echo $dsmensag; ?></textarea>

		<br /><br />
		
		<label for="dsvariav"><? echo utf8ToHtml('Variáveis:');  ?></label>	
		<textarea name="dsvariav" id="dsvariav"> <? echo $xml_dados->nmparam1 . ' ' . $xml_dados->nmparam2 . ' ' . $xml_dados->nmparam3 ?> </textarea>
		
		<br/ ><br />
	
	</fieldset>	

</form>

<div id="divBotoesMensagens" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
    <a href="#" class="botao" id="btSalvar" onclick="salvaMensagem(); fechaOpcao(); return false;">Continuar</a>   
</div>

<script> 
		
	$(document).ready(function(){
		highlightObjFocus($('#frmMensagem'));
		formataMensagem();
	});

</script>