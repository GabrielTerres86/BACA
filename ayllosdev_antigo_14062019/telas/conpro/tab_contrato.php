<?php
/* !
 * FONTE        : tab_contrato.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/03/2015
 * OBJETIVO     : Tabela que apresenta os contrato
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>
<div id="divContrato">
    <div class="divRegistros">	
        <table>
            <thead>
                <tr>
                    <th><?php echo utf8ToHtml('Contrato'); ?></th>
                    <th><?php echo utf8ToHtml('Data'); ?></th>
                    <th><?php echo utf8ToHtml('Emprestado'); ?></th>
                    <th><?php echo utf8ToHtml('Parcelas'); ?></th>
                    <th><?php echo utf8ToHtml('Prestação'); ?></th>
                    <th><?php echo utf8ToHtml('LC'); ?></th>
                    <th><?php echo utf8ToHtml('Fin'); ?></th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($registros as $r) { ?>
                    <tr>
                        <td><span><?php echo getByTagName($r->tags, 'nrctremp') ?></span>
                            <?php echo mascara(getByTagName($r->tags, 'nrctremp'), '#.###.###.###') ?>
                            <input type="hidden" id="nrctremp" name="nrctremp" value="<? echo mascara(getByTagName($r->tags,'nrctremp'),'#.###.###.###') ?>" />								  

                        </td>
                        <td><span><?php echo dataParaTimestamp(getByTagName($r->tags, 'dtmvtolt')) ?></span>
                            <?php echo getByTagName($r->tags, 'dtmvtolt') ?>
                        </td>
                        <td><span><?php echo converteFloat(getByTagName($r->tags, 'vlemprst'), 'MOEDA') ?></span>
                            <?php echo formataMoeda(getByTagName($r->tags, 'vlemprst')) ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'qtpreemp') ?></span>
                            <?php echo getByTagName($r->tags, 'qtpreemp') ?>
                        </td>
                        <td><span><?php echo converteFloat(getByTagName($r->tags, 'vlpreemp'), 'MOEDA') ?></span>
                            <?php echo formataMoeda(getByTagName($r->tags, 'vlpreemp')) ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'cdlcremp') ?></span>
                            <?php echo getByTagName($r->tags, 'cdlcremp') ?>
                        </td>
                        <td><span><?php echo getByTagName($r->tags, 'cdfinemp') ?></span>
                            <?php echo getByTagName($r->tags, 'cdfinemp') ?>
                        </td>
                    </tr>
                <?php } ?>	
            </tbody>
        </table>
    </div>	
</div>