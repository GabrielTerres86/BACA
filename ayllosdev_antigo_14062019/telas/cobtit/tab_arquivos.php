<?php
/*
 * FONTE        : tab_arquivos.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 14/06/2018
 * OBJETIVO     : Tabela que apresenta a consulta de arquivos
 */

?>

<div id="divArquivos" name="divArquivos" >
    <br style="clear:both" />
    <div class="divRegistros">
        <table width="100%">
            <thead>
                <tr>
                    <th>Remessa</th>
                    <th>Data</th>
                    <th>Nome do Arquivo</th>
                    <th>Qtd. Boletos</th>
                    <th>Qtd. Boletos Cr&iacute;ticas</th>
                    <th>Situa&ccedil;&atilde;o</th>
                </tr>
            </thead>
            <tbody>
            <?php
                foreach ($registro as $r) {
                    ?>
                    <tr>
                        <td><span><?php echo $r->idarquivo; ?></span>
                            <?php echo $r->idarquivo; ?>
                            <input type="hidden" id="idarquivo" name="idarquivo" value="<?php echo $r->idarquivo; ?>" />
                        </td>
                        <td><span><?php echo $r->dtarquivo; ?></span>
                            <?php echo $r->dtarquivo; ?>
                        </td>
                        <td><span><?php echo $r->nmarq_import; ?></span>
                            <?php echo $r->nmarq_import; ?>
                        </td>
                        <td><span><?php echo $r->qtd_boleto; ?></span>
                            <?php echo $r->qtd_boleto; ?>
                        </td>
                        <td><span><?php echo $r->qtd_critica; ?></span>
                            <?php echo $r->qtd_critica; ?>
                        </td>
                        <td><span><?php echo $r->situacaoarq; ?></span>
                            <?php echo $r->situacaoarq; ?>
                            <input type="hidden" id="situacaoarq" name="situacaoarq" value="<?php echo $r->situacaoarq; ?>" />
                        </td>
                    </tr>
                    <?php
                }
            ?>
            </tbody>
        </table>
    </div>
</div>

<div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>
        <tr>
            <td>
                <?php
                if (isset($qtregist) and $qtregist == 0) {
                    $nriniseq = 0;
                }
                // Se a paginacao nao esta na primeira, exibe botao voltar
                if ($nriniseq > 1) {
                    ?> <a class='paginacaoAnterior'><<< Anterior</a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>
            </td>
            <td>
                <?php
                if (isset($nriniseq)) {
                    ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php
                    if (($nriniseq + $nrregist) > $qtregist) {
                        echo $qtregist;
                    } else {
                        echo ($nriniseq + $nrregist - 1);
                    }
                    ?> de <?php echo $qtregist; ?><?php
                }
                ?>
            </td>
            <td>
                <?php
                // Se a paginacao nao esta na ultima pagina, exibe botao proximo
                if ($qtregist > ($nriniseq + $nrregist - 1)) {
                    ?> <a class='paginacaoProximo'>Pr&oacute;ximo >>></a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>
            </td>
        </tr>
    </table>
</div>

<script type="text/javascript">
    $('a.paginacaoAnterior').unbind('click').bind('click', function() {
        carregaArquivos(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        carregaArquivos(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>
