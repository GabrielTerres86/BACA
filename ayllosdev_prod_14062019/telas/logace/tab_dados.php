<?
/*!
 * FONTE        : tab_dados.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 26/03/2013
 * OBJETIVO     : Tabela que apresenta a consulta da LOGACE
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<div id="tabDados">
	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Tela'); ?></th>
					<th><? echo utf8ToHtml('Cooperativa');  ?></th>
					<th><? echo utf8ToHtml('Orig. Acesso');  ?></th>
					<th><? echo utf8ToHtml('Qtd Usuarios');  ?></th>
					<th><? echo utf8ToHtml('Qtd Acessos');  ?></th>
					<th><? echo utf8ToHtml('Listar Usuarios');  ?></th>
				</tr>
			</thead>
			<tbody>
			<?
				if ( $qtRegistros == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr><tr><td colspan="6" style="font-size:12px; text-align:center;">N&atilde;o foram encontrados log's de acessos com os par&acirc;metros informados.</td></tr></tr>
			<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {

					for ($i = 0; $i < $qtRegistros; $i++) {
					?>
						<tr>
							<td><span><? echo getByTagName($registros[$i]->tags,'dsdatela'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'dsdatela'); ?>
									  <input type="hidden" id="dsdatela" name="dsdatela" value="<? echo getByTagName($registros[$i]->tags,'dsdatela') ?>" />
									  <input type="hidden" id="dscooper" name="dscooper" value="<? echo getByTagName($registros[$i]->tags,'dscooper') ?>" />
									  <input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($registros[$i]->tags,'cdcooper') ?>" />
									  <input type="hidden" id="idorigem" name="idorigem" value="<? echo getByTagName($registros[$i]->tags,'idorigem') ?>" />
									  <input type="hidden" id="rowid"    name="rowid"    value="<? echo getByTagName($registros[$i]->tags,'rowid') ?>" />
									  <input type="hidden" id="dsorigem" name="dsorigem" value="<? echo getByTagName($registros[$i]->tags,'dsorigem') ?>" />
									  <input type="hidden" id="qtdusuar" name="qtdusuar" value="<? echo getByTagName($registros[$i]->tags,'qtdusuar') ?>" />
									  <input type="hidden" id="qtdacess" name="qtdacess" value="<? echo getByTagName($registros[$i]->tags,'qtdacess') ?>" />

							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'dscooper'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'dscooper'); ?>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'dsorigem'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'dsorigem'); ?>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'qtdusuar'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'qtdusuar'); ?>
							</td>
							<td><span><? echo getByTagName($registros[$i]->tags,'qtdacess'); ?></span>
									  <? echo getByTagName($registros[$i]->tags,'qtdacess'); ?>
							</td>
							<td><span></span>
									  <? if (getByTagName($registros[$i]->tags,'idresult') == "1") {
											$rowid    = getByTagName($registros[$i]->tags,'rowid');
											$cdcooper = getByTagName($registros[$i]->tags,'cdcooper');
											$dsdatela = getByTagName($registros[$i]->tags,'dsdatela');
											$idorigem = getByTagName($registros[$i]->tags,'idorigem');
											$qtdregis = getByTagName($registros[$i]->tags,'qtdusuar');?>
											<a href="#" id="btDetalhe" onClick="ver_detalhes(<? echo $cdcooper?>,'<? echo $dsdatela?>',<? echo $idorigem?>, 1, 10);return false;"> Listar</a>
										<?
										} else {
											echo "-";
										}; ?>
							</td>
						</tr>
				 <? } ?>
			<?  } ?>
			</tbody>
		</table>
	</div>

    <div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
<?                      if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;

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
                        if (isset($nriniseq)) {
                            ?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
                        }
                    ?>
                </td>
                <td>
                    <?
                        // Se a paginação não está na &uacute;ltima página, exibe botão proximo
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
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		executaPesquisa(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		executaPesquisa(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});

	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>