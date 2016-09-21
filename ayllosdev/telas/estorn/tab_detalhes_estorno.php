<?php 
/*
 * FONTE        : tab_lancamentos_pagamentos.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 16/09/2015
 * OBJETIVO     : Div que apresenta os lancamentos para estornar
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ ?>
<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>
<form id="frmDetalhesEstorno" name="frmDetalhesEstorno" class="formulario cabecalho" onSubmit="return false;" >
	<div>
		<fieldset>
			<legend>Dados</legend>
			
			<label for="cdestorno"><?php echo utf8ToHtml('Código:') ?></label>
			<input type="text" id="cdestorno" name="cdestorno" value=""/>
			
			<br />
			
			<label for="nmoperad">Operador: </label>
			<input type="text" id="nmoperad" name="nmoperad" value=""/>
			
			<label for="dtestorno">Data: </label>
			<input type="text" id="dtestorno" name="dtestorno" value=""/>
			
			<label for="hrestorno">Hora: </label>
			<input type="text" id="hrestorno" name="hrestorno" value=""/>
			
			<br />
			
			<label for="dsjustificativa"><?php echo utf8ToHtml('Justificativa:') ?></label>	
			
			<br />
			
			<textarea name="dsjustificativa" id="dsjustificativa"></textarea> 
			
		</fieldset>
	</div>
	<div>
		<fieldset>
			<legend>Lan&ccedil;amentos</legend>
				
			<div id="divEstornoDetalhes" class="divRegistros">
				<table width="100%">
					<thead>
						<tr>
							<th><?php echo utf8ToHtml('Parcela') ?></th>
							<th><?php echo utf8ToHtml('Vencimento') ?></th>
							<th><?php echo utf8ToHtml('Pagamento') ?></th>
							<th><?php echo utf8ToHtml('Historico') ?></th>
							<th><?php echo utf8ToHtml('Valor') ?></th>
						</tr>
					</thead>
					<tbody>
					<?php
					foreach ($aRegistros as $oLancamento) {
					?>
						<tr>
							<td><? echo getByTagName($oLancamento->tags,'nrparepr') ?></td>
							<td><? echo getByTagName($oLancamento->tags,'dtvencto') ?></td>
							<td><? echo getByTagName($oLancamento->tags,'dtpagamento') ?></td>
							<td><? echo getByTagName($oLancamento->tags,'cdhistor').' - '.getByTagName($oLancamento->tags,'dshistor') ?></td>
							<td><? echo formataMoeda(getByTagName($oLancamento->tags,'vllanmto')) ?></td>
						</tr>
					<?php
					}
					?>
					</tbody>
				</table>
			</div>
		</fieldset>
	</div>
</form>	
<div align="center">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
</div>