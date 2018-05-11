<?php 

/* !
 * FONTE        : tab_contas.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 11/09/2015
 * OBJETIVO     : Tabela que apresenta a consulta de contas
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ ?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<div id="divArquivos" name="divArquivos" >
    <br style="clear:both" />
    <div class="divRegistros">
        <table width="100%" >
            <thead>
                <tr>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Coop'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Reg'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('PA'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Conta'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Lct'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Bandeira'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Forma Transf'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Dt Lct'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Dt Arq'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Valor'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Situacao'); ?></th>
                    <th style="font-size: 11px"><?php echo utf8ToHtml('Erro'); ?></th>
                </tr>
            </thead>

            <?php
            foreach ($registros as $r) {
                ?>
                <tr>
                    <td><?php echo getByTagName($r->tags, 'cdcooper') ?>
                        <input type="hidden" id="nmrescop" name="nmrescop" value="<?php echo getByTagName($r->tags,'nmrescop') ?>" />
                        <input type="hidden" id="nmprimtl" name="nmprimtl" value="<?php echo getByTagName($r->tags,'nmprimtl') ?>" />
                        <input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo getByTagName($r->tags,'nrcpfcgc') ?>" />
                    </td>
                    <td><?php echo getByTagName($r->tags, 'cddregio'); ?></td> 
                    <td><?php echo getByTagName($r->tags, 'cdagenci'); ?></td>
                    <td><?php echo getByTagName($r->tags, 'nrdconta'); ?></td>
                    <td><?php echo trim(getByTagName($r->tags, 'tplancto')); ?></td>
                    <td><?php echo trim(getByTagName($r->tags, 'nmarranjo')); ?></td>
                    <td><?php echo getByTagName($r->tags, 'formatransf'); ?></td>
                    <td><?php echo getByTagName($r->tags, 'dtrefere'); ?></td>
                    <td><?php echo getByTagName($r->tags, 'dtinclus'); ?></td>
                    <td><?php echo getByTagName($r->tags, 'vllancto'); ?></td>
                    <td><?php echo getByTagName($r->tags, 'dssituac'); ?></td>
                    <td title="<?php echo getByTagName($r->tags, 'dserro');?>">
                        <?php echo getByTagName($r->tags, 'dserro');?>
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
                    ?> <a class='paginacaoAnt'><<< Anterior</a> <?php
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
                    ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>			
            </td>
        </tr>
    </table>
</div>

<div id="divTotaisConta" style="margin-bottom: 15px; text-align:center; margin-top: 15px;"> 
    
    <label for="qtregist"><?php echo utf8ToHtml('Quantidade Total:') ?></label>
    <input style="text-align: right"  type="text" id="qtregist" name="qtregist" value="<?php echo $qtregist ?>"/>

    <label for="vltotal" style="margin-left: 20px;"><?php echo utf8ToHtml('Valor Total:') ?></label>
    <input style="text-align: right"  type="text" id="vltotal" name="vltotal" value="<?php echo $vltotal ?>"/>


</div>

<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        buscaContas(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        buscaContas(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>