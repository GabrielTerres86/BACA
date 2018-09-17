<? 
/*!
 * FONTE        : form_observacoes.php
 * CRIAÇÃO      : Rodolpho Telmo(DB1)
 * DATA CRIAÇÃO : 29/04/2011 
 * OBJETIVO     : Formulário da rotina LIMITE DE CREDITO
 *
 * ALTERACOES   : 07/04/2015 - Consultas Automatizadas (Jonata-RKAM).
 *              : 05/12/2017 - Chamada para a tela GAROPC. Projeto 404 (Lombardi)
 *              : 18/12/2017 - P404 - Inclusão de Garantia de Cobertura das Operações de Crédito (Augusto / Marcos (Supero))
 */	
?>
	
<fieldset class="fsObservacoes">
	<legend><? echo utf8ToHtml('Observações') ?></legend>			

	<textarea name="dsobserv" id="dsobserv" rows="5"></textarea>
	
</fieldset>		

<div id="divBotoes">
	<input type="image" id="btVoltarObservacoes" src="<? echo $UrlImagens; ?>botoes/voltar.gif">
	<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="setDadosRating(nrgarope, nrinfcad, nrliquid, nrpatlvr);informarRating('divDadosObservacoes' , metodoContinue , metodoCancel, metodoSucesso );return false;">
</div>

<script>
  $("#btVoltarObservacoes").unbind("click").bind("click",function() {    
    if (normalizaNumero($('#idcobert','#frmNovoLimite').val()) > 0) {
      $('#frmNovoLimite').css('width', 540);
      $('#divFormGAROPC').css('display','block');
      $('#divBotoesGAROPC').css('display', 'block');
      $('#divDadosObservacoes').css('display', 'none');
    } else {    
      lcrShowHideDiv('divDadosRenda','divDadosObservacoes');
    }    
    return false;
	}); 
</script>