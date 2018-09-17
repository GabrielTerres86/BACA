<?php
/* !
 * FONTE        : tab_consulta.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 14/07/2014
 * OBJETIVO     : Tabela de Produtos - tela PCAPTA
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>
<form action="" method="post" id="frmTaxas" name="frmTaxas">
    <div id="tabIndice">
        <div class="divRegistros">
            <table class="tituloRegistros">
                <thead>
                    <tr>
                        <th><?php echo utf8ToHtml('Produto'); ?></th>
                        <th><?php echo utf8ToHtml('Tot.Apl.Dia'); ?></th>
                        <th><?php echo utf8ToHtml('Tot.Res.Dia'); ?></th>
                        <th><?php echo utf8ToHtml('Saldo Aplic.'); ?></th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($registros as $registro) { ?>
                        <tr id="<?php echo($registro->tags[0]->cdata); ?>">
                            <td>
                                <?php echo($registro->tags[0]->cdata); ?>
                            </td>
                            <td>
                                <span><?php echo($registro->tags[1]->cdata); ?></span>
                                <?php echo($registro->tags[1]->cdata); ?>
                            </td>
                            <td>
                                <span><?php echo($registro->tags[2]->cdata); ?></span>
                                <?php echo($registro->tags[2]->cdata); ?>
                            </td>
                            <td>
                                <span><?php echo($registro->tags[3]->cdata); ?></span>
                                <?php echo($registro->tags[3]->cdata); ?>
                            </td>
                        </tr>
                    <?php } ?>
                </tbody>
            </table>
        </div>
    </div>
    <div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>	
            <tr>
                <td>
                    <?php
                    if (isset($qtdregist) and $qtdregist == 0) {
                        $nriniseq = 0;
                    }

                    // Se a paginação não está na primeira, exibe botão voltar
                    if ($nriniseq > 1) {
                        ?> 
                        <a class='paginacaoAnt'><<< Anterior</a> 
                    <?php } else { ?> 
                        &nbsp;  
                    <?php } ?>
                </td>
                <td>
                    <?php if (isset($nriniseq)) { ?> 
                        Exibindo <?php echo $nriniseq; ?> 
                        at&eacute; 
                        <?php
                        if (($nriniseq + $nrregist) > $qtdregist) {
                            echo $qtdregist;
                        } else {
                            echo ($nriniseq + $nrregist - 1);
                        }
                        ?> 
                        de <?php
                        echo $qtdregist;
                    }
                    ?>
                </td>
                <td>
                    <?php
                    // Se a paginação não está na &uacute;ltima página, exibe botão proximo
                    if ($qtdregist > ($nriniseq + $nrregist - 1)) {
                        ?> 
                        <a class='paginacaoProx'>Pr&oacute;ximo >>></a> 
                    <?php } else { ?> 
                        &nbsp; 
                    <?php } ?>			
                </td>
            </tr>
        </table>
    </div>

    <div id="divBotoes">
        <a href="#" class="botao" id="btVoltar" onclick="fnVoltar();return false;" ><?php echo utf8ToHtml('Voltar'); ?></a>
    </div>
</form>
<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        listaMovimentacaoCarteira(<?php echo "'" . ($nriniseq - $nrregist) . "'"; ?>, <?php echo "'" . $nrregist . "'"; ?>);
    });
    $('a.paginacaoProx').unbind('click').bind('click', function() {
        listaMovimentacaoCarteira(<?php echo "'" . ($nriniseq + $nrregist) . "'"; ?>, <?php echo "'" . $nrregist . "'"; ?>);
    });

    $('#divPesquisaRodape').formataRodapePesquisa();

</script>