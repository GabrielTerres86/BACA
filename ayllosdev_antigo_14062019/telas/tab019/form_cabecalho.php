<?php
/* !
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann/Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 06/04/2016
 * OBJETIVO     : Cabeçalho para a tela TAB019
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<form id="frmCab" name="frmCab" class="formulario">

    <label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
    <select id="cddopcao" name="cddopcao">       
        <option value="C"><?php echo utf8ToHtml('C - Consultar Parametros Desconto de Cheques') ?></option>                
        <option value="A"><?php echo utf8ToHtml('A - Alterar Parametros Desconto de Cheques') ?></option>           
    </select>
    
    <label for="inpessoa"><? echo utf8ToHtml('Tipo Pessoa:') ?></label>
    <select id="inpessoa" name="inpessoa">       
        <option value="1"><?php echo utf8ToHtml('Física') ?></option>                
        <option value="2"><?php echo utf8ToHtml('Jurídica') ?></option>           
    </select>
	
    <a href="#" class="botao" id="btnOK" name="btnOK" onClick="controlaOperacao();
                return false;" style = "text-align:right;">OK</a>

    <br style="clear:both" />

</form>