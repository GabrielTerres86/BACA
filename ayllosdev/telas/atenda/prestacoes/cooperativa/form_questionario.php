<? 
 /*!
 * FONTE        : form_questionario.php
 * CRIAÇÃO      : Jonata-RKAM
 * DATA CRIAÇÃO : 14/01/2015
 * OBJETIVO     : Formulário do questionario para microcredito
 * 
 * ALTERACOES   : 08/06/2018 - P410 - Incluido tela de resumo da contratação + declaração isenção imóvel - Arins/Martini - Envolti 
 */	

 ?>

<form name="frmQuestionario" id="frmQuestionario" class="formulario condensado">	

	<fieldset style="height:420px;">
	
	<?  $qtpergun_atual = 0;
	    $qtpergun_exibi = 0;
		
		// Percorrer todas os titulos
		for ($i = 0; $i < count($xml_geral->titulos); $i++ ) {

		    $questionario = $xml_geral->titulos[$i];
			$flg_fieldset   = false;
	?>	
			<? // Percorrer todas as perguntas ?>
			<? for ($j = 0; $j < count($questionario->perguntas); $j++ ) { 
				   
				   $qtpergun_atual++;
				   $pergunta = $questionario->perguntas[$j]; 

				   // Desconsiderar as perguntas que ja foram exibidas
				   if ($qtpergun_atual <= $qtpergun) {
						continue;
				   }
				   
				   // Somente 10 perguntas por tela
				   if ( ($qtpergun_exibi % 10 == 0 && $qtpergun_exibi > 0) ) {
						break;	
				   }
				   
				   // So mostrar se tem resposta na opcao C	
				   if ($pergunta->resposta_dsrespos == '' && $cddopcao == 'C') {  
						$qtpergun++;
						continue;
				   }
				   
				   $qtpergun++;
				   $qtpergun_exibi++;
				   $nrseqper = $pergunta->nrseqper;
				   $intipres = $pergunta->intipres;
				   $dsregexi = $pergunta->dsregexi;
				   $inobriga = $pergunta->inobriga;
				   
				   // Somotrar o titulo do questionario 1 vez
				   if ($flg_fieldset == false) {
				   ?> 
					<fieldset>
					<legend> <?php echo utf8ToHtml ($questionario->titulo); ?> </legend>
					<br/>
				   <? $flg_fieldset = true; 
				   } ?>
				   
				
				<label for="pergunta" name="pergunta" id="<? echo $nrseqper; ?>"> <? echo $pergunta->pergunta; ?> </label>
		
				<? if ( strlen($pergunta->pergunta) > 40 ) {	
				     $estilo = 'margin-top:5px'; ?> 
					<br/>
				<? } else {
					$estilo = '';
				}  ?>	

				<? if ($intipres == 1) { // Multipla escolha ?>
					<select name="resposta" id="<? echo $nrseqper; ?>" dsregexi="<? echo $dsregexi; ?>" inobriga="<? echo $inobriga; ?>" style="<? echo $estilo; ?>" >
							
						<? if ($dsregexi != '' ) { // Se nao e' obrigatorio, criar opcao em branco ?>
							<option name="resposta" value=""> </option>
						<? } ?>
						
						<? // Percorrer todas as respostas ?>
						<? for ($q=0; $q < count($pergunta->opcoes->opcao); $q++) { 							
							$opcao = $pergunta->opcoes->opcao[$q];
							$nrseqres = $opcao->nrseqres;
							$dsrespos = $opcao->dsrespos;
							$selected = ($nrseqres == $pergunta->resposta_nrseqres) ? 'selected' : '';
						?>					
							<option name="resposta" <? echo $selected; ?> value="<? echo $nrseqres; ?>"> <? echo $dsrespos; ?> </option>
						<? } ?>
						
					</select>
				
				<? } else { 
					$name = ($intipres == 2) ? 'inteiro' : 'descricao';
				?>
					<input name="<? echo $name; ?>" id="<? echo $nrseqper; ?>" type="text" value="<? echo $pergunta->resposta_dsrespos; ?>" dsregexi="<? echo $dsregexi; ?>" inobriga="<? echo $inobriga; ?>" /> 
				<? } ?>
		
				<br/>
				<br/>
										
			<? } if ($flg_fieldset) { ?>
					</fieldset>
			<? } ?>		
	<? } ?>
			
	</fieldset>
	
	<input type="hidden" name="qtpergun" id="qtpergun" value ="<? echo $qtpergun; ?>">
  
</form>

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('C_COMITE_APROV'); return false;" />
	<?  
	// Verificar se tem mais perguntas, se tem chamar a mesma tela
	if ($qt_tot_perguntas > $qtpergun) { ?>
	 	<input type="image" id="btContinuar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif"  onClick="controlaOperacao('C_MICRO_PERG'); return false;" />
	<? } else { // Nao tem mais perguntas ?>
	    <input type="image" id="btContinuar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif"   onClick="controlaOperacao('C_DEMONSTRATIVO_EMPRESTIMO'); return false;" />
	<? } ?>
</div>

<script>
	$(document).ready(function() {
		 highlightObjFocus($('#frmQuestionario'));		
	});
</script>	