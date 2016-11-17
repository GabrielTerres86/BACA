<? 
/*!
 * FONTE        : form_dsregexi.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 12/12/2014 
 * OBJETIVO     : Tela para incluir/alterar as regras de existencias das perguntas
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

<form id="frmExistencia" name="frmExistencia" class="formulario" onSubmit="return false;" style="display:none;">

	<fieldset>
	
		<legend><? echo utf8ToHtml('Pergunta'); ?></legend>
		
		<br />
		
		<label for="tpdregis"><? echo utf8ToHtml('Tipo:'); ?></label>	
		<label for="dsfiltro"><? echo utf8ToHtml('Filtro:');  ?></label>
				
		<label for="linha"><? echo utf8ToHtml('');  ?></label>
		
		<select id="tpdregis" name="tpdregis" onchange="alteraFiltro();">
		    <option value="0" <? echo ($dsregexi == '') ? 'selected' : '' ?> ></option>
			<option value="1" <? echo (substr($dsregexi,0,7) == "#PESSOA") ? 'selected' : '' ?>>Vari&aacute;vel</option>
			<option value="2" <? echo (substr($dsregexi,0,8) == "pergunta") ? 'selected' : '' ?> >Pergunta</option>
		</select>
		
	
		<select id="dsfiltro" name="dsfiltro" onchange="alteraResposta()" >
			<? if (substr($dsregexi,0,7) == "#PESSOA") { ?>
				<option value="1">Pessoa</option>
			<? } ?>
		</select>

		<br />	
		
		<label for="dsrespos"><? echo utf8ToHtml('Respostas possíveis:');  ?></label>	
		
		<br />	
		
		<select id="dsrespos" name="dsrespos">
			<? if (substr($dsregexi,0,7) == "#PESSOA") { ?>
				<option value="1" <?php echo (substr($dsregexi,8,1) == "1") ? 'selected' : '' ?>>F&iacute;sica</option>
				<option value="2" <?php echo (substr($dsregexi,8,1) == "2") ? 'selected' : '' ?>>Jur&iacute;dica</option>
			<? } else { ?>
			
			
			<? } ?>
		</select>
		
		<br />
		
	</fieldset>	

</form>

<div id="divBotoesExis" style="margin-bottom:8px; display:none;">
    <a href="#" class="botao" id="btVoltar" onclick="telaExistencia(); return false;">Voltar</a>  
	<a href="#" class="botao" id="btVoltar" onclick="telaExistencia(); return false;">Continuar</a>  
</div>

<script> 
		
	$(document).ready(function(){
		highlightObjFocus($('#frmExistencia'));
		formataExistencia('<? echo substr($operacao,0,1); ?>');
		
		// Se for pergunta, buscar as perguntas e respostas
		<? if (substr($dsregexi,0,8) == 'pergunta') { ?>
			manter_rotina('C_crappqs_1');
			manter_rotina('C_craprqs_1');		
		<? } ?>
	});

</script>