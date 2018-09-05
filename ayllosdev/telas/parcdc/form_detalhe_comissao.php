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


<form id="frmDetalheComissao" name="frmDetalheComissao" class="formulario cabecalho" >
	<table width="100%">
		<tr>		
			<td> 	
				<label class="rotulo txtNormalBold" for="cdfaixav"><? echo utf8ToHtml('Faixa: ') ?></label>
				<input type="text" id="cdfaixav" name="cdfaixav" class="campoTelaSemBorda" value="" />
                <label for="idcomissao"><? echo utf8ToHtml(' Comissão: ') ?></label>
				<input type="text" id="idcomissao" class="campoTelaSemBorda" name="idcomissao" value="" />
				<input type="text" id="nmcomissao" name="nmcomissao" class="campoTelaSemBorda"  value="" />
			</td>
		</tr>
		<tr>
			<td>
				<fieldset>
					<legend>Valores Regra</legend>	
					<label for="vlinifvl"><? echo utf8ToHtml('Valor Inicial:') ?></label>
					<input type="text" id="vlinifvl" name="vlinifvl"  />	
					<br style="clear:both" />
					<label for="vlfinfvl"><? echo utf8ToHtml('Valor Final:') ?></label>
					<input type="text" id="vlfinfvl" name="vlfinfvl"  />	
                    <br style="clear:both" />
					<label for="vlcomiss"> <span id="lb_vlcomiss"> </span> <? echo utf8ToHtml('Comissão:') ?> </label>
					<input type="text" id="vlcomiss" name="vlcomiss"  />
					<br style="clear:both" />
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
	