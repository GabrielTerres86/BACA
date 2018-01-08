<? 
/*!
 * FONTE        : form_imunidade_tributaria.php
 * CRIA��O      : Lucas R (CECRED)
 * DATA CRIA��O : Julho/2013
 * OBJETIVO     : Formul�rio da rotina IMUNIDADE TRIBUTARIA da tela de CONTAS 
 * --------------
 * ALTERA��ES   :20/09/2013 - Corrigindo os campos cddentid e cdsitcad
							  para exibir os dados que vem da base e mostrar corretamente
							  na tela (Andr� Santos/ SUPERO)
				 
				 06/08/2015 - Reformulacao Cadastral (Gabriel-RKAM)
 * --------------
 */	
?>

<form name="frmImunidade" id="frmImunidade" class="formulario" >

	<input name="nrcpfcgc" id="nrcpfcgc" type="hidden" value="<? echo $nrcpfcgc ?>" />
	
	<fieldset>
		<legend>Opera��es dispon�veis</legend>		
		
        <label for="cddentid"><? echo utf8ToHtml(' Tipo de Entidade:') ?></label>
			<select id="cddentid" name="cddentid" >
                <option value="99" <? if ($cddentid == 99) { echo "selected";} ?> >&nbsp;</option>
				<option value="1" <? if ($cddentid == 1) { echo "selected";} ?> > 1 - Templo de qualquer culto</option>
				<option value="2" <? if ($cddentid == 2) { echo "selected";} ?> > 2 - Partido Pol�tico, funda��o de Partido Pol�tico</option>
				<option value="3" <? if ($cddentid == 3) { echo "selected";} ?> > 3 - Entidade Sindical de Trabalhadores</option>
				<option value="4" <? if ($cddentid == 4) { echo "selected";} ?> > 4 - Institui��o de Educa��o sem fins lucrativos</option>
				<option value="5" <? if ($cddentid == 5) { echo "selected";} ?> > 5 - Institui��o de Assistencia Social sem fins lucrativos</option>
			</select>	
		
		<br style="clear:both" />
		
        <label for="cdsitcad"> Situa��o</label>
			<select id="cdsitcad" name="cdsitcad">
                <option value="99" <? if ($cdsitcad == 99) { echo "selected";} ?> >&nbsp;</option>
				<option value="0" <? if ($cdsitcad == 0) { echo "selected";} ?> > 0 - Pendente</option>
				<option value="1" <? if ($cdsitcad == 1) { echo "selected";} ?> > 1 - Aprovado</option>
				<option value="2" <? if ($cdsitcad == 2) { echo "selected";} ?> > 2 - N�o Aprovado</option>
				<option value="3" <? if ($cdsitcad == 3) { echo "selected";} ?> > 3 - Cancelado</option>			
			</select>	
	</fieldset>			
	
</form>

<div id="divBotoes">	

	<? if ($flgcadas == 'M' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
	<? } else { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);"   />
	<? } ?>
	
	<input type="image" id="btAlterar"  src="<?php echo $UrlImagens; ?>botoes/alterar.gif"  onClick="confirmaRotina(); return false;" />	
	<input type="image" id="btImprimir" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" onClick="confirmaImpressao(); return false;" />	
	<!--<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar(); return false;" />-->
</div>
