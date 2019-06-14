<?php
/*!
 * FONTE        	: form_m.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Outubro/2016
 * OBJETIVO     	: Form da opcao M
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>

<form id="frmOpcaoM" name="frmOpcaoM" class="formulario">
    
    <br />

	<fieldset id="fsetInvestimentos" name="fsetInvestimentos" style="padding:10px;">
	<legend> Investimentos </legend>
        <table width="600" cellpadding="10" cellspacing="2">
        <tr>
            <td width="150">Cooperativa:</td>
            <td width="150">Operador:</td>
            <td width="150" style="text-align:right;">Valor:&nbsp;&nbsp;</td>
            <td width="150">Movimentação:</td>
        </tr>
        <?php
            $vltotope = 0;
            foreach ($registros as $reg) {
                $vltotope = $vltotope + converteFloat(getByTagName($reg->tags,'VLMOVIME'));
                echo '
                <tr>
                    <td><input type="text" value="'.getByTagName($reg->tags,'NMRESCOP').'" /></td>
                    <td><input type="text" value="'.getByTagName($reg->tags,'NMOPERAD').'" style="width:240px;" /></td>
                    <td><input type="text" value="'.getByTagName($reg->tags,'VLMOVIME').'" style="text-align:right;" /></td>
                    <td><input type="text" value="'.getByTagName($reg->tags,'DSMOVIME').'" style="width:80px;" /></td>
                </tr>';
            }
        ?>
        <tr>
            <td>&nbsp;</td>
            <td align="right">Total das operações:</td>
            <td><input type="text" value="<?php echo formataMoeda($vltotope); ?>" style="text-align:right;" /></td>
            <td>&nbsp;</td>
        </tr>
        </table>
	</fieldset>

    <br style="clear:both" />
	
</form>

<script type="text/javascript">
    var cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmOpcaoM');
    cTodosFormulario.desabilitaCampo();
    trocaBotao('','','btnVoltar()');
</script>