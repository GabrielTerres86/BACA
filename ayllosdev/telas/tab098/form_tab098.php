<?
/*!
 * FONTE        	: form_tab098.php
 * CRIAÇÃO      	: Ricardo Linhares
 * DATA CRIAÇÃO 	: Dezembro/2016
 * OBJETIVO     	: Form para a tela TAB098
 * ÚLTIMA ALTERAÇÃO : 01/08/2017
 * --------------
 * ALTERAÇÕES   	: 01/08/2017 - Excluir campos para habilitar contigencia e rollout e incluir campo para valor limite.
 *                                 PRJ340-NPC (Odirlei-AMcom)
 * --------------
 */
?>

<style>
    .labelNomeParametro {
        width:315px;
    } 

</style>

<form id="frmTab098" name="frmTab098" class="formulario" style="display:none; border-bottom: 1px solid #777777; ">

    <label for="vlcontig_cip" class="labelNomeParametro"><? echo utf8ToHtml('Valor limite de pagamento em conting&ecirc;ncia:') ?></label>  
    <input name="vlcontig_cip" id="vlcontig_cip" type="text" class="moeda" style="margin-right: 5px"/>        

    <br style="clear:both" />   

    <label for="prz_baixa_cip" class="labelNomeParametro"><? echo utf8ToHtml('Prazo de baixa autom&aacute;tica de boletos - CIP:') ?></label>
    <input name="prz_baixa_cip" id="prz_baixa_cip" type="text" class="inteiro" style="margin-right: 5px"/>        
    <label><? echo utf8ToHtml(' dias') ?></label>
    
    <br style="clear:both" />

    <?php
        if ($glbvars["cdcooper"] == 3) {
    ?>

        <label for="vlvrboleto" class="labelNomeParametro"><? echo utf8ToHtml('Valor do VR-Boleto:') ?></label>
        <input name="vlvrboleto" id="vlvrboleto" type="text" class="moeda" style="margin-right: 5px"/>        

        <br style="clear:both" />        
    
    <?php
    }
    ?>

</form>

<script type="text/javascript">
    

</script>
