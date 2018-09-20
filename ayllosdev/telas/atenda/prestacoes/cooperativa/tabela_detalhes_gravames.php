<? 
/*!
 * FONTE        : tabela_detalhes_gravame.php
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
 *	<dsretor> - Copiar para a coluna Retorno;
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
					<th>CPF/CNPJ</th>
					<th>Contrato</th>
					<th>Chassi</th>
					<th>Descri&ccedil;&atilde;o do Bem</th>
					<th>Data Env</th>
					<th>Data Ret</th>
					<th>Situa&ccedil;&atilde;o</th>
					<th>Retorno</th>
				</tr>			
			</thead>
			<tbody>
				<?
				if ( count($detalhesGrav) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="13" style="width: 100px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o h&aacute; registros para exibir.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($detalhesGrav); $i++) {
					?>
						<tr id="linObsClick_<? echo $i; ?>">
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'cdcooper'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'cdcooper'); ?> 
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'cdagenci'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'cdagenci'); ?> 
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dsoperac'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'dsoperac'); ?> 
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'nrseqlot'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'nrseqlot'); ?> 
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'nrdconta'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'nrdconta'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'nrcpfcgc'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'nrcpfcgc'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'nrctrpro'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'nrctrpro'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dschassi'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'dschassi'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dsbemfin'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'dsbemfin'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dtenvgrv'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'dtenvgrv'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dtretgrv'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'dtretgrv'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dssituac'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'dssituac'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesGrav[$i]->tags,'dsretor'); ?></span>
									  <? echo getByTagName($detalhesGrav[$i]->tags,'dsretor'); ?>
							</td>
						</tr>
					<? }
				 } ?>
			</tbody>
		</table>
	</div>
</div>