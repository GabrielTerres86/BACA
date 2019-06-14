<?
/*!
 * FONTE        : tab_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Novembro/2014
 * OBJETIVO     : Monta Tabela de dados LOGRBC
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

<div id="tabDados" style="display:block" >
	<div class="divRegistros">
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Bureaux');  ?></th>
					<th><? echo utf8ToHtml('Observa&ccedil;&atilde;o');  ?></th>
					<th><? echo utf8ToHtml('Prepara&ccedil;&atilde;o');  ?></th>
					<th><? echo utf8ToHtml('Envio');  ?></th>
					<th><? echo utf8ToHtml('Retorno');  ?></th>
					<th><? echo utf8ToHtml('Devolu&ccedil;&atilde;o');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($remessas) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr><tr><td colspan="5" style="font-size:12px; text-align:center;">N&atilde;o foram encontrados registros no per&iacute;odo informado.</td></tr></tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($remessas); $i++) {
					?>
						<tr>
							<td><input type="hidden" id="indrowid" name="indrowid" value="<? echo getByTagName($remessas[$i]->tags,'indrowid') ?>" />
							    <span><? echo getByTagName($remessas[$i]->tags,'dtmvtolt'); ?></span>
									  <? echo getByTagName($remessas[$i]->tags,'dtmvtolt'); ?>
							</td>
							<td><span><? echo getByTagName($remessas[$i]->tags,'idtpreme'); ?></span>
									  <? echo getByTagName($remessas[$i]->tags,'idtpreme'); ?>
							</td>
							<td><span><? echo getByTagName($remessas[$i]->tags,'dtcancel'); ?></span>
									  <? echo getByTagName($remessas[$i]->tags,'dtcancel'); ?>
							</td>
							<td><span><? echo getByTagName($remessas[$i]->tags,'dssitpre'); ?></span>
									  <? echo getByTagName($remessas[$i]->tags,'dssitpre'); ?>
							</td>
							<td><span><? echo getByTagName($remessas[$i]->tags,'dssitenv'); ?></span>
									  <? echo getByTagName($remessas[$i]->tags,'dssitenv'); ?>
							</td>
							<td><span><? echo getByTagName($remessas[$i]->tags,'dssitret'); ?></span>
									  <? echo getByTagName($remessas[$i]->tags,'dssitret'); ?>
							</td>
							<td><span><? echo getByTagName($remessas[$i]->tags,'dssitdev'); ?></span>
									  <? echo getByTagName($remessas[$i]->tags,'dssitdev'); ?>
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