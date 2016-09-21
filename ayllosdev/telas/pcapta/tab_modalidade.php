<?php
/* !
 * FONTE        : tab_modalidade.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 05/08/2014
 * OBJETIVO     : Tabela de Modalidades - tela PCAPTA
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
    <div class="tabModalidade">
        <div class="divRegistros">
            <table class="tituloRegistros"> 
                <thead>
                    <tr>
                        <?php if ($subopcao == 'E') { ?>
                            <th align="left">
                                <input type="checkbox" name="chkTodos" onclick="checaTodos($(this))"  id="chkTodos" value="" />
                            </th>
                        <?php } ?>    
                        <th align="left"><?php echo utf8ToHtml('Car&ecirc;ncia'); ?></th>
                        <th align="left"><?php echo utf8ToHtml('Prazo'); ?></th>
                        <th align="left"><?php echo utf8ToHtml('Valor Inicial da Faixa'); ?></th>
                        <th align="left"><?php echo ( $idtxfixa == 1 ) ? utf8ToHtml('% Taxa Fixa') : utf8ToHtml('% Rentabilidade'); ?></th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($registros as $registro) { ?>
                        <?php if ( $registro->tags[0]->cdata > 0 ) { ?>
                            <tr id="<?php echo($registro->tags[0]->cdata); ?>">
                                <?php if ($subopcao == 'E') { ?>
                                    <td>
                                        <input class="cdmodali" type="checkbox" name="<?php echo($registro->tags[0]->cdata); ?>" id="<?php echo($registro->tags[0]->cdata); ?>" value="" />
                                    </td>
                                <?php } ?>

                                <td>
                                    <?php echo($registro->tags[2]->cdata); ?>
                                </td>
                                <td>
                                    <?php echo($registro->tags[3]->cdata); ?>
                                </td>
                                <td>
                                    <?php 
                                        echo $registro->tags[4]->cdata; 
                                    ?>
                                </td>
                                <td>
                                    <?php 
                                        echo($idtxfixa == 1) ? $registro->tags[6]->cdata : $registro->tags[5]->cdata; 
                                    ?>
                                </td>
                            </tr>
                        <?php } ?>
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
                    <td id="nrRegistrosTabela">
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
                    <?php }
                    ?>			
                </td>
            </tr>
        </table>
    </div>

    <div id="divBotoes">
        <a href="javascript:void(0);" class="botao" id="btVoltar" onclick="resetaCampos();" ><?php echo utf8ToHtml('Voltar'); ?></a>
        <?php if ($subopcao == 'E' && $qtdregist > 0) { ?>
            <a href="javascript:void(0);" class="botao" id="btProseguir" onclick="validaExclusaoModalidade();" ><?php echo utf8ToHtml('Prosseguir'); ?></a>
        <?php } ?>
    </div>

</form>
<script type="text/javascript">
    $(function() {
        
        var obj = <?php echo ($subopcao == 'E') ? '$("#modalidadesProdExcluir #btProseg")': '$("#modalidadesProdConsult #btProseg")'; ?>;
        
        $('a.paginacaoAnt').unbind('click').bind('click', function() {
            consultaModalidade(<?php echo "'" . ($nriniseq - $nrregist) . "'"; ?>, <?php echo "'" . $nrregist . "'"; ?>, <?php echo "'".$subopcao."'"; ?>);
        });
        $('a.paginacaoProx').unbind('click').bind('click', function() {
            consultaModalidade(<?php echo "'" . ($nriniseq + $nrregist) . "'"; ?>, <?php echo "'" . $nrregist . "'"; ?>, <?php echo "'".$subopcao."'"; ?>);
        });

        $('.divPesquisaRodape').formataRodapePesquisa();
    });
    
    function checaTodos(obj)
    {
        if ( $(obj).is(':checked') ) {
            
            $("#frmTaxas .tabModalidade .tituloRegistros tr input.cdmodali").each( function() {
                $(this).attr('checked','checked');
            });
            
        } else {
            $("#frmTaxas .tabModalidade .tituloRegistros tr input.cdmodali").each( function() {
                $(this).removeAttr('checked');
            });            
        }
    }
</script>