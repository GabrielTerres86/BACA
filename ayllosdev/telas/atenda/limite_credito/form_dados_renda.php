<? 
/*!
 * FONTE        : form_dados_renda.php
 * CRIAÇÃO      : Rodolpho Telmo(DB1)
 * DATA CRIAÇÃO : 29/04/2011 
 * OBJETIVO     : Formulário da rotina LIMITE DE CREDITO
 *
 * ALTERACOES   : 06/04/2015 - Consultas automatizadas (Jonata-RKAM).
 */	
?>
	
<fieldset class="fsDadosRenda">
	<legend><? echo utf8ToHtml('Dados da Renda') ?></legend>			

	<label for="vlsalari"><? echo utf8ToHtml('Salário:')  ?></label>	
	<input name="vlsalari" id="vlsalari" type="text"  />
	
	<label for="vlsalcon"><? echo utf8ToHtml('Conjugê:') ?></label>
	<input name="vlsalcon" id="vlsalcon" type="text" >
	<br />
	
	<label for="vloutras"><? echo utf8ToHtml('Outras:') ?></label>	
	<input name="vloutras" id="vloutras" type="text" />
	
	<label for="vlalugue"><? echo utf8ToHtml('Aluguel:') ?></label>
	<input name="vlalugue" id="vlalugue" type="text" />
	<br />
	
</fieldset>		
<fieldset class="fsConjuge">
	<legend><? echo utf8ToHtml('Cônjuge') ?></legend>
	
	<label for="inconcje"><?php echo utf8ToHtml('Consultar Cônjuge:') ?></label>
	<input name="inconcje" id="inconcje_1" type="radio" class="radio" value="1" />
	<label for="flgYes" class="radio" >Sim</label>
	<input name="inconcje" id="inconcje_0" type="radio" class="radio" value="0" checked=true/>
	<label for="flgNo" class="radio"><? echo utf8ToHtml('Não') ?></label>

</fieldset>

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="lcrShowHideDiv('divDadosLimite','divDadosRenda');return false;">
	<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="trataObservacao('<? echo $cddopcao; ?>');lcrShowHideDiv('divDadosObservacoes','divDadosRenda');return false;">
</div>