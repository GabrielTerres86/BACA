<? 
 /*!
 * FONTE        : form_questionario.php
 * CRIAÇÃO      : Jonata-RKAM
 * DATA CRIAÇÃO : 06/01/2015
 * OBJETIVO     : Formulário do questionario para microcredito
 * --------------
 * ALTERACOES   : 
 * --------------
 * 001: [17/07/2015] Adicionado capitalize nos campos. (Kelvin)
 * 002: [16/10/2018] Atualizar encoding da string de titulo do formulario ( Bruno Luiz Katzjarowski - Mout's )
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
					<legend> <?php echo decodeString($questionario->titulo) ?> </legend>
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
							
						<option name="resposta" value=""> </option>
						
						<? // Percorrer todas as respostas ?>
						<? for ($q=0; $q < count($pergunta->opcoes->opcao); $q++) { 							
							$opcao = $pergunta->opcoes->opcao[$q];
							$nrseqres = $opcao->nrseqres;
							$dsrespos = $opcao->dsrespos;
							$selected = ( trim((string) $nrseqres) == trim((string) $pergunta->resposta_nrseqres)) ? 'selected="selected"' : '';
						?>					
							<option valor=<? echo $pergunta->resposta_nrseqres; ?> name="resposta" <? echo $selected; ?> value="<? echo $nrseqres; ?>"> <? echo $dsrespos; ?> </option>
						<? } ?>
						
					</select>
				
				<? } else { 
					$name = ($intipres == 2) ? 'inteiro' : 'descricao';
				?>
					<input name="<? echo $name; ?>" id="<? echo $nrseqper; ?>" type="text" value="<? echo $pergunta->resposta_dsrespos; ?>" dsregexi="<? echo $dsregexi; ?>" inobriga="<? echo $inobriga; ?>" style="text-transform: capitalize !important"/> 
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
	<? if ($cddopcao == 'A') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
	<? } 
	else if ($cddopcao == 'I') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
	<? } else { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('CF'); return false;">Voltar</a>
	<? } ?>
	
	<?  
	// Verificar se tem mais perguntas, se tem chamar a mesma tela
	if ($qt_tot_perguntas > $qtpergun) { 
		 if ($cddopcao == 'C') { // Exibe mais perguntas ?>
			<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('<? echo $cddopcao; ?>_MICRO_PERG'); return false;">Continuar</a>
		<? } else { // Carregar as demais perguntas  ?>
			<a href="#" class="botao" id="btSalvar" onClick="salvaQuestionario('<? echo $cddopcao; ?>_MICRO_PERG'); return false;">Continuar</a>
		<? } ?>
	<? } else { // Nao tem mais perguntas 
		 if ($cddopcao == 'C') { // Finaliza consulta ?>
			<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao(''); return false;">Continuar</a>
		<? } else { // Finaliza inclusao/alteracao  ?>
			<a href="#" class="botao" id="btSalvar" onClick="salvaQuestionario('<? echo $cddopcao; ?>'); return false;">Continuar</a>
		<? } ?>
	<? } ?>
</div>

<script>
	$(document).ready(function() {
		 highlightObjFocus($('#frmQuestionario'));
	});
</script>	
