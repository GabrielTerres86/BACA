<? 
/*!
 * FONTE        : form_observacoes.php
 * CRIAÇÃO      : Rodolpho Telmo(DB1)
 * DATA CRIAÇÃO : 29/04/2011 
 * OBJETIVO     : Formulário da rotina LIMITE DE CREDITO
 *
 * ALTERACOES   : 07/04/2015 - Consultas Automatizadas (Jonata-RKAM).
 */	
?>
	
<fieldset class="fsObservacoes">
	<legend><? echo utf8ToHtml('Observações') ?></legend>			

	<textarea name="dsobserv" id="dsobserv" rows="5"></textarea>
	
</fieldset>		

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="lcrShowHideDiv('divDadosRenda','divDadosObservacoes');return false;">
	<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="setDadosRating(nrgarope, nrinfcad, nrliquid, nrpatlvr);informarRating('divDadosObservacoes' , metodoContinue , metodoCancel, metodoSucesso );return false;">
</div>