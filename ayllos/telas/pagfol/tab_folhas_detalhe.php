<?
/*!
 * FONTE        : tab_folhas_detalhe.php
 * CRIAÇÃO      : Renato Darosci - SUPERO
 * DATA CRIAÇÃO : Junho/2015
 * OBJETIVO     : Formulário de detalhes
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<div id="tabFolhaDetalhe" style="display:block;" align="center">
	<div class="divRegistros">
        <table class="regsDetalhes">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('CPF');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Nome');  ?></th>
					<th><? echo utf8ToHtml('Modalidade');  ?></th>
					<th><? echo utf8ToHtml('Valor R$');  ?></th>
					<th><? echo utf8ToHtml('Situa&ccedil;&atilde;o');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($detalhesPgto) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="7" style="width: 80px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o h&aacute; registros para exibir.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($detalhesPgto); $i++) {
					?>
						<tr id="linObsClick_<? echo $i; ?>">
							<td><span><? echo getByTagName($detalhesPgto[$i]->tags,'nrcpfcgc'); ?></span>
									  <? echo getByTagName($detalhesPgto[$i]->tags,'nrcpfcgc'); ?> 
							</td>
							<td><span><? echo getByTagName($detalhesPgto[$i]->tags,'nrdconta'); ?></span>
									  <? echo getByTagName($detalhesPgto[$i]->tags,'nrdconta'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesPgto[$i]->tags,'nmprimtl'); ?></span>
									  <? echo getByTagName($detalhesPgto[$i]->tags,'nmprimtl'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesPgto[$i]->tags,'dsmodali'); ?></span>
									  <? echo getByTagName($detalhesPgto[$i]->tags,'dsmodali'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesPgto[$i]->tags,'vllancto'); ?></span>
									  <? echo getByTagName($detalhesPgto[$i]->tags,'vllancto'); ?>
							</td>
							<td><span><? echo getByTagName($detalhesPgto[$i]->tags,'idsitlct'); ?></span>
									  <? echo getByTagName($detalhesPgto[$i]->tags,'idsitlct'); ?>
							</td>
						</tr>
					<? } ?>
			<? } ?>
			</tbody>
		</table>
	</div>
    <div id="divObservacao" style="display:none;">
        <table class="regsDetalhes" width="500">
			<thead>
				<tr><th bgcolor="#f7d3ce"><? echo utf8ToHtml('Observa&ccedil;&atilde;o');  ?></th></tr>
			</thead>
			<tbody>
                <? // Carrega as observacoes
                for ($i = 0; $i < count($detalhesPgto); $i++) { 
                    $dsobslct = getByTagName($detalhesPgto[$i]->tags,'dsobslct') != '' ? getByTagName($detalhesPgto[$i]->tags,'dsobslct') : 'Sem observa&ccedil;&otilde;es para o lan&ccedil;amento' ;
                    ?>
                    <tr class="linObs" id="linObs_<? echo $i; ?>"><td><? echo $dsobslct; ?></td></tr>
                 <? } ?>
                <tr><td>&nbsp;</td></tr>
			</tbody>
		</table>
    </div>
</div>
	<div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
                    <?
                        if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;
                        if ($nriniseq > 1) {
                            ?> <a class='paginacaoAnt'><<< Anterior</a> <?
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>
                </td>
                <td>
                    <?
                        if ($nriniseq) {
                            ?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
                    <?  } ?>
                </td>
                <td>
                    <?
                        if ($qtregist > ($nriniseq + $nrregist - 1)) {
                            ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>
                </td>
            </tr>
        </table>
    </div>

<script type="text/javascript">
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>