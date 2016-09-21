<? 
/*!
 * FONTE        : tab_tipo3.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 29/09/2011 
 * OBJETIVO     : Tabela de exibição do TIPO 3 do ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 *
 *				  19/03/2015 - Adicionado coluna de Valor na tabAplicacao. (Reinert)
 * --------------
 */	
?>

<form id="frmTipo" name="frmTipo" class="formulario">

	<fieldset>
	<legend><? echo utf8ToHtml('3 - Deposito Vinculado - Aplicações de Terceiros') ?></legend>

	<label for="nrctagar"><? echo utf8ToHtml('Conta Interveniente Garantidor:') ?></label>
	<input type="text" id="nrctagar" name="nrctagar" value="<? echo formataContaDV(getByTagName($dados,'nrctagar'))?>" />
	
	<label for="dtmvtolt"><? echo utf8ToHtml('Data Inclusão do Aditivo:') ?></label>
	<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($dados,'dtmvtolt')?>" />
	
	</fieldset>


	<fieldset>
	<legend><? echo utf8ToHtml('Tipo Aplicação') ?></legend>
	
	<div id="tabTipo">
		<div class="divRegistros">	
			<table>
				<thead>
					<tr>
						<th><? echo utf8ToHtml('Data'); ?></th>
						<th><? echo utf8ToHtml('Historico');  ?></th>
						<th><? echo utf8ToHtml('Valor');  ?></th>
						<th><? echo utf8ToHtml('Docmto');  ?></th>
						<th><? echo utf8ToHtml('Dt Vencto');  ?></th>
						<th><? echo utf8ToHtml('Saldo');  ?></th>
						<th><? echo utf8ToHtml('Saldo Resg');  ?></th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $aplicacao as $r ) { ?>
						<tr>
							<td><span><? echo getByTagName($r->tags,'dtmvtolt') ?></span>
									  <? echo getByTagName($r->tags,'dtmvtolt') ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'dshistor') ?></span>
									  <? echo getByTagName($r->tags,'dshistor') ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'vlaplica') ?></span>
									  <? echo formataMoeda(getByTagName($r->tags,'vlaplica')) ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'nrdocmto') ?></span>
									  <? echo getByTagName($r->tags,'nrdocmto') ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'dtvencto') ?></span>
									  <? echo getByTagName($r->tags,'dtvencto') ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'vlsldapl') ?></span>
									  <? echo formataMoeda(getByTagName($r->tags,'vlsldapl')) ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'sldresga') ?></span>
									  <? echo formataMoeda(getByTagName($r->tags,'sldresga')) ?>
							</td>
						</tr>
				<? } ?>	
				</tbody>
			</table>
		</div>	
	</div>
	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:10px">
	<?php if ( $cddopcao == 'E' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="manterRotina('VD'); return false;">Continuar</a>
	<?php } else { ?>
		<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="Gera_Impressao(); return false;">Imprimir</a>
	<?php } ?>
</div>

<script>
formataTipo3();
</script>