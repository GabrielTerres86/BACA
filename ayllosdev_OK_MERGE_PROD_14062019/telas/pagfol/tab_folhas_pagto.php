<?
/*!
 * FONTE        : tab_folhas_pagto.php
 * CRIAÇÃO      : Renato Darosci - SUPERO
 * DATA CRIAÇÃO : Junho/2015
 * OBJETIVO     : Formulário de de
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<div id="dadosEmpresa" style="display:block">	
		<br>
		<fieldset>
		<hr width="250px">
		<table >
			<!--tr>
				<td width="160px" class="txtNormalBold" style="text-align:right;">
					<label for="nmresemp" align="right" style="width:100%;" ><? echo utf8ToHtml('Empresa:') ?></label>
				</td>
				<td colspan="3">
					<input name="nmresemp" type="text"  id="nmresemp" class='campoTelaSemBorda' size="100" value="<? echo $dsempres; ?>"  readOnly />
				</td>
			</tr-->
			<tr>
				<td width="160px" class="txtNormalBold" style="text-align:right;">
					<label for="nrdconta" align="right" style="width:100%;"><? echo utf8ToHtml('Conta:') ?></label>	
				</td>
				<td>
					<input name="nrdconta" type="text"  id="nrdconta" class='campoTelaSemBorda' size="35" value="<? echo $nrdconta; ?>"  readOnly />
				</td>
				<td width="90px" class="txtNormalBold" style="text-align:right;">
					<label for="nmagenci" align="right" style="width:100%;"><? echo utf8ToHtml('PA:') ?></label>
				</td>
				<td>
					<input name="nmagenci" type="text"  id="nmagenci" class='campoTelaSemBorda' size="45" value="<? echo $nmagenci; ?>"  readOnly />
				</td>
			</tr>
			<tr>
				<td width="160px" class="txtNormalBold" style="text-align:right;">
					<label for="dsdregio" align="right" style="width:100%;"><? echo utf8ToHtml('Regional:') ?></label>	
				</td>
				<td>
					<input name="dsdregio" type="text"  id="dsdregio" class='campoTelaSemBorda' size="35" value="<? echo $dsdregio; ?>"  readOnly />
				</td>
				<td width="90px" class="txtNormalBold" style="text-align:right;">
					<label for="nmconspj" align="right" style="width:100%;"><? echo utf8ToHtml('Consultor PJ:') ?></label>	
				</td>
				<td>
					<input name="nmconspj" type="text"  id="nmconspj" class='campoTelaSemBorda' size="45" value="<? echo $nmconspj; ?>"  readOnly />
				</td>
			</tr>
			<tr>
				<td width="160px" class="txtNormalBold" style="text-align:right;">
					<label for="dtultufp" align="right" style="width:100%;"><? echo utf8ToHtml('&Uacuteltimo uso:') ?></label>	
				</td>
				<td>
					<input name="dtultufp" type="text"  id="dtultufp" class='campoTelaSemBorda' size="35" value="<? echo $dtultufp; ?>"  readOnly />
				</td>
				<td width="90px" class="txtNormalBold" style="text-align:right;">
					&nbsp;
				</td>
				<td>
					&nbsp;
				</td>
			</tr>
		</table>
		</fieldset>	
		<br>
</div>

<div id="tabFolhaPagto" style="display:block">
	<div class="divRegistros" >
        <table class="regsPagamentos" >
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Seq.');  ?></th>
					<th><? echo utf8ToHtml('Data Agend.');  ?></th>
					<th><? echo utf8ToHtml('Data D&eacute;bito');  ?></th>
					<th><? echo utf8ToHtml('Sit. D&eacute;b.');  ?></th>
					<th><? echo utf8ToHtml('Data Cr&eacute;dito');  ?></th>
					<th><? echo utf8ToHtml('Sit. Cr&eacute;d.');  ?></th>
					<th><? echo utf8ToHtml('Qtd. Lanctos');  ?></th>
					<th><? echo utf8ToHtml('Qtd. CTASAL');  ?></th>
					<th><? echo utf8ToHtml('Vlr R$ Pagto');  ?></th>
					<th><? echo utf8ToHtml('Tot. Tarifa');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($pagamentosFolha) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="11" style="width: 80px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o h&aacute; registros para exibir.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($pagamentosFolha); $i++) {
					?>
						<tr>
							<td><input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($pagamentosFolha[$i]->tags,'cdcooper') ?>" />
							    <input type="hidden" id="cdempres" name="cdempres" value="<? echo getByTagName($pagamentosFolha[$i]->tags,'cdempres') ?>" />
								<input type="hidden" id="nrseqpag" name="nrseqpag" value="<? echo getByTagName($pagamentosFolha[$i]->tags,'nrseqpag') ?>" />
							    <span><? echo getByTagName($pagamentosFolha[$i]->tags,'nrseqpag'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'nrseqpag'); ?> 
							</td>
							<td><span><? echo getByTagName($pagamentosFolha[$i]->tags,'dtmvtolt'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'dtmvtolt'); ?>
							</td>
							<td><span><? echo getByTagName($pagamentosFolha[$i]->tags,'dtdebito'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'dtdebito'); ?>
							</td>
							<td><span><? echo getByTagName($pagamentosFolha[$i]->tags,'flsitdeb'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'flsitdeb'); ?>
							</td>
							<td><span><? echo getByTagName($pagamentosFolha[$i]->tags,'dtcredit'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'dtcredit'); ?>
							</td>
							<td><span><? echo getByTagName($pagamentosFolha[$i]->tags,'flsitcre'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'flsitcre'); ?>
							</td>
							<td><span><? echo getByTagName($pagamentosFolha[$i]->tags,'qtlctpag'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'qtlctpag'); ?>
							</td>
							<td><span><? echo getByTagName($pagamentosFolha[$i]->tags,'qtctasal'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'qtctasal'); ?>
							</td>
							<td><span><? echo getByTagName($pagamentosFolha[$i]->tags,'vllctpag'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'vllctpag'); ?>
							</td>
							<td ><span><? echo getByTagName($pagamentosFolha[$i]->tags,'vltarifa'); ?></span>
									  <? echo getByTagName($pagamentosFolha[$i]->tags,'vltarifa'); ?>
							</td>
						</tr>
					<? } ?>
			<? } ?>
			</tbody>
		</table>
	</div>
	<br>
</div>
</div>
<script>
cNmresemp.desabilitaCampo();
cNmcooper.desabilitaCampo();
cDsdregio.desabilitaCampo();
cNmconspj.desabilitaCampo();
</script>