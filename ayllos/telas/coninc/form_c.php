<?php
/*!
 * FONTE        	: form_c.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Novembro/2016
 * OBJETIVO     	: Form da opcao C
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>

<form id="frmOpcaoC" name="frmOpcaoC" class="formulario">
    
    <br />

	<div id="divInconsistencia" class="divRegistros">
        <table width="100%">
            <thead>
                <tr>
                    <th>Cooperativa</th>
                    <th>Tipo</th>
                    <th>Data/Hora</th>
                    <th>Inconsist&ecirc;ncia</th>
                    <th>Registro de Refer&ecirc;ncia</th>
                </tr>
            </thead>
            <tbody>
            <?php
                foreach( $xmlRegist as $r ) {
                    ?>
                    <tr>
                        <td><?php echo getByTagName($r->tags,'NMRESCOP'); ?></td>
                        <td><?php echo getByTagName($r->tags,'DSTIPINC'); ?></td>
                        <td><?php echo getByTagName($r->tags,'DHINCONS'); ?></td>
                        <td><?php echo getByTagName($r->tags,'DSINCONS'); ?></td>
                        <td><?php echo getByTagName($r->tags,'DSREGIST'); ?></td>
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

	<br style="clear:both" />
    
    <table width="100%" cellspacing="1">
    <tr style="background-color:#F7D3CE;">
        <td width="50%" style="padding:3px; text-align:center; font-weight:bold;">Total de Erros</td>
        <td width="50%" style="padding:3px; text-align:center; font-weight:bold;">Total de Avisos</td>
    </tr>
    <tr style="background-color:#EFEBEF;">
        <td style="padding:3px; text-align:center;"><?php echo $qtderros; ?></td>
        <td style="padding:3px; text-align:center;"><?php echo $qtavisos; ?></td>
    </tr>
    </table>
	
</form>

<script type="text/javascript">
    formataGridInconsistencia();
    trocaBotao('Exportar','exportaInconsistencia()','btnVoltar()');

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        controlaOperacao(<?php echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);				
    });
    $('a.paginacaoProx').unbind('click').bind('click', function() {
        controlaOperacao(<?php echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);	
    });	

    $('#divRegistrosRodape').formataRodapePesquisa();
</script>