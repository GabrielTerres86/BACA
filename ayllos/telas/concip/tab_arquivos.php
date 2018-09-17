<?php

/*
 * FONTE        : tab_arquivos.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 11/09/2015
 * OBJETIVO     : Tabela que apresenta a consulta de arquivos
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
        <table width="100%">
            <thead>
                <tr>
                    <th><?php echo utf8ToHtml('Arquivo Recebido') ?></th>
                    <th><?php echo utf8ToHtml('Tipo') ?></th>
                    <th><?php echo utf8ToHtml('Banco Liquidante') ?></th>
                    <th><?php echo utf8ToHtml('Credenciadora') ?></th>
                    <th><?php echo utf8ToHtml('Data Rec.') ?></th>
                    <th><?php echo utf8ToHtml('Data Liquidação C/C') ?></th>
                    <th><?php echo utf8ToHtml('Arquivo Gerado') ?></th>
                    <th><?php echo utf8ToHtml('Data Geração') ?></th>
                    <th><?php echo utf8ToHtml('Ret.') ?></th>
                </tr>
            </thead>

            <?php
            foreach ($registros as $r) {
                ?>
                <tr>
                    <?php
                      //formatacao de nomes de arquivos
                      $arquivo_fullname = getByTagName($r->tags, 'nmarquivo');
                      $arquivo_abrev = explode('_', $arquivo_fullname);
                      $arquivo_abrev = $arquivo_abrev[0];
                      $gerado_fullname = getByTagName($r->tags, 'nmarquivo_gerado');
                      $gerado_abrev = explode('_', $gerado_fullname);
                      $gerado_abrev = $gerado_abrev[0];
                    ?>
                    <td style="max-width: 126px; overflow-x: hidden;" title="<?php echo $arquivo_fullname;?>"><?php echo $arquivo_abrev; ?>
                    <input type="hidden" id="nmarquivo" name="nmarquivo" value="<?php echo $arquivo_fullname; ?>" />
                    </td>
                    <td><?php echo getByTagName($r->tags, 'tparquivo') ?></td>
                    <td><?php echo getByTagName($r->tags, 'bcoliquidante'); ?></td>
                    <td><?php echo getByTagName($r->tags, 'nmcredenciador'); ?></td>
                    <td><?php echo getByTagName($r->tags, 'dtinclusao') ?></td>
                    <td><?php echo getByTagName($r->tags, 'dtliquidacao') ?>
                        <input type="hidden" id="dtliquidacao" name="dtliquidacao" value="<?php echo getByTagName($r->tags,'dtliquidacao') ?>" />
                    </td>
                    <td title="<?php echo $gerado_fullname; ?>"><?php echo $gerado_abrev; ?></td>
                    <td><?php echo getByTagName($r->tags, 'dtgeracao') ?>
                        <input type="hidden" id="dtgeracao" name="dtgeracao" value="<?php echo getByTagName($r->tags,'dtgeracao') ?>" />
                    </td>
                    <td><?php echo getByTagName($r->tags, 'tpretorno') ?></td>
                    <input type="hidden" id="qtprocessados" name="qtprocessados" value="<? echo getByTagName($r->tags,'qtprocessados'); ?>" />
                    <input type="hidden" id="vlprocessados" name="vlprocessados" value="<? echo formataMoeda(getByTagName($r->tags,'vlprocessados')); ?>" />
                    <input type="hidden" id="qtintegrados" name="qtintegrados" value="<? echo getByTagName($r->tags,'qtintegrados'); ?>" />
                    <input type="hidden" id="vlintegrados" name="vlintegrados" value="<? echo formataMoeda(getByTagName($r->tags,'vlintegrados')); ?>" />
                    <input type="hidden" id="qtagendados" name="qtagendados" value="<? echo getByTagName($r->tags,'qtagendados'); ?>" />
                    <input type="hidden" id="vlagendados" name="vlagendados" value="<? echo formataMoeda(getByTagName($r->tags,'vlagendados')); ?>" />
                    <input type="hidden" id="qterros" name="qterros" value="<? echo getByTagName($r->tags,'qterros'); ?>" />
                    <input type="hidden" id="vlerros" name="vlerros" value="<? echo formataMoeda(getByTagName($r->tags,'vlerros')); ?>" />
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

<div id="divTotaisArquivo" style="margin-bottom: 15px; text-align:center; margin-top: 15px; display: flex;">

    <fieldset style="padding:0px; margin:0px; padding-bottom:10px; width: 25%;">
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Processados:') ?></legend>

        <fieldset>
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Arquivo selecionado:') ?></legend>

            <label for="fsqtprocessados"><? echo utf8ToHtml('Quantidade:') ?></label>
            <input type="text" id="fsqtprocessados" name="fsqtprocessados"/>

            <label for="fsvlprocessados"><? echo utf8ToHtml('Valor:') ?></label>
            <input type="text" id="fsvlprocessados" name="fsvlprocessados"/>

        </fieldset>

        <fieldset >
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Total Processados:') ?></legend>

            <label for="totalpro"><?php echo utf8ToHtml('Quantidade:') ?></label>
            <input type="text" id="totalpro" name="totalpro" value="<?php echo $totalpro ?>"/>

            <label for="totalpro"><?php echo utf8ToHtml('Valor:') ?></label>
            <input type="text" id="totalpro" name="totalpro" value="<?php echo formataMoeda($totalvalorpro); ?>"/>

        </fieldset>

    </fieldset>

    <fieldset style="padding:0px; margin:0px; padding-bottom:10px; width: 25%;">
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Integrados:') ?></legend>

        <fieldset>
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Arquivo selecionado:') ?></legend>

            <label for="fsqtintegrados"><? echo utf8ToHtml('Quantidade:') ?></label>
            <input type="text" id="fsqtintegrados" name="fsqtintegrados"/>

            <label for="fsvlintegrados"><? echo utf8ToHtml('Valor:') ?></label>
            <input type="text" id="fsvlintegrados" name="fsvlintegrados"/>

        </fieldset>

        <fieldset >
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Total Integrados:') ?></legend>

            <label for="totalint"><?php echo utf8ToHtml('Quantidade:') ?></label>
            <input type="text" id="totalint" name="totalint" value="<?php echo $totalint ?>"/>

            <label for="totalint"><?php echo utf8ToHtml('Valor:') ?></label>
            <input type="text" id="totalint" name="totalint" value="<?php echo formataMoeda($totalvalorint); ?>"/>

        </fieldset>

    </fieldset>

    <fieldset style="padding:0px; margin:0px; padding-bottom:10px; width: 25%;">
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Agendados:') ?></legend>

        <fieldset>
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Arquivo selecionado:') ?></legend>

        <label for="fsqtagendados"><? echo utf8ToHtml('Quantidade:') ?></label>
        <input type="text" id="fsqtagendados" name="fsqtagendados"/>

        <label for="fsvlagendados"><? echo utf8ToHtml('Valor:') ?></label>
        <input type="text" id="fsvlagendados" name="fsvlagendados"/>

        </fieldset>

        <fieldset >
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Total Agendados:') ?></legend>

        <label for="totalage"><?php echo utf8ToHtml('Quantidade:') ?></label>
        <input type="text" id="totalage" name="totalage" value="<?php echo $totalage ?>"/>

        <label for="totalage"><?php echo utf8ToHtml('Valor:') ?></label>
        <input type="text" id="totalage" name="totalage" value="<?php echo formataMoeda($totalvalorage); ?>"/>

        </fieldset>

    </fieldset>

    <fieldset style="padding:0px; margin:0px; padding-bottom:10px; width: 25%;">
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Erros:') ?></legend>

        <fieldset>
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Arquivo selecionado:') ?></legend>

        <label for="fsqterros"><? echo utf8ToHtml('Quantidade:') ?></label>
        <input type="text" id="fsqterros" name="fsqterros"/>

        <label for="fsvlerros"><? echo utf8ToHtml('Valor:') ?></label>
        <input type="text" id="fsvlerros" name="fsvlerros"/>

        </fieldset>

        <fieldset >
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Total Erros:') ?></legend>

        <label for="totalerr"><?php echo utf8ToHtml('Quantidade:') ?></label>
        <input type="text" id="totalerr" name="totalerr" value="<?php echo $totalerr ?>"/>

        <label for="totalerr"><?php echo utf8ToHtml('Valor:') ?></label>
        <input type="text" id="totalerr" name="totalerr" value="<?php echo formataMoeda($totalvalorerr); ?>"/>

        </fieldset>

    </fieldset>

</div>

<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        buscaArquivos(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        buscaArquivos(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>
