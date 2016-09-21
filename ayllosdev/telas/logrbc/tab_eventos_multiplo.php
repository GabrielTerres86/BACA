<?
/*!
 * FONTE        : tab_eventos_multiplo.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Novembro/2014
 * OBJETIVO     : Monta Tabela de eventos multi-arquivos LOGRBC
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<div id="tabEventoMultiplo" style="display:block" >
	<div class="divRegistros">
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Arquivo');  ?></th>
					<th><? echo utf8ToHtml('Eventos');  ?></th>
					<th><? echo utf8ToHtml('Detalhe do evento');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($eventos) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr><tr><td colspan="3" style="font-size:12px; text-align:center;">N&atilde;o foram encontrados registros no per&iacute;odo informado.</td></tr></tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($eventos); $i++) {
					?>
						<tr>
							<td><span><? echo getByTagName($eventos[$i]->tags,'dtprceve'); ?></span>
									  <? echo getByTagName($eventos[$i]->tags,'dtprceve'); ?>
							</td>
							<td><span><? echo getByTagName($eventos[$i]->tags,'nmarquiv'); ?></span>
									  <? echo getByTagName($eventos[$i]->tags,'nmarquiv'); ?>
							</td>
							<td><span><? echo getByTagName($eventos[$i]->tags,'dsesteve'); ?></span>
									  <? echo getByTagName($eventos[$i]->tags,'dsesteve'); ?>
							</td>
							<td><span><? echo str_replace('<![CDATA[','',str_replace(']]>','',getByTagName($eventos[$i]->tags,'dslogeve'))); ?></span>
									  <? echo str_replace('<![CDATA[','',str_replace(']]>','',getByTagName($eventos[$i]->tags,'dslogeve'))); ?>
							</td>
						</tr>
					<? } ?>
			<? } ?>
			</tbody>
		</table>
	</div>
    <div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
                    <?
                        //
                        if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;

                        // Se a paginação não está na primeira, exibe botão voltar
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
                        // Se a paginação não está na ultima página, exibe botão proximo
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
</div>
<script type="text/javascript">
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>