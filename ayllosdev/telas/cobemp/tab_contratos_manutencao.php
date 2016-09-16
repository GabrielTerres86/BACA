<?php
/* !
 * FONTE        : tab_contratos.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 14/08/2015
 * OBJETIVO     : Tabela que apresenta a consulta de contratos
 * --------------
 * ALTERAÇÕES   : 
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

<div id="divContratos" name="divContratos" >
    <br style="clear:both" />
    <div class="divRegistros">
        <table width="100%">
            <thead>
                <tr>
                    <th><?php echo utf8ToHtml('PA') ?></th>
                    <th><?php echo utf8ToHtml('Conta/DV') ?></th>
                    <th><?php echo utf8ToHtml('Contrato') ?></th>
                    <th><?php echo utf8ToHtml('Data') ?></th>
                    <th><?php echo utf8ToHtml('Boleto') ?></th>
                    <th><?php echo utf8ToHtml('Vencto') ?></th>
                    <th><?php echo utf8ToHtml('Valor') ?></th>
                    <th><?php echo utf8ToHtml('Dt.Pagto') ?></th>
                    <th><?php echo utf8ToHtml('Vlr.Pago') ?></th>
                    <th><?php echo utf8ToHtml('Situa&ccedil;&atilde;o') ?></th>
                    <th><?php echo utf8ToHtml('Dt.Baixa') ?></th>
                </tr>
            </thead>
            <tbody>

                <?php
                $conta = 0;
                foreach ($registros as $r) {
                    $conta++;
                    ?>
                    <tr>
                        <td><span><?php echo getByTagName($r->tags, 'cdagenci'); ?></span>
                            <?php echo getByTagName($r->tags, 'cdagenci'); ?>
                        </td>
                        <td id='nrdconta'><span><?php echo getByTagName($r->tags, 'nrdconta'); ?></span>	
                            <?php echo formataContaDV(getByTagName($r->tags, 'nrdconta')); ?>
                            <input type="hidden" id="<?php echo 'nrdconta' . $conta; ?>" name="<?php echo 'nrdconta' . $conta; ?>" value="<?php echo getByTagName($r->tags, 'nrdconta'); ?>" />
                            <input type="hidden" id="nrctacob" name="nrctacob" value="<?php echo getByTagName($r->tags, 'nrctacob'); ?>" />
                            <input type="hidden" id="nrcnvcob" name="nrcnvcob" value="<?php echo getByTagName($r->tags, 'nrcnvcob'); ?>" />
                            <input type="hidden" id="lindigit" name="lindigit" value="<?php echo getByTagName($r->tags, 'lindigit'); ?>" />
                            <input type="hidden" id="nrctremp" name="nrctremp" value="<?php echo getByTagName($r->tags, 'nrctremp'); ?>" />
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'nrctremp'); ?></span>
                            <?php echo formataNumericos("zz.zzz.zzz", getByTagName($r->tags, "nrctremp"), "."); ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'dtmvtolt'); ?></span>
                            <?php echo getByTagName($r->tags, 'dtmvtolt'); ?>
                        </td>
                        <td id="nrdocmto"><span><?php echo getByTagName($r->tags, 'nrdocmto'); ?></span>
                            <?php echo getByTagName($r->tags, 'nrdocmto'); ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'dtvencto'); ?></span>
                            <?php echo getByTagName($r->tags, 'dtvencto'); ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'vlboleto'); ?></span>
                            <?php echo number_format(str_replace(",", ".", getByTagName($r->tags, 'vlboleto')), 2, ",", "."); ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'dtdpagto'); ?></span>
                            <?php echo getByTagName($r->tags, 'dtdpagto'); ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'vldpagto'); ?></span>
                            <?php echo number_format(str_replace(",", ".", getByTagName($r->tags, 'vldpagto')), 2, ",", "."); ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'dssituac'); ?></span>
                            <?php echo getByTagName($r->tags, 'dssituac'); ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'dtdbaixa'); ?></span>
                            <?php echo getByTagName($r->tags, 'dtdbaixa'); ?>
                        </td>
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

                // Se a paginação não está na primeira, exibe botão voltar
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
                // Se a paginação não está na última página, exibe botão proximo
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
        buscaContratos(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        buscaContratos(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>