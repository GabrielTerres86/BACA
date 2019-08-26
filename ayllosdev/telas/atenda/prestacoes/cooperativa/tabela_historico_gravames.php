<? 
/*!
 * FONTE        : tabela_historico_gravame.php
 * CRIAÇÃO      : Christian Grauppe - Envolti
 * DATA CRIAÇÃO : 19/09/2018 
 * OBJETIVO     : Tabela que apresenta os detalhes do GRAVAMES do bem
 *
 *	<cdcooper> - Copiar para a coluna Coop;
 *	<cdagenci> - Copiar para a coluna PA;
 *	<dsoperac> - Copiar para a coluna Operação;
 *	<nrseqlot> - Copiar para a coluna Lote;
 *	<nrdconta> - Copiar para a coluna Conta/DV;
 *	<nrcpfcgc> - Copiar para a coluna CPF/CNPJ;
 *	<nrctrpro> - Copiar para a coluna Contrato;
 *	<dschassi> - Copiar para a coluna Chassi;
 *	<dsbemfin> - Copiar para a coluna Descrição do Bem;
 *	<dtenvgrv> - Copiar para a coluna Data Env;
 *	<dtretgrv> - Copiar para a coluna Data Ret;
 *	<dssituac> - Copiar para a coluna Situação;
 *	<desretor> - Copiar para a coluna Retorno;
 *
 */
?>

<div id="divDetGravTabela">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th>Coop</th>
					<th>PA</th>
					<th>Opera&ccedil;&atilde;o</th>
					<th>Lote</th>
					<th>Conta/DV</th>
					<? /* th>CPF/CNPJ</th */ ?>
					<th>Contrato</th>
					<th>Chassi</th>
					<th>Descri&ccedil;&atilde;o do Bem</th>
					<th>Data Env</th>
					<th>Data Ret</th>
					<th>Situa&ccedil;&atilde;o</th>
					<? /* th>Retorno</th */ ?>
				</tr>			
			</thead>
			<tbody>
				<?
				if ($qtregist == 0) {
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="11" style="width: 100px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $qtregist; ?>" />
								<b>N&atilde;o h&aacute; registros para exibir.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($detalhesGrav); $i++) {
					?>
						<tr id="linObsClick_<? echo $i; ?>">
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'cdcooper'); ?></span><? echo trim(getByTagName($detalhesGrav[$i]->tags,'cdcooper')); ?></td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'cdagenci'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'cdagenci'); ?></td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dsoperac'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'dsoperac'); ?></td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'nrseqlot'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'nrseqlot'); ?></td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'nrdconta'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'nrdconta'); ?></td>
							<? /*td><span><? echo getByTagName($detalhesGrav[$i]->tags,'nrcpfcgc'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'nrcpfcgc'); ?>
							</td */ ?>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'nrctrpro'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'nrctrpro'); ?></td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dschassi'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'dschassi'); ?></td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dsbemfin'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'dsbemfin'); ?></td>
							<td class="dtenvgrv"><span><? echo getByTagName($detalhesGrav[$i]->tags,'dtenvgrv'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'dtenvgrv'); ?></td>
							<td class="dtretgrv"><span><? echo getByTagName($detalhesGrav[$i]->tags,'dtretgrv'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'dtretgrv'); ?></td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dssituac'); ?></span><? echo getByTagName($detalhesGrav[$i]->tags,'dssituac'); ?></td>
							<input type="hidden" id="dsretorLinha<? echo $i; ?>" name="dsretorLinha<? echo $i; ?>" value="<? echo getByTagName($detalhesGrav[$i]->tags,'desretor'); ?>" />
						</tr>
					<? }
				 } ?>
			</tbody>
		</table>
	</div>
</div>
<? if ($qtregist > 0) { ?>
	<div style="height:50px;">
		<table width="100%">
			<tbody>
				<tr>
					<td class="txtNormalBold" style="text-align:left; width: 50px;">
						<label for="dsdregio" align="right" style="width:100%;">Retorno:</label>	
					</td>
					<td>
						<input name="dsretorLinha" type="text" id="dsretorLinha" class="campoTelaSemBorda" value="" readonly="readonly" style="width:100%;" />
					</td>
				</tr>
			</tbody>
		</table>
	</div>
    <div id="divPesquisaRodape" class="divPesquisaRodape">
      <table>
        <tr>
          <td>
            <?if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;
				  if ($nriniseq > 1) {
					  ?> <a class='paginacaoAnt'> <<< Anterior</a> <?
				  } ?>
          </td>
          <td>
            <? if (isset($nriniseq)) { ?>
				Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
			<? } ?>
          </td>
          <td>
            <? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
            <a class="paginacaoProx">Pr&oacute;ximo >>></a>
            <? } ?>
          </td>
        </tr>
      </table>
    </div>
	<script type="text/javascript">
		$('a.paginacaoAnt').unbind('click').bind('click', function() {
			mostraTabelaHistoricoGravames( <? echo ($nriniseq - $nrregist) . "," . $nrregist; ?> );
		});

		$('a.paginacaoProx').unbind('click').bind('click', function() {
			mostraTabelaHistoricoGravames( <? echo ($nriniseq + $nrregist) . "," . $nrregist; ?> );
		});

		$('#divPesquisaRodape').formataRodapePesquisa();

		divRegistro = $('div.divRegistros' , '#divDetGravTabela');

		$('table > tbody > tr', divRegistro).click( function() {
            num = $(this).attr('id').replace('linObsClick_','');
			$('#dsretorLinha').val( $('#dsretorLinha' + num).val() );
		});

		//formataFormularioBens();
		//formataTabelaBens();

	</script>
<? } ?>