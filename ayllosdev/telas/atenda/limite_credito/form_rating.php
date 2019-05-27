<?php
/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 03/12/2018;
 * Ultima alteração:
 * 
 * Alterações:
 */
?>

<fieldset id='fsRating'>
	<legend><? echo utf8ToHtml('Rating');?></legend>

	<label for="nrinfcad">Inf. cadastrais: </label>
	<input name="nrinfcad" id="nrinfcad" type="text" value="" />
	<img class='lupa' style='float: left; margin-top: 5px; margin-left: 5px; cursor: pointer;' id='buscaInfCad' src="<? echo $UrlImagens; ?>geral/ico_lupa.gif">
	<input name="dsinfcad" id="dsinfcad" type="text" value="" />
	<br /> <br />

	<label for="nrgarope">Garantia:</label>
	<input name="nrgarope" id="nrgarope" type="text" value="" class='campo'/>
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="dsgarope" id="dsgarope" type="text" value="" />
				
	<label for="nrliquid">Liquidez:</label>
	<input name="nrliquid" id="nrliquid" type="text" value="" class='campo'/>
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="dsliquid" id="dsliquid" type="text" value="" />
	<br />

	<label for="nrpatlvr">Patr. pessoal livre:</label>
	<input name="nrpatlvr" id="nrpatlvr" type="text" value="" class='campo'/>
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="dspatlvr" id="dspatlvr" type="text" value="" />
	<br />

	<div id="divRatingPJ">
		<label for="nrperger"><? echo utf8ToHtml('Percepção geral com relação a empresa:') ?></label>
		<input name="nrperger" id="nrperger" type="text" value=""  class='campo'/>
		<a id='lupanrperger'><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsperger" id="dsperger" type="text" value="" />
		<br />
	</div>

</fieldset>



<div id="divBotoes">
    <input type="image" id="btVoltarRating" src="<? echo $UrlImagens; ?>botoes/voltar.gif">
    <input type="image" id="btContinuarRating" src="<? echo $UrlImagens; ?>botoes/continuar.gif">
</div>

<script type='text/javascript'>
	$('#btVoltarRating').unbind('click').bind('click',function(){
		lcrShowHideDiv('divDadosObservacoes','divFormRating');
	});

	//metodoContinue
	$('#btContinuarRating').unbind('click').bind('click',function(){
		<?php
		if($operacao == 'I_PROT_CRED' || $cddopcao == "N"){
			if($operacao == "A_PROT_CRED"){
				$operacao = "A_COMITE_APROV";
			}
			?>
			validarDadosRating('<?php echo $glbvars["cdcooper"]; ?>','<?php echo $operacao ?>','<?php echo $inprodut ?>');
			<?php
		}else if($operacao == 'A_PROT_CRED'){
			?>
			eval("<?php echo $metodoContinue; ?>");
			<?php
		}
		?>
	});

	<?php
	if($cdOperacao == "C"){
		?>
		atualizarCamposRating(aux_rating);
		<?php
	}
	?>
</script>