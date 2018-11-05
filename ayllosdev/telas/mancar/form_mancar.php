<?
/*!
 * FONTE        	: form_mancar.php
 * CRIAÇÃO      	: André Clemer
 * DATA CRIAÇÃO 	: Abril/2018
 * OBJETIVO     	: Form para a tela MANCAR
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>
<style>
    .labelFrmManCar {
        width:200px;
    } 
</style>

<form id="frmManCar" name="frmManCar" class="formulario" style="display:none; border-bottom: 1px solid #777777; ">
    <input name="idcartorio" id="idcartorio" type="hidden" />        
    <input name="idcartorio" id="idcartorio" type="hidden" />        


    <label for="nmcartorio" class="labelFrmManCar"><? echo utf8ToHtml('Nome:') ?></label>  
    <input name="nmcartorio" id="nmcartorio" type="text" style="margin-right: 5px; width:410px"/>        

    <br style="clear:both" />

    <label for="idcidade" class="labelFrmManCar">Cidade:</label>
    <input type="text" id="idcidade" name="idcidade" class="inteiro" style="width:80px" maxlength="8" />
    <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
    <input type="text" id="dscidade" name="dscidade" style="width:310px" />

    <br style="clear:both" />

    <label for="nrcpf_cnpj" class="labelFrmManCar"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
    <input name="nrcpf_cnpj" id="nrcpf_cnpj" type="text" class="inteiro campo" maxlength="14" style="margin-right: 5px">

    <br style="clear:both" />

    <label for="flgativo" class="labelFrmManCar"><? echo utf8ToHtml('Ativo:') ?></label>
    <select id="flgativo" name="flgativo" style="width: 60px;">
        <option value="0">NAO</option>
        <option value="1" selected>SIM</option>
    </select>

    <br style="clear:both" />

</form>

