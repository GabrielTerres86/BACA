<?
/*!
 * FONTE        : form_detalhe_comissao.php
 * CRIAÇÃO      : Diego Simas
 * DATA CRIAÇÃO : 30/04/2018 
 * OBJETIVO     : Tela de exibição detalhamento da regras da comissão
 * --------------
 * ALTERAÇÕES   :
 */		
?>

<script>

$(document).ready(function() {
	
	$('#dscomissao','#frmDetalheComissao').val(glbTabDscomissao);
	$('#cdcomissao','#frmDetalheComissao').val(glbTabCdcomissao);
	$('#cdfaixav','#frmDetalheComissao').desabilitaCampo();
	$('#cdcomissao','#frmDetalheComissao').desabilitaCampo();
	$('#dscomissao','#frmDetalheComissao').desabilitaCampo();
	
	switch (cddopdet) {
		case 'X':
		case 'A':
			var vlinifvl = ( glbTabVlinifvl ) ;
			vlinifvl = number_format(vlinifvl,2,',','');

			var vlcomissao = ( glbTabVlcomiss ) ;
			vlcomissao = number_format(vlcomissao,2,',','');        
				
			var vlfinfvl = ( glbTabVlfinfvl ) ;
			vlfinfvl = number_format(vlfinfvl,2,',','');						
			
			$('#vlinifvl','#frmDetalheComissao').val(vlinifvl);
			$('#vlfinfvl','#frmDetalheComissao').val(vlfinfvl);
			$('#vlcomissao','#frmDetalheComissao').val(vlcomissao);	
			$('#cdfaixav','#frmDetalheComissao').val(glbTabCdfaixav);
			break;	
		case 'I':			
        	$('#cdcomissao','#frmDetalheComissao').val(glbTabCdcomissao);
	    	$('#dscomissao','#frmDetalheComissao').val(glbTabDscomissao);
        	highlightObjFocus( $('#frmDetalheComissao') );
	    	$('#vlinifvl','#frmDetalheComissao').focus();
	   		bloqueiaFundo( $('#divRotina') );
			//buscaSequencialDetalhamento();
			break;
	}
	
	return false;	
});

</script>

<form id="frmDetalheComissao" name="frmDetalheComissao" class="formulario cabecalho" onSubmit="return false;" >
	<table width="100%">
		<tr>		
			<td> 	
				<label class="rotulo txtNormalBold" for="cdfaixav"><? echo utf8ToHtml('Faixa: ') ?></label>
				<input type="text" id="cdfaixav" name="cdfaixav" class="campoTelaSemBorda" value="" />
                <label for="cdcomissao"><? echo utf8ToHtml(' Comissão: ') ?></label>
				<input type="text" id="cdcomissao" class="campoTelaSemBorda" name="cdcomissao" value="" />
				<input type="text" id="dscomissao" name="dscomissao" class="campoTelaSemBorda"  value="" />
			</td>
		</tr>
		<tr>
			<td>
				<fieldset>
					<legend>Valores Regra</legend>	
					<label for="vlinifvl" class="rotulo txtNormalBold"><? echo utf8ToHtml('Valor Inicial:') ?></label>
					<input type="text" id="vlinifvl" name="vlinifvl"  />	
					<br style="clear:both" />
					<label for="vlfinfvl" class="rotulo txtNormalBold"><? echo utf8ToHtml('Valor Final:') ?></label>
					<input type="text" id="vlfinfvl" name="vlfinfvl"  />	
                    <br style="clear:both" />
					<label for="vlcomissao" class="rotulo txtNormalBold"><? echo utf8ToHtml('Valor Comissão:') ?></label>
					<input type="text" id="vlcomissao" name="vlcomissao"  />
				</fieldset>
			</td>
		</tr>		
	</table>
</form>

<div id="divTabDetalhamento" name="divTabDetalhamento" style="display:none">			
</div>	

<div id="divBotoesfrmDetalheComissao" style="margin-bottom: 5px; text-align:center;" >
	<br style="clear:both">
	<a href="#" class="botao" id="btVoltar"  	onClick="<? echo 'fechaRotina($(\'#divUsoGenerico\')); carregaDetalhamento();'; ?> return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar"  	onClick="<? echo 'fechaRotina($(\'#divRotina\')); carregaDetalhamento();'; ?> return false;">Concluir</a>
	<a href="#" class="botao" id="btContinuar"  onClick="manterDetalhamento(cddopdet);">Prosseguir</a>
</div>
	
	
<script>
	$("#btSalvar","#divBotoesfrmDetalheComissao").hide();
	highlightObjFocus( $('#frmDetalheComissao') );
	$('#vlinifvl','#frmDetalheComissao').focus();
	controlafrmDetalheComissao();		
</script>	
	