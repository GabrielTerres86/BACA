<?php 
/*
 * FONTE        : tab_borderos.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 22/05/2018
 * OBJETIVO     : Tabela que apresenta a consulta de borderos
 * --------------
 */
?>
<div id="divBorderos" name="divBorderos" >
    <br style="clear:both" />
    <div class="divRegistros">
        <table width="100%">
            <thead>
                <tr>
                    <th>Data Proposta</th>
                    <th>Border&ocirc;</th>
                    <th>Contrato</th>
                    <th>Qtd. Aprovados</th>
                    <th>Vlr. Aprovados</th>
                    <th>Qtd. Vencidos</th>
                    <th>Qtd. Vip/Exj/Jud</th>
                    <th>Vlr. Vencidos</th>
                    <th>Data de Libera&ccedil;&atilde;o</th>
                </tr>
            </thead>
            <?php
            foreach ($dados->find("inf") as $r) {
                ?>
                <tr>
                    <td><?php echo $r->dtmvtolt ?>
                        <input type="hidden" id="nrborder" name="nrborder" value="<?php echo $r->nrborder ?>" />
                        <input type="hidden" id="flavalis" name="flavalis" value="<?php echo $r->flavalis ?>" />
                    </td>
                    <td><?php echo $r->nrborder ?></td>
                    <td><?php echo $r->nrctrlim ?></td> 
					<td><?php echo $r->qtaprova ?></td>
                    <td><?php echo formataMoeda($r->vlaprova) ?></td>
                    <td><?php echo $r->qtvencid ?></td>
                    <td><?php echo $r->qtjexvip ?></td>
                    <td><?php echo formataMoeda($r->vlvencid) ?></td>
                    <td><?php echo $r->dtlibbdt ?></td>
                </tr>
                <?php
            }
            ?>
            </tbody>
        </table>
        <input type="hidden" id="qtdreg" name="qtdreg" value="<?php echo $qtregist; ?>" />
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
                    if (($nriniseq + $qtregist) > $qtregist) {
                        echo $qtregist;
                    } else {
                        echo ($nriniseq + $qtregist - 1);
                    }
                    ?> de <?php echo $qtregist; ?><?php
                }
                ?>
            </td>
            <td>
                <?php
                // Se a paginacao nao esta na ultima pagina, exibe botao proximo
                if ($qtregist > ($nriniseq + $qtregist - 1)) {
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
        buscaBorderos(<?php echo "'" . ($nriniseq - $qtregist) . "','" . $qtregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        buscaBorderos(<?php echo "'" . ($nriniseq + $qtregist) . "','" . $qtregist . "'"; ?>);
    });
</script>
