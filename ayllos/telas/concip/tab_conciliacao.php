<?php
/*
 * FONTE        : tab_conciliacao.php
 * CRIAÇÃO      : Marcos Lucas (Mout's)
 * DATA CRIAÇÃO : 20/02/2018
 * OBJETIVO     : Tabela que apresenta conciliacao de liquidacao STR0006R2
 * --------------
 * ALTERAÇÕES   : 23/07/2018 - Alterado texto de legenda dos Fieldsets (PRJ 486 - Mateus Z / Mouts)
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

$vlPagamentos = str_replace(',', '.', $vlPagamentos);
$vlCreditado  = str_replace(',', '.', $vlCreditado);

//pagamento maior que creditado
$vl_pagar = ($vlPagamentos > $vlCreditado) ? ($vlPagamentos - $vlCreditado) : 0;
//creditado maior que pagamento
$vl_receber = ($vlCreditado > $vlPagamentos) ? ($vlCreditado - $vlPagamentos) : 0;
?>
<style type="text/css">
    
    .boxes {
        width: 28%;
        display: inline;
        margin-right: 10px;
        margin-left: 10px;
    }

</style>
<div id="divTotaisConciliacao" style="margin-bottom: 15px; text-align:center; margin-top: 15px; display: flex;">

    <fieldset style="padding:0px; margin:0 auto; padding-bottom:10px; width: 90%; display:inline;">
        <legend style="font-weight: 600"><?php echo utf8ToHtml('Conciliação Liquidação STR') ?></legend>

        <!-- recebidos STR0006R2 -->
        <fieldset class="boxes">
            <legend style="font-weight: 600"><?php echo utf8ToHtml('Liquidação recebida') ?></legend>

            <label for="txtQdeRecebido"><?php echo utf8ToHtml('Quantidade:') ?></label>
            <input type="text" id="txtQdeRecebido" name="txtQdeRecebido" value="<?php echo (empty($qdePagamentos)) ? '0' : $qdePagamentos;?>"/>

            <label for="txtVlRecebido"><?php echo utf8ToHtml('Valor:') ?></label>
            <input type="text" id="txtVlRecebido" name="txtVlRecebido" value="<?php echo formataMoeda($vlPagamentos);?>"/>
        </fieldset>


        <!-- repasse a cooperados -->
        <fieldset class="boxes">
            <legend style="font-weight: 600"><?php echo utf8ToHtml('Liquidação C/C Cooperados') ?></legend>

            <label for="txtQtcreditado"><? echo utf8ToHtml('Quantidade:') ?></label>
            <input type="text" id="txtQtcreditado" name="txtQtcreditado" value="<?php echo (empty($qdeCreditado)) ? '0' : $qdeCreditado;?>"/>

            <label for="txtVlcreditado"><? echo utf8ToHtml('Valor:') ?></label>
            <input type="text" id="txtVlcreditado" name="txtVlcreditado" value="<?php echo formataMoeda($vlCreditado);?>"/>
        </fieldset>


        <!-- saldo diferencial valores -->
        <fieldset class="boxes">
            <legend style="font-weight: 600"><?php echo utf8ToHtml('Saldo') ?></legend>

            <label for="txtVlReceber"><? echo utf8ToHtml('A Receber:') ?></label>
            <input type="text" id="txtVlReceber" name="txtVlReceber" value="<?php echo formataMoeda($vl_receber);?>"/>

            <label for="txtVlPagar"><? echo utf8ToHtml('A Pagar:') ?></label>
            <input type="text" id="txtVlPagar" name="txtVlPagar" value="<?php echo formataMoeda($vl_pagar);?>"/>
        </fieldset>
        
    </fieldset>

</div>
