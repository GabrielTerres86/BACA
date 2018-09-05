<?php 
/*
 * FONTE        : tab_boletos.php
 * CRIAÇÃO      : Vitor Shimada Assanuma (GFT)
 * DATA CRIAÇÃO : 22/05/2018
 * OBJETIVO     : Tabela que apresenta a consulta de borderos
 * --------------
 */
?>
<div id="divBoletos" name="divBoletos" >
    <br style="clear:both" />
    <div class="divRegistros">
        <table width="100%">
            <thead>
                <tr>
                    <th>PA</th>
                    <th>Conta/DV</th>
                    <th>Border&ocirc;</th>
                    <th>Data</th>
                    <th>Boleto</th>
                    <th>Vencto</th>
                    <th>Valor</th>
                    <th>Dt.Pagto</th>
                    <th>Vlr.Pago</th>
                    <th>Situa&ccedil;&atilde;o</th>
                    <th>Dt.Baixa</th>
                </tr>
            </thead>
            <?php
            $conta = 0;
            foreach ($dados->find("inf") as $r) {
                $conta++;
                ?>
                <tr>
                    <td><?php echo $r->cdagenci ?>
                        <input type="hidden" id="nrdconta" name="nrdconta" value="<?php echo $r->nrdconta ?>" />
                        <input type="hidden" id="nrborder" name="nrborder" value="<?php echo $r->nrborder ?>" />
                        <input type="hidden" id="nrdocmto" name="nrdocmto" value="<?php echo $r->nrdocmto ?>" />
                        <input type="hidden" id="nrctacob" name="nrctacob" value="<?php echo $r->nrctacob ?>" />
                        <input type="hidden" id="nrcnvcob" name="nrcnvcob" value="<?php echo $r->nrcnvcob ?>" />
                        <input type="hidden" id="lindigit" name="lindigit" value="<?php echo $r->lindigit ?>" />
                    </td>
                    <td><?php echo $r->nrdconta ?></td>
                    <td><?php echo $r->nrborder ?></td>
                    <td><?php echo $r->dtmvtolt ?></td> 
                    <td><?php echo $r->nrdocmto ?></td>
					<td><?php echo $r->dtvencto ?></td>
                    <td><?php echo formataMoeda($r->vlboleto) ?></td>
                    <td><?php echo $r->dtdpagto ?></td>
                    <td><?php echo formataMoeda($r->vldpagto) ?></td>
                    <td><?php echo $r->dssituac ?></td>
                    <td><?php echo $r->dtdbaixa ?></td>
                </tr>
                <?php
            }
            ?>
            </tbody>
        </table>
        <input type="hidden" id="qtdreg" name="qtdreg" value="<?php echo $conta; ?>" />
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
        buscaBorderos(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        buscaBorderos(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>
