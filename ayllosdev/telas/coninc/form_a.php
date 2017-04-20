<?php
/*!
 * FONTE        	: form_a.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Novembro/2016
 * OBJETIVO     	: Form da opcao A
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */

$btn_nome = 'Concluir';
$btn_func = 'confirmaOperacao()';
 
if ($dsoperac == 'C') { // Consultar
    $btn_nome = '';
    $btn_func = '';
}
?>

<form id="frmOpcaoA" name="frmOpcaoA" class="formulario">
    
    <br />
    <?php
        // Se for uma Inclusao
        if ($dsoperac == 'I') {
            ?>
            <fieldset id="fsetDados" name="fsetDados" style="padding:10px;">
            <legend> Departamento </legend>
                <table width="600" cellpadding="10" cellspacing="2">
                <tr><td>
                    <select id="cddepart" name="cddepart">
                        <option value="">Selecione</option>
                        <?php
                            foreach ($xmlDeptos as $r) {
                                ?><option value="<?php echo getByTagName($r->tags,'CDDEPART'); ?>"><?php echo getByTagName($r->tags,'DSDEPART'); ?></option><?php
                            }
                        ?>
                    </select>
                </td></tr>
                </table>
            </fieldset>
            <?php
        } else {
            ?>
            <div id="divAcesso" class="divRegistros">
                <table width="100%">
                    <thead>
                        <tr>
                            <?php
                                if ($dsoperac == 'E') {
                                    ?>
                                    <th>&nbsp;</th>
                                    <?php
                                }
                            ?>
                            <th>Cooperativa</th>
                            <th>Departamento</th>
                        </tr>
                    </thead>
                    <tbody>
                    <?php
                        foreach( $xmlRegist as $r ) {
                            ?>
                            <tr>
                                <?php
                                    if ($dsoperac == 'E') {
                                        ?>
                                        <td>
                                            <span><?php echo getByTagName($r->tags,'NMRESCOP'); ?></span>
                                            <input type="checkbox" id="<?php echo getByTagName($r->tags,'CDCOOPER'); ?>_<?php echo $iddgrupo; ?>_<?php echo getByTagName($r->tags,'CDDEPART'); ?>" />
                                        </td>
                                        <?php
                                    }
                                ?>
                                <td><?php echo getByTagName($r->tags,'NMRESCOP'); ?></td>
                                <td><?php echo getByTagName($r->tags,'DSDEPART'); ?></td>
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
        // Se for uma Inclusao
        if ($dsoperac == 'I') {
            ?>
            formataFormAcesso();
            <?php
        } else {
            ?>
            formataGridAcesso();

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
    trocaBotao('<?php echo $btn_nome; ?>','<?php echo $btn_func; ?>','btnVoltar()');
</script>