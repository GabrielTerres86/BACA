<? 
/*!
 * FONTE        : tab_movcmpnr.php
 * CRIAÇÃO      : Jackson Barcellos AMcom
 * DATA CRIAÇÃO : 06/2019
 * OBJETIVO     : P565
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
$tqtenviad = 0;
$tvlenviad = 0;
$tqtproces = 0;
$tvlproces = 0;
?>

	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>Coop.</th>
					<th>PA</th>
					<th>Tp. Arq.</th>
					<th>Data</th>
					<th>Qtd. Env.</th>
                    <th>Valor Env.</th>
                    <th>Qtd. Proc.</th>
                    <th>Valor Proc.</th>
				</tr>			
			</thead>
			<tbody>
                <? if ($tparquivo > 0){
                    foreach( $registros as $item ) { 
                       $tqtenviad = $tqtenviad + getByTagName($item->tags,'qtenviad');
                       $tvlenviad = $tvlenviad + getByTagName($item->tags,'vlenviad');
                       $tqtproces = $tqtproces + getByTagName($item->tags,'qtproces');
                       $tvlproces = $tvlproces + getByTagName($item->tags,'vlproces');
                    }
                }?>

				<? foreach( $registros as $item ) { 
                    if ($tparquivo == 0){
                        $tqtenviad = getByTagName($item->tags,'qtenviad');
                        $tvlenviad = getByTagName($item->tags,'vlenviad');
                        $tqtproces = getByTagName($item->tags,'qtproces');
                        $tvlproces = getByTagName($item->tags,'vlproces'); 
                    }?>

					<tr title="<? echo getByTagName($item->tags,'insituac') ?>">                        
						<td><? echo getByTagName($item->tags,'nmrescop'); ?></td>
						<td><? echo getByTagName($item->tags,'cdagenci'); ?></td>
						<td><? echo getByTagName($item->tags,'dsarquiv'); ?></td>
						<td><? echo date('d/m/Y',strtotime(getByTagName($item->tags,'dtarquiv'))); ?></td>
                        <td><? echo getByTagName($item->tags,'qtenviad'); ?></td>
                        <td><? echo number_format(str_replace(",",".",getByTagName($item->tags,'vlenviad')),2,",","."); ?></td>                        
                        <td><? echo getByTagName($item->tags,'qtproces'); ?></td>
                        <td><? echo number_format(str_replace(",",".",getByTagName($item->tags,'vlproces')),2,",","."); ?></td>
                        <input type="hidden" id="cdcooper" name="cdcooper" value="<? echo getByTagName($item->tags,'cdcooper') ?>" />
                        <input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($item->tags,'cdagenci') ?>" />
                        <input type="hidden" id="tparquiv" name="dsarquiv" value="<? echo getByTagName($item->tags,'tparquiv') ?>" />
                        <input type="hidden" id="dtarquiv" name="dtarquiv" value="<? echo getByTagName($item->tags,'dtarquiv') ?>" />
                        <input type="hidden" id="qtenviad" name="qtenviad" value="<? echo $tqtenviad ?>" />
                        <input type="hidden" id="vlenviad" name="vlenviad" value="<? echo $tvlenviad ?>" />
                        <input type="hidden" id="qtproces" name="qtproces" value="<? echo $tqtproces ?>" />
                        <input type="hidden" id="vlproces" name="vlproces" value="<? echo $tvlproces ?>" />
                        <input type="hidden" id="insituac" name="insituac" value="<? echo getByTagName($item->tags,'insituac') ?>" />
                        <input type="hidden" id="nmarquiv" name="nmarquiv" value="<? echo getByTagName($item->tags,'nmarquiv') ?>" />   
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
<form id="frmMovnr" name="frmMovnr" class="formulario">
        <div id="divMovnr" style="border-bottom: 1px solid; border-top: 1px solid;">

            <label for="nmarquiv"><? echo utf8ToHtml('Arquivo:') ?></label>
            <input id="nmarquiv" name="nmarquiv" type="text"/>
            
            <label for="insituac"><? echo utf8ToHtml('Situação:') ?></label>
            <input id="insituac" name="insituac" type="text"/>

            <br style="clear:both" />
            
            <label for="totais"><? echo utf8ToHtml('Totalizadores') ?></label>
            
            <br style="clear:both" />
            <div style="border: 1px solid; width: 98%; margin-left: 5px">
                
            
            </div>
            <br style="clear:both" />

            <label for="qtenviad"><? echo utf8ToHtml('Qtd. Enviada:') ?></label>
            <input id="qtenviad" name="qtenviad" type="text"/>
            
            <label for="vlenviad"><? echo utf8ToHtml('Valor Enviado:') ?></label>
            <input id="vlenviad" name="vlenviad" type="text"/>
           
            <br style="clear:both" />   
                    
            <label for="qtproces"><? echo utf8ToHtml('Qtd. Processada:') ?></label>
            <input id="qtproces" name="qtproces" type="text"/>  
            
            <label for="vlproces"><? echo utf8ToHtml('Valor Processado:') ?></label>
            <input id="vlproces" name="vlproces" type="text"/>
            
            <br style="clear:both" />
        </div>
    </form>
    </fieldset>
</form>

<script type="text/javascript">

    $('a.paginacaoAnterior').unbind('click').bind('click', function() {
        controlaOperacao('CX',<?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProximo').unbind('click').bind('click', function() {
        controlaOperacao('CX',<?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
</script>

	<div id="divBotoes">
		<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="btnVoltar();"   />			
	</div>
