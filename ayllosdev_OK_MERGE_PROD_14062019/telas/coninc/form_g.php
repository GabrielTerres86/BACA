<?php
/*!
 * FONTE        	: form_g.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Novembro/2016
 * OBJETIVO     	: Form da opcao G
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */

switch ($dsoperac) {

    case 'A': // Alterar
        if ($iddgrupo > 0) {
            $xmlRegis = $xmlObject->roottag->tags[0]->tags[0];
            $nmdgrupo = getByTagName($xmlRegis->tags,'NMINCONSIST_GRP');
            $indconte = getByTagName($xmlRegis->tags,'TPCONFIG_EMAIL');
            $dsassunt = getByTagName($xmlRegis->tags,'DSASSUNTO_EMAIL');
            $indperio = getByTagName($xmlRegis->tags,'TPPERIODICIDADE_EMAIL');
        }

        $btn_nome = 'Alterar';
        $btn_func = 'carregaAlteracao()';
        break;

    case 'E': // Excluir
        $btn_nome = 'Excluir';
        $btn_func = 'confirmaOperacao()';
        break;

    default: // Consultar
        $btn_nome = '';
        $btn_func = '';

}
?>

<form id="frmOpcaoG" name="frmOpcaoG" class="formulario">
    
    <br />
    <?php
        // Se for uma Inclusao ou Alteracao com Codigo
        if ($dsoperac == 'I' || ($dsoperac == 'A' && $iddgrupo > 0)) {
            $btn_nome = 'Concluir';
            $btn_func = 'confirmaOperacao()';
            ?>
            <fieldset id="fsetDados" name="fsetDados" style="padding:10px;">
            <legend> Dados Cadastrais </legend>
                <table width="600" cellpadding="10" cellspacing="2">
                <?php
                    // Se for alteracao
                    if ($dsoperac == 'A') {
                        ?>
                        <tr>
                            <td align="right">C&oacute;digo</td>
                            <td><input type="text" name="iddgrup2" id="iddgrup2" value="<?php echo $iddgrupo; ?>" /></td>
                        </tr>
                        <?php
                    }
                ?>
                <tr>
                    <td align="right">Descri&ccedil;&atilde;o</td>
                    <td><input type="text" name="nmdgrupo" id="nmdgrupo" value="<?php echo $nmdgrupo; ?>" /></td>
                </tr>
                <tr>
                    <td align="right">Conte&uacute;do do E-mail</td>
                    <td>
                        <select id="indconte" name="indconte">
                            <option value="0"<?php echo ($indconte == 0 ? ' selected="selected"' : ''); ?>> N&atilde;o enviar e-mail</option> 
                            <option value="1"<?php echo ($indconte == 1 ? ' selected="selected"' : ''); ?>> Somente Erros</option>
                            <option value="2"<?php echo ($indconte == 2 ? ' selected="selected"' : ''); ?>> Erros e Alertas</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td align="right">T&iacute;tulo do E-mail</td>
                    <td><input type="text" name="dsassunt" id="dsassunt" value="<?php echo $dsassunt; ?>" /></td>
                </tr>
                <tr>
                    <td align="right">Periodicidade do E-mail</td>
                    <td>
                        <select id="indperio" name="indperio">
                            <option value="1"<?php echo ($indperio == 1 ? ' selected="selected"' : ''); ?>> Online</option>
                            <option value="2"<?php echo ($indperio == 2 ? ' selected="selected"' : ''); ?>> Di&aacute;rio</option>
                        </select>
                    </td>
                </tr>
                </table>
            </fieldset>
            <?php
        } else {
            ?>
            <div id="divGrupo" class="divRegistros">
                <table width="100%">
                    <thead>
                        <tr>
                            <th>C&oacute;digo</th>
                            <th>Descri&ccedil;&atilde;o</th>
                            <th>Conte&uacute;do do E-mail</th>
                            <th>Periodicidade</th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php
                        foreach( $xmlRegist as $r ) {
                            ?>
                            <tr>
                                <td><?php echo getByTagName($r->tags,'IDINCONSIST_GRP'); ?></td>
                                <td>
                                    <?php echo getByTagName($r->tags,'NMINCONSIST_GRP'); ?>
                                    <input type="hidden" id="hd_iddgrupo" value="<?php echo getByTagName($r->tags,'IDINCONSIST_GRP'); ?>" />
                                </td>
                                <td><?php echo getByTagName($r->tags,'DSCONTEUDO'); ?></td>
                                <td><?php echo getByTagName($r->tags,'DSPERIODICIDADE'); ?></td>
                            </tr>
                            <?php
                        }
                    ?>
                    </tbody>
                </table>
            </div>
            <div id="divRegistrosRodape" class="divRegistrosRodape">
                <table>	
                    <tr>
                        <td>
                            <? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
                            <? if ($nriniseq > 1){ ?>
                                   <a class="paginacaoAnt"><<< Anterior</a>
                            <? }else{ ?>
                                    &nbsp;
                            <? } ?>
                        </td>
                        <td>
                            <? if (isset($nriniseq)) { ?>
                                   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
                            <? } ?>
                            
                        </td>
                        <td>
                            <? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
                                  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
                            <? }else{ ?>
                                    &nbsp;
                            <? } ?>
                        </td>
                    </tr>
                </table>
            </div>
            <?php
        }
    ?>

	<br style="clear:both" />
	
</form>

<script type="text/javascript">
    <?php
        // Funcao para voltar
        $btn_back = 'btnVoltar()';
        
        // Se for uma Inclusao ou Alteracao com Codigo
        if ($dsoperac == 'I' || ($dsoperac == 'A' && $iddgrupo > 0)) {
            if ($dsoperac == 'A') {
                $btn_back = 'btnVoltarOpcaoG()';
            }
            ?>
            formataFormGrupo();
            <?php
        } else {
            ?>
            formataGridGrupo();

            $('a.paginacaoAnt').unbind('click').bind('click', function() {
                controlaOperacao(<?php echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);				
            });
            $('a.paginacaoProx').unbind('click').bind('click', function() {
                controlaOperacao(<?php echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);	
            });	

            $('#divRegistrosRodape').formataRodapePesquisa();
            <?php
        }
    ?>
    trocaBotao('<?php echo $btn_nome; ?>','<?php echo $btn_func; ?>','<?php echo $btn_back; ?>');
</script>