<?php
/*!
 * FONTE        	: form_r.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Outubro/2016
 * OBJETIVO     	: Form da opcao R
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */
?>

<form id="frmOpcaoR" name="frmOpcaoR" class="formulario">
    
    <br />

	<fieldset id="fsetResultadoCentralizacao" name="fsetResultadoCentralizacao" style="padding:10px;">
	<legend> Resultado Centralização </legend>
        <table width="800" cellpadding="10" cellspacing="2">
        <tr>
            <td>&nbsp;</td>
            <td align="right">AILOS &nbsp;</td>
            <td align="right">BANCO DO BRASIL &nbsp;</td>
            <td align="right">BANCOOB &nbsp;</td>
            <td align="right">SICREDI &nbsp;</td>
        </tr>
        <tr>
            <td align="right">ENTRADAS</td>
            <td><input type="text" name="vlent085" id="vlent085" value="<?php echo $arrRegist['085']['VLENTRAD']; ?>" /></td>
            <td><input type="text" name="vlent001" id="vlent001" value="<?php echo $arrRegist['001']['VLENTRAD']; ?>" /></td>
            <td><input type="text" name="vlent756" id="vlent756" value="<?php echo $arrRegist['756']['VLENTRAD']; ?>" /></td>
            <td><input type="text" name="vlent748" id="vlent748" value="<?php echo $arrRegist['748']['VLENTRAD']; ?>" /></td>
        </tr>                     
        <tr>                      
            <td align="right">SAÍDAS</td>
            <td><input type="text" name="vlsai085" id="vlsai085" value="<?php echo $arrRegist['085']['VLSAIDAS']; ?>" /></td>
            <td><input type="text" name="vlsai001" id="vlsai001" value="<?php echo $arrRegist['001']['VLSAIDAS']; ?>" /></td>
            <td><input type="text" name="vlsai756" id="vlsai756" value="<?php echo $arrRegist['756']['VLSAIDAS']; ?>" /></td>
            <td><input type="text" name="vlsai748" id="vlsai748" value="<?php echo $arrRegist['748']['VLSAIDAS']; ?>" /></td>
        </tr>                     
        <tr>                      
            <td align="right">DIVERSOS</td>
            <td><input type="text" name="vldiv085" id="vldiv085" value="<?php echo $arrRegist['085']['VLOUTROS']; ?>" class="clsFieldDesbloq" /></td>
            <td><input type="text" name="vldiv001" id="vldiv001" value="<?php echo $arrRegist['001']['VLOUTROS']; ?>" class="clsFieldDesbloq" /></td>
            <td><input type="text" name="vldiv756" id="vldiv756" value="<?php echo $arrRegist['756']['VLOUTROS']; ?>" class="clsFieldDesbloq" /></td>
            <td><input type="text" name="vldiv748" id="vldiv748" value="<?php echo $arrRegist['748']['VLOUTROS']; ?>" class="clsFieldDesbloq" /></td>
        </tr>                     
        <tr>                      
            <td align="right">RESULTADO CENTRALIZAÇÃO</td>
            <td><input type="text" name="vlres085" id="vlres085" value="<?php echo $arrRegist['085']['VLRESULT']; ?>" /></td>
            <td><input type="text" name="vlres001" id="vlres001" value="<?php echo $arrRegist['001']['VLRESULT']; ?>" /></td>
            <td><input type="text" name="vlres756" id="vlres756" value="<?php echo $arrRegist['756']['VLRESULT']; ?>" /></td>
            <td><input type="text" name="vlres748" id="vlres748" value="<?php echo $arrRegist['748']['VLRESULT']; ?>" /></td>
        </tr>
        </table>
	</fieldset>
    
    <br />

	<table width="100%" cellpadding="10" cellspacing="2">
    <tr>
        <td width="50%">
            <fieldset id="fsetResultadoTotal" name="fsetResultadoTotal" style="padding:10px; height:185px;">
            <legend> Resultado Total </legend>
                <table cellpadding="10" cellspacing="2" style="margin-left:30px;">
                <tr>
                    <td align="right">ENTRADAS</td>
                    <td><input type="text" name="vlenttot" id="vlenttot" value="<?php echo getByTagName($reginform->tags,'TOT_VLENTRAD'); ?>" /></td>
                </tr>
                <tr>
                    <td align="right">SAÍDAS</td>
                    <td><input type="text" name="vlsaitot" id="vlsaitot" value="<?php echo getByTagName($reginform->tags,'TOT_VLSAIDAS'); ?>" /></td>
                </tr>
                <tr>
                    <td align="right">DIVERSOS</td>
                    <td><input type="text" name="vldivtot" id="vldivtot" value="<?php echo getByTagName($reginform->tags,'TOT_VLOUTROS'); ?>" /></td>
                </tr>
                <tr>
                    <td align="right">RESULTADO CENTRALIZAÇÃO</td>
                    <td><input type="text" name="vlrestot" id="vlrestot" value="<?php echo getByTagName($reginform->tags,'TOT_VLRESULT'); ?>" /></td>
                </tr>
                <tr>
                    <td align="right">SALDO C/C ATUALIZADO</td>
                    <td><input type="text" name="vlsldcta" id="vlsldcta" value="<?php echo getByTagName($reginform->tags,'TOT_VLSLDCTA'); ?>" /></td>
                </tr>
                <tr>
                    <td align="right">SALDO FINAL C/C</td>
                    <td><input type="text" name="vlsldfim" id="vlsldfim" value="<?php echo getByTagName($reginform->tags,'TOT_VLSLDFIM'); ?>" /></td>
                </tr>
                </table>
            </fieldset>
        </td>
        <td width="50%">
            <fieldset id="fsetInvestimentos" name="fsetInvestimentos" style="padding:10px; height:185px;">
            <legend> Investimentos </legend>
                <table cellpadding="10" cellspacing="2" style="margin-left:20px;">
                <tr>
                    <td height="26">&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td align="right">RESGATE</td>
                    <td><input type="text" name="vlresgat" id="vlresgat" value="<?php echo getByTagName($reginform->tags,'TOT_VLRESGAT'); ?>" class="clsFieldDesbloq" /></td>
                </tr>                     
                <tr>                      
                    <td align="right">APLICAÇÃO</td>
                    <td><input type="text" name="vlaplica" id="vlaplica" value="<?php echo getByTagName($reginform->tags,'TOT_VLAPLICA'); ?>" class="clsFieldDesbloq" /></td>
                </tr>
                <tr>
                    <td align="right">OPERADOR</td>
                    <td><input type="text" value="<?php echo getByTagName($reginform->tags,'NMOPERAD'); ?>" style="width:270px;" class="clsTxtLeft" /></td>
                </tr>
                <tr>
                    <td align="right">HORÁRIO</td>
                    <td><input type="text" value="<?php echo getByTagName($reginform->tags,'HRTRANSA'); ?>" class="clsTxtLeft" /></td>
                </tr>
                </table>
            </fieldset>
        </td>
    </tr>
    </table>

    <br style="clear:both" />

</form>

<script type="text/javascript">
    var cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmOpcaoR');
    cTodosFormulario.css('text-align', 'right').desabilitaCampo();
    $('.clsTxtLeft', '#frmOpcaoR').css('text-align', 'left');
    <?php
        if (getByTagName($reginform->tags,'PODE_ALTERAR')) {
            ?>
            highlightObjFocus($('#frmOpcaoR'));
            formataOpcaoR();
            $('.clsFieldDesbloq', '#frmOpcaoR').habilitaCampo();
            $('#vldiv085', '#frmOpcaoR').focus();
            trocaBotao('Prosseguir','alterarDados()','btnVoltar()');
            <?php
        } else {
            ?>
            trocaBotao('','','btnVoltar()');
            <?php
        }
    ?>
</script>