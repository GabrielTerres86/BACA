<?
/*!
 * FONTE        	: form_h.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Outubro/2016
 * OBJETIVO     	: Form para a opcao H
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>

<form id="frmParflu" name="frmParflu" class="formulario">
    <input name="hdncooper" id="hdncooper" type="hidden" value="<?php echo $cooper; ?>" />

    <div id="divCooper1" style="margin-top:20px; display:none; text-align: center;" >
		<label for="cooper">Cooperativa:</label>
        <select id="cooper" name="cooper">
            <option value="0">Selecione</option>
            <?php
                $arrCoop = array();
                foreach ($list_coop as $reg) {
                    $cdcooper = getByTagName($reg->tags,'cdcooper');
                    $nmrescop = getByTagName($reg->tags,'nmrescop');
                    if ($cdcooper <> '' &&
                        $cdcooper <> 3 ) {
                        $arrCoop[$cdcooper] = $nmrescop;
                        echo '<option value="'.$cdcooper.'">'.$nmrescop.'</option>';
                    }
                }
            ?>
        </select>
        <a href="#" class="botao" id="btVoltar"  onClick="btnVoltar();return false;" style="text-align: right; float: none;">Voltar</a>
        <a href="#" class="botao" id="btProsseguir" onClick="mostraOpcaoH();" style="text-align: right; float: none;">Prosseguir</a>
	</div>

    <div id="divCooper2" style="margin-top:20px; display:none; text-align: center;" >
        <label for="cooper">Cooperativa:</label>
        <input type="text" name="cdcooper" id="cdcooper" value="<?php echo $cooper; ?>" />
        <input type="text" name="nmcooper" id="nmcooper" value="<?php echo $arrCoop[$cooper]; ?>" />

        <br style="clear:both" />
        <br style="clear:both" />

        <fieldset id="fsetFormularioInc" name="fsetFormularioInc" style="padding:0px; margin:0px;">
        <legend> Hor&aacute;rio Bloqueio </legend>
            <table width="500" style="margin: 5px 0px 10px 10px;">
            <tr><td colspan="2"><input type="text" name="dshora" id="dshora" value="<?php echo $dshora; ?>" /></td></tr>
            <tr>
                <td width="25"><input type="checkbox" name="inallcop" id="inallcop" /></td>
                <td>Gravar em todas as Cooperativas</td>
            </tr>
            </table>
        </fieldset>
    </div>
	
</form>