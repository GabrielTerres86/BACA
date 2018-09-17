<?
/*!
 * FONTE        : tab_contrato.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 22/10/2013
 * OBJETIVO     : Tabela de registros do relatório - Tela RATBND
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?php
     session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<div id="tabContrato">
    <div class="divRegistros">
        <table class="tituloRegistros">
            <thead>
                <tr>
                    <th><? echo utf8ToHtml('PA'); ?></th>
                    <th><? echo utf8ToHtml('Conta/dv');  ?></th>
                    <th><? echo utf8ToHtml('Valor');  ?></th>
                    <th><? echo utf8ToHtml('Contrato');  ?></th>
                    <th><? echo utf8ToHtml('Data');  ?></th>
                </tr>
            </thead>
            <tbody>
                <?
                for ($i = 0; $i < count($contrato); $i++) {
                ?>
                    <tr>
                        <td>
                            <input type="hidden" id="inrisctl" name="inrisctl" value="<? echo getByTagName($contrato[$i]->tags,'inrisctl'); ?>" />
                            <input type="hidden" id="nrnotrat" name="nrnotrat" value="<? echo getByTagName($contrato[$i]->tags,'nrnotrat'); ?>" />
                            <input type="hidden" id="indrisco" name="indrisco" value="<? echo getByTagName($contrato[$i]->tags,'indrisco'); ?>" />
                            <input type="hidden" id="nrnotatl" name="nrnotatl" value="<? echo getByTagName($contrato[$i]->tags,'nrnotatl'); ?>" />
                            <input type="hidden" id="dteftrat" name="dteftrat" value="<? echo getByTagName($contrato[$i]->tags,'dteftrat'); ?>" />
                            <input type="hidden" id="nmoperad" name="nmoperad" value="<? echo getByTagName($contrato[$i]->tags,'nmoperad'); ?>" />
                            <input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($contrato[$i]->tags,'nrdconta'); ?>" />
                            <input type="hidden" id="nrctrato" name="nrctrato" value="<? echo getByTagName($contrato[$i]->tags,'nrctrato'); ?>" />
                            <input type="hidden" id="cdoperad" name="cdoperad" value="<? echo getByTagName($contrato[$i]->tags,'cdoperad'); ?>" />
                            <input type="hidden" id="tpctrato" name="tpctrato" value="<? echo getByTagName($contrato[$i]->tags,'tpctrato'); ?>" />
                            <span><? echo getByTagName($contrato[$i]->tags,'cdagenci'); ?></span>
                                  <? echo getByTagName($contrato[$i]->tags,'cdagenci'); ?>
                        </td>
                        <td><span><? echo getByTagName($contrato[$i]->tags,'nrdconta'); ?></span>
                                  <? echo getByTagName($contrato[$i]->tags,'nrdconta'); ?>
                        </td>
                        <td><span><? echo getByTagName($contrato[$i]->tags,'vlctrbnd'); ?></span>
                                  <? echo formataMoeda(getByTagName($contrato[$i]->tags,'vlctrbnd')); ?>
                        </td>
                        <td><span><? echo getByTagName($contrato[$i]->tags,'nrctrato'); ?></span>
                                  <? echo getByTagName($contrato[$i]->tags,'nrctrato'); ?>
                        </td>
                        <td><span><? echo getByTagName($contrato[$i]->tags,'dtmvtolt'); ?></span>
                                  <? echo getByTagName($contrato[$i]->tags,'dtmvtolt'); ?>
                        </td>
                    </tr>
                <? } ?>
            </tbody>
        </table>
    </div>
</div>
<div id="linha1">
    <ul class="complemento">
        <li><? echo utf8ToHtml('Risco Coop.:'); ?></li>
        <li id="inrisctl"></li>
        <li><? echo utf8ToHtml('Nota:'); ?></li>
        <li id="nrnotrat"></li>
        <li><? echo utf8ToHtml('Rating:'); ?></li>
        <li id="indrisco"></li>
        <li><? echo utf8ToHtml('Nota:'); ?></li>
        <li id="nrnotatl"></li>
    </ul>
</div>
<div id="linha2">
    <ul class="complemento">
        <li><? echo utf8ToHtml('Efetivacao:'); ?></li>
        <li id="dteftrat"></li>
        <li><? echo utf8ToHtml('Operador:'); ?></li>
        <li id="nmoperad"></li>
    </ul>
</div>
<br style="clear:both" />
<div id="divBotoes2">
    <a href="#" class="botao" id="btVoltar"  onClick="btnVoltar2(); return false;">Voltar</a>
    <a href="#" class="botao" id="btImprimir"  onClick="btnImprimirRatEfetivo(); return false;">Imprimir</a>
</div>
<br style="clear:both" />