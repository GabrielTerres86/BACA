<? 
/*!
 * FONTE        : tab_movcmpsr.php
 * CRIAÇÃO      : Jackson Barcellos AMcom
 * DATA CRIAÇÃO : 06/2019
 * OBJETIVO     : P565
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
$tqtrecebd = 0;
$tvlrecebd = 0;
$tqtintegr = 0;
$tvlintegr = 0;
$tqtrejeit = 0;
$tvlrejeit = 0;
?>

	<div class="divRegistros">
		<table class="tituloRegistros" >
			<thead >
                <tr>
                    <th>Coop.</th>
                    <th>Tp. Arq.</th>
                    <th>Data</th>
                    <th>Qtd. Rec.</th>
                    <th>Valor Rec.</th>
                    <th>Qtd. Int.</th>
                    <th>Valor Int.</th>
                    <th>Qtd. Rej.</th>
                    <th>Valor Rej.</th>
                </tr>           
            </thead>
            <tbody>
                 <? if ($tparquivo > 0){
                    foreach( $registros as $item ) { 
                       $tqtrecebd = $tqtrecebd + getByTagName($item->tags,'qtrecebd');
                       $tvlrecebd = $tvlrecebd + getByTagName($item->tags,'vlrecebd');
                       $tqtintegr = $tqtintegr + getByTagName($item->tags,'qtintegr');
                       $tvlintegr = $tvlintegr + getByTagName($item->tags,'vlintegr');
                       $tqtrejeit = $tqtrejeit + getByTagName($item->tags,'qtrejeit');
                       $tvlrejeit = $tvlrejeit + getByTagName($item->tags,'vlrejeit');
                    }
                }?>
                <? foreach( $registros as $item ) { 
                    if ($tparquivo == 0){
                       $tqtrecebd = getByTagName($item->tags,'qtrecebd');
                       $tvlrecebd = getByTagName($item->tags,'vlrecebd');
                       $tqtintegr = getByTagName($item->tags,'qtintegr');
                       $tvlintegr = getByTagName($item->tags,'vlintegr');
                       $tqtrejeit = getByTagName($item->tags,'qtrejeit');
                       $tvlrejeit = getByTagName($item->tags,'vlrejeit');
                    }?>
                    <tr >
                        <td><? echo getByTagName($item->tags,'nmrescop'); ?></td>
                        <td><? echo getByTagName($item->tags,'dsarquiv'); ?></td>
                        <td><? echo date('d/m/Y',strtotime(getByTagName($item->tags,'dtarquiv'))); ?></td>
                        <td><? echo getByTagName($item->tags,'qtrecebd'); ?></td>
                        <td><? echo number_format(str_replace(",",".",getByTagName($item->tags,'vlrecebd')),2,",","."); ?></td>
                        <td><? echo getByTagName($item->tags,'qtintegr'); ?></td>
                        <td><? echo number_format(str_replace(",",".",getByTagName($item->tags,'vlintegr')),2,",","."); ?></td>
                        <td><? echo getByTagName($item->tags,'qtrejeit'); ?></td>
                        <td><? echo number_format(str_replace(",",".",getByTagName($item->tags,'vlrejeit')),2,",","."); ?></td>
                        <input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($item->tags,'cdcooper') ?>" />
                        <input type="hidden" id="tparquiv" name="tparquiv" value="<? echo getByTagName($item->tags,'tparquiv') ?>" />
                        <input type="hidden" id="dtarquiv" name="dtarquiv" value="<? echo getByTagName($item->tags,'dtarquiv') ?>" />
                        <input type="hidden" id="qtrecebd" name="qtrecebd" value="<? echo $tqtrecebd ?>" />
                        <input type="hidden" id="vlrecebd" name="vlrecebd" value="<? echo $tvlrecebd ?>" />
                        <input type="hidden" id="qtintegr" name="qtintegr" value="<? echo $tqtintegr ?>" />
                        <input type="hidden" id="vlintegr" name="vlintegr" value="<? echo $tvlintegr ?>" />
                        <input type="hidden" id="qtrejeit" name="qtrejeit" value="<? echo $tqtrejeit ?>" />
                        <input type="hidden" id="vlrejeit" name="vlrejeit" value="<? echo $tvlrejeit ?>" />
                        <input type="hidden" id="nmarqrec" name="nmarqrec" value="<? echo getByTagName($item->tags,'nmarqrec') ?>" />                        
                    </tr>               
                <? } ?>         
            </tbody>
		</table>
	</div> 
	
	
<div id="divPesquisaRodape" class="divPesquisaRodape">
    <table>	
        <tr>
            <td>
                <?php

                if (isset($total) and $total == 0) {
                    $nriniseq = 0;
                }

                // Se a paginacao nao esta na primeira, exibe botao voltar
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
                    if (($nriniseq + $nrregist) > $total) {
                        echo $total;
                    } else {
                        echo ($nriniseq + $nrregist - 1);
                    }
                    ?> de <?php echo $total; ?><?php
                }
                ?>
            </td>
            <td>
                <?php
                // Se a paginacao nao esta na ultima pagina, exibe botao proximo
                if ($total > ($nriniseq + $nrregist - 1)) {
                    ?> <a class='paginacaoProximo'>Pr&oacute;ximo >>></a> <?php
                } else {
                    ?> &nbsp; <?php
                }
                ?>			
            </td>
        </tr>
    </table>
</div>
<br>
<form id="frmMovsr" name="frmMovsr" class="formulario">
        <div id="divMovsr" style="border-bottom: 1px solid; border-top: 1px solid;">

            <label for="nmarqrec"><? echo utf8ToHtml('Arquivo:') ?></label>
            <input id="nmarqrec" name="nmarqrec" type="text"/>

            <br style="clear:both" />
            
            <label for="totais"><? echo utf8ToHtml('Totalizadores') ?></label>
            
            <br style="clear:both" />
            <div style="border: 1px solid; width: 98%; margin-left: 5px">
                
            
            </div>
            <br style="clear:both" />

            <label for="qtrecebd"><? echo utf8ToHtml('Qtd. Recebida:') ?></label>
            <input id="qtrecebd" name="qtrecebd" type="text"/>
            
            <label for="vlrecebd"><? echo utf8ToHtml('Valor Recebido:') ?></label>
            <input id="vlrecebd" name="vlrecebd" type="text"/>
           
            <br style="clear:both" />   
                    
            <label for="qtintegr"><? echo utf8ToHtml('Qtd. Integrado:') ?></label>
            <input id="qtintegr" name="qtintegr" type="text"/>  
            
            <label for="vlintegr"><? echo utf8ToHtml('Valor Integrado:') ?></label>
            <input id="vlintegr" name="vlintegr" type="text"/>
            
            <br style="clear:both" />

            <label for="qtrejeit"><? echo utf8ToHtml('Qtd. Rejeitada:') ?></label>
            <input id="qtrejeit" name="qtrejeit" type="text"/>  
            
            <label for="vlrejeit"><? echo utf8ToHtml('Valor Rejeitado:') ?></label>
            <input id="vlrejeit" name="vlrejeit" type="text"/>
            
            <br style="clear:both" />
        </div>
    </form>
    </fieldset>
</form>

<script type="text/javascript">

    $('a.paginacaoAnterior').unbind('click').bind('click', function() {
        controlaOperacao('C',<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        controlaOperacao('C',<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>

	<div id="divBotoes">
		<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="btnVoltar();"   />			
	</div>
