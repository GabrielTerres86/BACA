<? 
/*!
 * FONTE        : form_cadris.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 25/04/2016
 * OBJETIVO     : Formulario do cadastro.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form id="frmCadris" name="frmCadris" class="formulario">

	<fieldset style="padding-top: 5px;">
        <label for="innivris">Nível de Risco:</label>	
        <select name="innivris" id="innivris">
        <?php
            $arrRisco = array(2 => 'A', 3 => 'B', 4 => 'C', 5 => 'D', 6 => 'E', 7 => 'F', 8 => 'G', 9 => 'H');
            foreach ($arrRisco as $innivris => $dsnivris) {
                ?><option value="<?php echo $innivris; ?>"><?php echo $dsnivris; ?></option><?php
            }
        ?>
        </select>
        <label for="nrdconta" class="clsContaJustif"><?php echo utf8ToHtml('Conta/DV:') ?></label>
        <input type="text" id="nrdconta" name="nrdconta" class="conta clsContaJustif" />
        <a class="clsContaJustif"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
        <br />
        <label for="dsjustif" class="clsContaJustif"><?php echo utf8ToHtml('Justificativa:') ?></label>
        <textarea name="dsjustif" id="dsjustif" class="clsContaJustif"></textarea>
	</fieldset>

    <fieldset style="padding-top: 5px;" id="fieldListagem"></fieldset>
    
    <fieldset id="fieldJustificativa">
        <label for="dsjustificativa" class="rotulo txtNormalBold">Justificativa:</label>
        <textarea name="dsjustificativa" id="dsjustificativa"></textarea>
    </fieldset>

</form>