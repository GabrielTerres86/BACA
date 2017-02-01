<?
/*!
 * FONTE        	: form_c.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Outubro/2016
 * OBJETIVO     	: Form para a opcao C
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>

<form id="frmParflu" name="frmParflu" class="formulario">
    <input name="hdnconta" id="hdnconta" type="hidden" value="<?php echo $conta_sysphera; ?>" />
    
    <div id="divConta1" style="margin-top:20px; display:none; text-align: center;" >
		<label for="conta_sysphera">Conta Sysphera:</label>
        <select id="conta_sysphera" name="conta_sysphera">
            <?php
                $arrNmconta = array();
                foreach ($regcontas as $reg) {
                    $cdconta = getByTagName($reg->tags,'CDCONTA');
                    $nmconta = getByTagName($reg->tags,'NMCONTA');
                    $arrNmconta[$cdconta] = $nmconta;
                    echo '<option value="'.$cdconta.'">'.$cdconta.' - '.$nmconta.'</option> ';
                }
            ?>
        </select>
        <a href="#" class="botao" id="btVoltar"  onClick="btnVoltar();return false;" style="text-align: right; float: none;">Voltar</a>
        <a href="#" class="botao" id="btProsseguir" onClick="mostraOpcaoC();" style="text-align: right; float: none;">Prosseguir</a>
	</div>

    <div id="divConta2" style="margin-top:20px; display:none; text-align: center;" >
        <label for="conta_sysphera">Conta Sysphera:</label>
        <input type="text" name="cdconta" id="cdconta" value="<?php echo $conta_sysphera; ?>" />
        <input type="text" name="nmconta" id="nmconta" value="<?php echo $arrNmconta[$conta_sysphera]?>" />
        <br style="clear:both" />

        <fieldset id="fsetFormulario" name="fsetFormulario" style="padding:0px; margin:0px; margin-top:20px; padding-bottom:10px;">
        <legend> Per&iacute;odo At&eacute; (dias) </legend>
            <div align="center">
                <table id="tabFieldC">
                <tr>
                    <td width="70">&nbsp;</td>
                    <td width="60" align="center">%</td>
                    <td width="40">&nbsp;</td>
                    <td width="70">&nbsp;</td>
                    <td width="60" align="center">%</td>
                    <td width="40">&nbsp;</td>
                    <td width="90">&nbsp;</td>
                    <td width="60" align="center">%</td>
                </tr>
                <tr>
                    <td>At&eacute; 90 d</td>
                    <td><input type="text" name="perc_90" id="perc_90" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 1800 d</td>
                    <td><input type="text" name="perc_1800" id="perc_1800" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 4320 d</td>
                    <td><input type="text" name="perc_4320" id="perc_4320" /></td>
                </tr>
                <tr>
                    <td>At&eacute; 180 d</td>
                    <td><input type="text" name="perc_180" id="perc_180" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 2160 d</td>
                    <td><input type="text" name="perc_2160" id="perc_2160" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 4680 d</td>
                    <td><input type="text" name="perc_4680" id="perc_4680" /></td>
                </tr>
                <tr>
                    <td>At&eacute; 270 d</td>
                    <td><input type="text" name="perc_270" id="perc_270" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 2520 d</td>
                    <td><input type="text" name="perc_2520" id="perc_2520" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 5040 d</td>
                    <td><input type="text" name="perc_5040" id="perc_5040" /></td>
                </tr>
                <tr>
                    <td>At&eacute; 360 d</td>
                    <td><input type="text" name="perc_360" id="perc_360" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 2880 d</td>
                    <td><input type="text" name="perc_2880" id="perc_2880" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 5400 d</td>
                    <td><input type="text" name="perc_5400" id="perc_5400" /></td>
                </tr>
                <tr>
                    <td>At&eacute; 720 d</td>
                    <td><input type="text" name="perc_720" id="perc_720" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 3240 d</td>
                    <td><input type="text" name="perc_3240" id="perc_3240" /></td>
                    <td>&nbsp;</td>
                    <td>Mais de 5400 d</td>
                    <td><input type="text" name="perc_5401" id="perc_5401" /></td>
                </tr>
                <tr>
                    <td>At&eacute; 1080 d</td>
                    <td><input type="text" name="perc_1080" id="perc_1080" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 3600 d</td>
                    <td><input type="text" name="perc_3600" id="perc_3600" /></td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>At&eacute; 1440 d</td>
                    <td><input type="text" name="perc_1440" id="perc_1440" /></td>
                    <td>&nbsp;</td>
                    <td>At&eacute; 3960 d</td>
                    <td><input type="text" name="perc_3960" id="perc_3960" /></td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                </table>
            </div>
        </fieldset>
    </div>
	
</form>