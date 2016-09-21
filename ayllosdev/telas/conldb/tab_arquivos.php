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
                    <th><?php echo utf8ToHtml('Arquivo') ?></th>
                    <th><?php echo utf8ToHtml('Data') ?></th>
                    <th><?php echo utf8ToHtml('Hora') ?></th>
                    <th><?php echo utf8ToHtml('Processados') ?></th>
                    <th><?php echo utf8ToHtml('Pendentes') ?></th>
                    <th><?php echo utf8ToHtml('Erros') ?></th>
                </tr>
            </thead>

            <?php
            foreach ($registros as $r) {
                ?>
                <tr>
                    <td><?php echo getByTagName($r->tags, 'nmarquivo') ?>
                    <input type="hidden" id="nmarquivo" name="nmarquivo" value="<?php echo getByTagName($r->tags,'nmarquivo') ?>" />
                    </td>
                    <td><?php echo getByTagName($r->tags, 'dtinclusao') ?></td>
                    <td><?php echo getByTagName($r->tags, 'hrinclusao') ?></td> 
                    <td><?php echo getByTagName($r->tags, 'qtprocessados') ?></td>
                    <td><?php echo getByTagName($r->tags, 'qtpendentes') ?></td>
                    <td><?php echo getByTagName($r->tags, 'qterros') ?></td>
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

<div id="divTotaisArquivo" style="margin-bottom: 15px; text-align:center; margin-top: 15px;"> 
    
    <label for="totalpro"><?php echo utf8ToHtml('Total Processados:') ?></label>
    <input type="text" id="totalpro" name="totalpro" value="<?php echo $totalpro ?>"/>

    <label for="totalpen"><?php echo utf8ToHtml('Total Pendentes:') ?></label>
    <input type="text" id="totalpen" name="totalpen" value="<?php echo $totalpen ?>"/>

    <label for="totalerr"><?php echo utf8ToHtml('Total Erros:') ?></label>
    <input type="text" id="totalerr" name="totalerr" value="<?php echo $totalerr ?>"/>

</div>

<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        buscaArquivos(<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        buscaArquivos(<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>