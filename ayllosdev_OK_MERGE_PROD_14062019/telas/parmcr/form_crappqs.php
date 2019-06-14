<? 
/*!
 * FONTE        : form_crappqs.php
 * CRIAÇÃO      : Jonata Cardoso - (RKAM)
 * DATA CRIAÇÃO : 12/12/2014 
 * OBJETIVO     : Tela para incluir/alterar dados das perguntas do questionario
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

<form id="frmPergunta" name="frmPergunta" class="formulario" onSubmit="return false;">

	<input name="dsregexi" id="dsregexi" type="hidden" value="<? echo $dsregexi; ?>" />

	<fieldset>
	
		<legend><? echo utf8ToHtml('Pergunta'); ?></legend>
		
		<label for="nrordper"><? echo utf8ToHtml('Sequência:'); ?></label>	
		<input name="nrordper" id="nrordper" type="text" value="<? echo $nrordper; ?>" />
		<br />
		
		<label for="dspergun"><? echo utf8ToHtml('Pergunta:'); ?></label>	
		<textarea name="dspergun" id="dspergun" type="text" maxlength="100"> <? echo $dspergun; ?> </textarea>
		
		<br />
				
		<label for="inobriga"><? echo utf8ToHtml('Obrigatória:');  ?></label>	
		<select id="inobriga" name="inobriga">
			<option value="1" <?php echo ($inobriga == '1') ? 'selected' : '' ?> >Sim</option>
			<option value="0" <?php echo ($inobriga == '0') ? 'selected' : '' ?> >N&atilde;o</option>
		</select>
		
		<br />
		
		<label for="intipres"><? echo utf8ToHtml('Resposta:');  ?></label>	
		<select id="intipres" name="intipres">
			<option value="1" <?php echo ($intipres == '1') ? 'selected' : '' ?> >&Uacute;nica escolha</option>
			<option value="2" <?php echo ($intipres == '2') ? 'selected' : '' ?> >Texto num&eacute;rico</option>
			<option value="3" <?php echo ($intipres == '3') ? 'selected' : '' ?> >Texto livre</option>
		</select>
		
		<br />
		
		<label for="nrregcal"><? echo utf8ToHtml('Regra de cálculo:');  ?></label>	
		<select id="nrregcal" name="nrregcal">
			<option value="0" <?php echo ($nrregcal == '0') ? 'selected' : '' ?> > </option>
			<option value="1" <?php echo ($nrregcal == '1') ? 'selected' : '' ?> >Perfil Cr&eacute;dito </option>
			<option value="2" <?php echo ($nrregcal == '2') ? 'selected' : '' ?> >Prazo</option>
			<option value="3" <?php echo ($nrregcal == '3') ? 'selected' : '' ?> >G&ecirc;nero</option>
		</select>
		
		<br/ >
		
		<label for="dsregexi-2"><? echo utf8ToHtml('Filtro Exibição:'); ?></label>	
		<input name="dsregexi-2" id="dsregexi-2" type="text" value="<? echo ($dsregexi == "") ? 'N&atilde;o' : 'Sim'; ?>" />
		
		<a class="lupa" style="cursor:pointer;" onclick="telaExistencia();" ><img src="<? echo $UrlImagens; ?>geral/ico_cadeado03"  width="20" height="20" border="0"></a>

		<br />
	
	</fieldset>	

</form>

<div id="divBotoesPerg" style="margin-bottom:8px">
    <a href="#" class="botao" id="btVoltar" onclick="fechaOpcao(); return false;">Voltar</a>  
    <a href="#" class="botao" id="btSalvar" onclick="manter_rotina('<? echo substr($operacao,0,10) . '2' ?>'); return false;">Continuar</a>   
</div>

<script> 
		
	$(document).ready(function(){
		highlightObjFocus($('#frmPergunta'));
		formataPergunta('<? echo substr($operacao,0,1); ?>');
	});

</script>