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

	<fieldset>
		<legend><? echo utf8ToHtml('Pagamentos Divergentes') ?></legend>
	
        <label for="sit_pag_divergente"><? echo utf8ToHtml('Situa&ccedil;&atilde;o das Devolu&ccedil;&otilde;es:') ?></label>
        <select name="sit_pag_divergente" id="sit_pag_divergente" >
            <option value="1" > ATIVO        </option>
            <option value="2" > INATIVO      </option>
        </select>
        <br />
	
        <label for="pag_a_menor"><? echo utf8ToHtml('Devolver pagamentos a menor:') ?></label>
        <input name="pag_a_menor" id="pag_a_menor" type="checkbox" class="checkbox" readonly />
        <br />
	
        <label for="pag_a_maior"><? echo utf8ToHtml('Devolver pagamentos a maior:') ?></label>
        <input name="pag_a_maior" id="pag_a_maior" type="checkbox" class="checkbox" readonly />
        <br />
	
        <label for="tip_tolerancia"><? echo utf8ToHtml('Tipo de Toler&acirc;ncia:') ?></label>
        <select name="tip_tolerancia" id="tip_tolerancia" >
            <option value="1" > VALOR        </option>
            <option value="2" > PERCENTUAL   </option>
        </select>
        <br />
	
        <label for="vl_tolerancia"><? echo utf8ToHtml('Toler&acirc;ncia:') ?></label>
        <input name="vl_tolerancia" id="vl_tolerancia" type="text" style="margin-right: 5px"/>
        <label id="simbolo_percentual" class="rotulo-linha">% &nbsp;&nbsp; </label>
        <br />
	
        <br style="clear:both" />
	
	</fieldset>
	
    <br style="clear:both" />
    
    <ul class="complemento">
        <li><? echo utf8ToHtml('Última Alt.:') ?></li>
        <li id="dtcadast"></li>
        <li><? echo utf8ToHtml('Operador:') ?></li>
        <li id="cdoperad"></li>
    </ul>
    
    <br style="clear:both" />
    
</form>

<script type="text/javascript">
    

</script>
