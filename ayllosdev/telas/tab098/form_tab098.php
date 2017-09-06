<?
/*!
 * FONTE        	: form_tab098.php
 * CRIAÇÃO      	: Ricardo Linhares
 * DATA CRIAÇÃO 	: Dezembro/2016
 * OBJETIVO     	: Form para a tela TAB098
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>

<style>
    .labelNomeParametro {
        width:300px;
    } 

</style>

<form id="frmTab098" name="frmTab098" class="formulario" style="display:none; border-bottom: 1px solid #777777; ">

	<input name="cdcooper" id="cdcooper" type="hidden" value="<? echo $glbvars["cdcooper"]; ?>" />
    <label for="flgpagcont_ib" class="labelNomeParametro"><? echo utf8ToHtml('Habilitar pagamento por conting&ecirc;ncia - IB:') ?></label>                        
    <select id="flgpagcont_ib" name="flgpagcont_ib">                      
        <option value="S" selected>SIM</option>
        <option value="N" selected>NAO</option>
    </select>                

    <br style="clear:both" />   

    <label for="flgpagcont_taa" class="labelNomeParametro"><? echo utf8ToHtml('Habilitar pagamento por conting&ecirc;ncia - TAA:') ?></label>                        
    <select id="flgpagcont_taa" name="flgpagcont_taa">                      
        <option value="S" selected>SIM</option>
        <option value="N" selected>NAO</option>
    </select>                

    <br style="clear:both" />   

    <label for="flgpagcont_cx" class="labelNomeParametro"><? echo utf8ToHtml('Habilitar pagamento por conting&ecirc;ncia - Caixa Online:') ?></label>                        
    <select id="flgpagcont_cx" name="flgpagcont_cx">                      
        <option value="S" selected>SIM</option>
        <option value="N" selected>NAO</option>
    </select>                

    <br style="clear:both" />   

    <label for="flgpagcont_mob" class="labelNomeParametro"><? echo utf8ToHtml('Habilitar pagamento por conting&ecirc;ncia - Mobile:') ?></label>                        
    <select id="flgpagcont_mob" name="flgpagcont_mob">                      
        <option value="S" selected>SIM</option>
        <option value="N" selected>NAO</option>
    </select>                

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

        <label for="rollout_cip_reg_data" class="labelNomeParametro"><? echo utf8ToHtml('Rollout Registro CIP a partir de:') ?></label>
        <input name="rollout_cip_reg_data" id="rollout_cip_reg_data" type="text" style="margin-right: 5px"/>            
        <label for="rollout_cip_reg_valor" ><? echo utf8ToHtml('R$:') ?></label>
        <input name="rollout_cip_reg_valor" id="rollout_cip_reg_valor" type="text" class="moeda" style="margin-right: 5px"/>

        <br style="clear:both" />

        <label for="rollout_cip_pag_data" class="labelNomeParametro"><? echo utf8ToHtml('Rollout Pagamento CIP a partir de:') ?></label>
        <input name="rollout_cip_pag_data" id="rollout_cip_pag_data" type="text" style="margin-right: 5px"/>            
        <label for="rollout_cip_pag_valor" ><? echo utf8ToHtml('R$:') ?></label>
        <input name="rollout_cip_pag_valor" id="rollout_cip_pag_valor" type="text" class="moeda" style="margin-right: 5px"/>

        <br style="clear:both" />        
    
    <?php
    }
    ?>

</form>

<script type="text/javascript">
    

</script>
