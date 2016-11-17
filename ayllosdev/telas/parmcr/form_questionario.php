<? 
 /*!
 * FONTE        : form_questionario.php
 * CRIAÇÃO      : Jonata-RKAM
 * DATA CRIAÇÃO : 13/01/2015
 * OBJETIVO     : Formulário do questionario para microcredito
 * 
 * ALTERACOES   :
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
	<a href="#" class="botao" id="btVoltar" onClick="fechaOpcao(); return false;">Voltar</a>
	<?  
	// Verificar se tem mais perguntas, se tem chamar a mesma tela
	if ($qt_tot_perguntas > $qtpergun) { ?>
		<a href="#" class="botao" id="btSalvar" onClick="rotina('C_perguntas_<? echo $inpessoa; ?>'); return false;">Continuar</a>
	<? } else { // Nao tem mais perguntas ?>
			<a href="#" class="botao" id="btSalvar" onClick="fechaOpcao(); return false;">Continuar</a>
	<? } ?>
</div>

<script>
	$(document).ready(function() {
		 highlightObjFocus($('#frmQuestionario'));		
	});
	
	formataQuestionario();
	
</script>	