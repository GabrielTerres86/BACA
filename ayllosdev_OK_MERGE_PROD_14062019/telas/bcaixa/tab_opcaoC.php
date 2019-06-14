<? 
/*!
 * FONTE        : tab_consulta.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 26/10/2011 
 * OBJETIVO     : Tabela que consulta BCAIXA
 * --------------
 * ALTERAÇÕES   : 27/01/2012 - Alteracoes para imprimir cabeçalho ou não (Tiago).
 *
 *				  19/04/2013 - Ajustes de layout nos botões (Lucas R).
 * --------------
 */ 
?>

<form id="frmOpcaoc" name="frmOpcaoc" class="formulario">

	<fieldset>
	<legend> Consulta </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Operador'); ?></th>
					<th><? echo utf8ToHtml('Abertura');  ?></th>
					<th><? echo utf8ToHtml('Fechamento');  ?></th>
					<th><? echo utf8ToHtml('Saldo Inicial');  ?></th>
					<th><? echo utf8ToHtml('Saldo Final');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $boletimcx as $r ) { 
								
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'cdopecxa'); ?> - RECID <? echo getByTagName($r->tags,'nrcrecid') ?></span>
								  <? echo getByTagName($r->tags,'cdopecxa'); ?>
								  <input type="hidden" id="nrcrecid" name="nrcrecid" value="<? echo getByTagName($r->tags,'nrcrecid') ?>" />								  
								  <input type="hidden" id="nrdlacre" name="nrdlacre" value="<? echo getByTagName($r->tags,'nrdlacre') ?>" />								  
								  
						</td>
						<td><span><? echo getByTagName($r->tags,'dshrabtb'); ?></span>
								  <? echo getByTagName($r->tags,'dshrabtb'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dshrfecb'); ?></span>
								  <? echo getByTagName($r->tags,'dshrfecb'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vldsdini'); ?></span>
								  <? echo formataMoeda(getByTagName($r->tags,'vldsdini')); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vldsdfin'); ?></span>
								  <? echo formataMoeda(getByTagName($r->tags,'vldsdfin')); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:11px">
	
	<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>	
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Boletim'); return false;" >Visualizar</a>
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Termo'); return false;" >Imprimir Abertura</a>
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Boletim'); return false;" >Imprimir Boletim</a> <br/> <br/>
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Fita_Caixa'); return false;" >Imprimir Fita</a>
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Depositos_Saques'); return false;" >Imprimir Dep/Saq</a>
</div>
