<?php 
/*
 * FONTE        : tab_titulos.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 23/05/2018
 * OBJETIVO     : Tabela que apresenta a consulta de titulos
 * --------------
 */
$vlpagar = 0;
?>
    <br style="clear:both" />
    <div class="">
        <table class="tituloRegistros divRegistros" style="margin-bottom:20px;">
            <thead>
                <tr>
                    <th>                        
                        <input type="checkbox" id="checkTodos" name="checkTodos" onclick="checkTodos()"  > 
                    </th>               
                    <th>N&#176; Boleto</th>
                    <th>Data de Vencimento</th>
                    <th>Valor do T&iacute;tulo</th>
                    <th>Valor Pago</th>
                    <th>Multa</th>
                    <th>Juros de Mora</th>
                    <th>IOF Atraso</th>
                    <th>Valor Atual</th>
                    <th>Valor a Pagar</th>
                    <th>Valor</th>
                </tr>           
            </thead>
            <tbody>
                <?php foreach($dados->find("inf") as $t) {
                    $vlpagar += $t->vlpagar->cdata;
                    ?>
                    <tr class="linTitulo" style="text-align:center;">
                        <td id="tr_<?=$t->nrtitulo?>">
                            <input class="pagarTitulo" type="checkbox" value="<?=$t->nrtitulo?>" onchange="changeCheckbox(this)" name="nrtitulo_selecionado"/>
                            <input type="hidden" name="vlpagartotal" value="<?=formataMoeda($t->vlpagar)?>"/>
                            <input type="hidden" name="nrtitulo[]" value="<?=$t->nrtitulo?>"/>
                        </td>
                        <td><?=$t->nrdocmto?></td>
                        <td><?=$t->dtvencto?></td>
                        <td><?=formataMoeda($t->vltitulo)?></td>
                        <td><?=formataMoeda($t->vlpago)?></td>
                        <td><?=formataMoeda($t->vlmulta)?></td>
                        <td><?=formataMoeda($t->vlmora)?></td>
                        <td><?=formataMoeda($t->vliof)?></td>
                        <td><?=formataMoeda($t->vlsldtit)?></td>
                        <td><?=formataMoeda($t->vlpagar)?></td>
                        <td><input type="text" style="width:100px" class="vlpagar monetario campoTelaSemBorda" value="<?=formataMoeda(0)?>" id="vlpagar_<?=$t->nrtitulo?>" name="vlpagar[<?=$t->nrtitulo?>]" readonly/></td>
                    </tr>
                <?php } ?>
            </tbody>
        </table>
    </div>
    <div>
        Exibindo <?=$dados->getAttribute("QTREGIST");?> registros
    </div>

    <div id="divVlTit " align="left" >
        <form id="frmVlTit" name="frmVlTit" >
            <div style="float:right;text-align:right;margin-right:10px;">
                <label for="totpagto" style="margin-left:25px">Total a Pagar:</label><input type="text" id="totpagto" name="totpagto" value="0,00" class="campoTelaSemBorda" style="text-align: right;"/></br>
                <label for="totatras" style="margin-left:25px">Total Atraso:</label><input type="text" id="totatras" name="totatras" class="campoTelaSemBorda" value="<?=formataMoeda($vlpagar)?>" style="text-align: right;"/></br>
            </div>
        </form>
    </div>
    <div id="divBotoes" style="margin-bottom: 15px; text-align:center;">
        <a href="#" class="botao" id="btVoltar"     onClick="<?php echo 'voltarTitulos(); '; ?> return false;">Voltar</a>
        <a href="#" class="botao" id="btGerar"      onClick="finalizarBoleto(); return false;">Gerar Boleto</a>
    </div>