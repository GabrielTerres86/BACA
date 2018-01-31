<?php
/*!
 * FONTE        	: form_f.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Outubro/2016
 * OBJETIVO     	: Form da opcao F
 * ÚLTIMA ALTERAÇÃO : 25/01/2018
 * --------------
 * ALTERAÇÕES   	: 25/01/2018 - Incluido convenio de Bancoob. PRJ-406 FGTS (Odirlei-AMcom)
 * --------------
 */
?>

<form id="frmOpcaoF" name="frmOpcaoF" class="formulario">
    
    <br />

	<fieldset id="fsetCECRED" name="fsetCECRED" style="padding:10px;">
	<legend> CECRED </legend>
        <table width="800" cellpadding="10" cellspacing="2" style="text-align:right; margin-right:20px;">
        <tr>
            <td width="200">&nbsp;</td>
            <td width="150">PROJETADO</td>
            <td width="150">REALIZADO</td>
            <td width="150">DIFERENÇA(R$)</td>
            <td width="150">DIFERENÇA(%)</td>
        </tr>
        <?php
            // Se for ENTRADA
            if ($tpdmovto == 'E') { 
                ?>
                <tr>
                    <td>NR CHEQUES</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['VLCHEQUE']; ?>" <?php echo ($arrRegist['0853']['BG_NR_CHEQUES'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['VLCHEQUE']; ?>" <?php echo ($arrRegist['0851']['BG_NR_CHEQUES'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLCHEQUE']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLCHEQUE']; ?>" /></td>
                </tr>
                <tr>
                    <td>SR DOC</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['VLTOTDOC']; ?>" <?php echo ($arrRegist['0853']['BG_SR_DOC'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['VLTOTDOC']; ?>" <?php echo ($arrRegist['0851']['BG_SR_DOC'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLTOTDOC']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLTOTDOC']; ?>" /></td>
                </tr>
                <tr>
                    <td>SR TED</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['VLTOTTED']; ?>" <?php echo ($arrRegist['0853']['BG_SR_TED'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['VLTOTTED']; ?>" <?php echo ($arrRegist['0851']['BG_SR_TED'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLTOTTED']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLTOTTED']; ?>" /></td>
                </tr>
                <tr>
                    <td>SR TÍTULOS</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['VLTOTTIT']; ?>" <?php echo ($arrRegist['0853']['BG_SR_TITULOS'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['VLTOTTIT']; ?>" <?php echo ($arrRegist['0851']['BG_SR_TITULOS'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLTOTTIT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLTOTTIT']; ?>" /></td>
                </tr>
                <tr>
                    <td>DEV. CHEQUE REMETIDO</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['VLDEVOLU']; ?>" <?php echo ($arrRegist['0853']['BG_DEV_CHEQUE_REMETIDO'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['VLDEVOLU']; ?>" <?php echo ($arrRegist['0851']['BG_DEV_CHEQUE_REMETIDO'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLDEVOLU']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLDEVOLU']; ?>" /></td>
                </tr>
                <tr>
                    <td>TRANSF INTER</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['VLTRFITC']; ?>" <?php echo ($arrRegist['0853']['BG_TRANSF_INTER'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['VLTRFITC']; ?>" <?php echo ($arrRegist['0851']['BG_TRANSF_INTER'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLTRFITC']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLTRFITC']; ?>" /></td>
                </tr>
                <tr>
                    <td>DEP INTER</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['VLDEPITC']; ?>" <?php echo ($arrRegist['0853']['BG_DEP_INTER'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['VLDEPITC']; ?>" <?php echo ($arrRegist['0851']['BG_DEP_INTER'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLDEPITC']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLDEPITC']; ?>" /></td>
                </tr>
                <tr>
                    <td>SAQUE TAA INTERC</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['VLSATAIT']; ?>" <?php echo ($arrRegist['0853']['BG_SAQUE_TAA_INTERC'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['VLSATAIT']; ?>" <?php echo ($arrRegist['0851']['BG_SAQUE_TAA_INTERC'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLSATAIT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLSATAIT']; ?>" /></td>
                </tr>
                <tr>
                    <td>RECOLHIMENTO NUMERÁRIO</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['VLNUMERA']; ?>" <?php echo ($arrRegist['0853']['BG_RECOLHIMENTO_NUMERARIO'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['VLNUMERA']; ?>" <?php echo ($arrRegist['0851']['BG_RECOLHIMENTO_NUMERARIO'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLNUMERA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLNUMERA']; ?>" /></td>
                </tr>
                <?php
            // Se for SAIDA
            } else if ($tpdmovto == 'S') {
                ?>
                <tr>
                    <td>SR CHEQUES</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLCHEQUE']; ?>" <?php echo ($arrRegist['0854']['BG_SR_CHEQUES'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLCHEQUE']; ?>" <?php echo ($arrRegist['0852']['BG_SR_CHEQUES'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLCHEQUE']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLCHEQUE']; ?>" /></td>
                </tr>
                <tr>
                    <td>NR DOC</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLTOTDOC']; ?>" <?php echo ($arrRegist['0854']['BG_NR_DOC'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLTOTDOC']; ?>" <?php echo ($arrRegist['0852']['BG_NR_DOC'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLTOTDOC']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLTOTDOC']; ?>" /></td>
                </tr>
                <tr>
                    <td>NR TED/TEC</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLTOTTED']; ?>" <?php echo ($arrRegist['0854']['BG_NR_TED_TEC'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLTOTTED']; ?>" <?php echo ($arrRegist['0852']['BG_NR_TED_TEC'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLTOTTED']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLTOTTED']; ?>" /></td>
                </tr>
                <tr>
                    <td>NR TÍTULOS</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLTOTTIT']; ?>" <?php echo ($arrRegist['0854']['BG_NR_TITULOS'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLTOTTIT']; ?>" <?php echo ($arrRegist['0852']['BG_NR_TITULOS'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLTOTTIT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLTOTTIT']; ?>" /></td>
                </tr>
                <tr>
                    <td>DEV. CHEQUE RECEBIDO</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLDEVOLU']; ?>" <?php echo ($arrRegist['0854']['BG_DEV_CHEQUE_RECEBIDO'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLDEVOLU']; ?>" <?php echo ($arrRegist['0852']['BG_DEV_CHEQUE_RECEBIDO'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLDEVOLU']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLDEVOLU']; ?>" /></td>
                </tr>
                <tr>
                    <td>TRANSF INTER</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLTRFITC']; ?>" <?php echo ($arrRegist['0854']['BG_TRANSF_INTER'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLTRFITC']; ?>" <?php echo ($arrRegist['0852']['BG_TRANSF_INTER'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLTRFITC']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLTRFITC']; ?>" /></td>
                </tr>
                <tr>
                    <td>DEP INTER</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLDEPITC']; ?>" <?php echo ($arrRegist['0854']['BG_DEP_INTER'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLDEPITC']; ?>" <?php echo ($arrRegist['0852']['BG_DEP_INTER'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLDEPITC']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLDEPITC']; ?>" /></td>
                </tr>
                <tr>
                    <td>SAQUE TAA INTERC</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLSATAIT']; ?>" <?php echo ($arrRegist['0854']['BG_SAQUE_TAA_INTERC'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLSATAIT']; ?>" <?php echo ($arrRegist['0852']['BG_SAQUE_TAA_INTERC'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLSATAIT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLSATAIT']; ?>" /></td>
                </tr>
                <tr>
                    <td>CARTÃO DE CRÉDITO</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLCARCRE']; ?>" <?php echo ($arrRegist['0854']['BG_CARTAO_CREDITO'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLCARCRE']; ?>" <?php echo ($arrRegist['0852']['BG_CARTAO_CREDITO'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLCARCRE']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLCARCRE']; ?>" /></td>
                </tr>
                <tr>
                    <td>SUPRIMENTO NUMERÁRIO</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLNUMERA']; ?>" <?php echo ($arrRegist['0854']['BG_SUPRIMENTO_NUMERARIO'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLNUMERA']; ?>" <?php echo ($arrRegist['0852']['BG_SUPRIMENTO_NUMERARIO'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLNUMERA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLNUMERA']; ?>" /></td>
                </tr>
                <tr>
                    <td>CONVÊNIOS</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['VLCONVEN']; ?>" <?php echo ($arrRegist['0854']['BG_CONVENIOS'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['VLCONVEN']; ?>" <?php echo ($arrRegist['0852']['BG_CONVENIOS'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_VLCONVEN']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_VLCONVEN']; ?>" /></td>
                </tr>
                <?php
            // RESULTADO
            } else {
                ?>
                <tr>
                    <td>ENTRADAS</td>
                    <td><input type="text" value="<?php echo $arrRegist['0853']['CEC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0851']['CEC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_CEC_IN']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_CEC_IN']; ?>" /></td>
                </tr>
                <tr>
                    <td>SAÍDAS</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['CEC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0852']['CEC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_CEC_OUT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_CEC_OUT']; ?>" /></td>
                </tr>
                <tr>
                    <td>RESULTADO CENTRALIZAÇÃO</td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_CEC_PROJETADO']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_CEC_REALIZADO']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_RS_CEC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0854']['DIF_PC_CEC_SOMA']; ?>" /></td>
                </tr>
                <?php
            }
        ?>
        </table>
	</fieldset>

    <br />

	<fieldset id="fsetBB" name="fsetBB" style="padding:10px;">
	<legend> BANCO DO BRASIL </legend>
        <table width="800" cellpadding="10" cellspacing="2" style="text-align:right; margin-right:20px;">
        <tr>
            <td width="200">&nbsp;</td>
            <td width="150" align="right">PROJETADO</td>
            <td width="150" align="right">REALIZADO</td>
            <td width="150" align="right">DIFERENÇA(R$)</td>
            <td width="150" align="right">DIFERENÇA(%)</td>
        </tr>
        <?php
            // Se for ENTRADA
            if ($tpdmovto == 'E') { 
                ?>
                <tr>
                    <td>SR TÍTULOS</td>
                    <td><input type="text" value="<?php echo $arrRegist['0013']['VLTOTTIT']; ?>" <?php echo ($arrRegist['0013']['BG_SR_TITULOS'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0011']['VLTOTTIT']; ?>" <?php echo ($arrRegist['0011']['BG_SR_TITULOS'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_RS_VLTOTTIT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_PC_VLTOTTIT']; ?>" /></td>
                </tr>
                <tr>
                    <td>MVTO CONTA ITG</td>
                    <td><input type="text" value="<?php echo $arrRegist['0013']['VLMVTITG']; ?>" <?php echo ($arrRegist['0013']['BG_MVTO_CONTA_ITG'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0011']['VLMVTITG']; ?>" <?php echo ($arrRegist['0011']['BG_MVTO_CONTA_ITG'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_RS_VLMVTITG']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_PC_VLMVTITG']; ?>" /></td>
                </tr>
                <?php
            // Se for SAIDA
            } else if ($tpdmovto == 'S') {
                ?>
                <tr>
                    <td>NR TÍTULOS</td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['VLTOTTIT']; ?>" <?php echo ($arrRegist['0014']['BG_NR_TITULOS'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0012']['VLTOTTIT']; ?>" <?php echo ($arrRegist['0012']['BG_NR_TITULOS'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_RS_VLTOTTIT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_PC_VLTOTTIT']; ?>" /></td>
                </tr>
                <tr>
                    <td>MVTO CONTA ITG</td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['VLMVTITG']; ?>" <?php echo ($arrRegist['0014']['BG_MVTO_CONTA_ITG'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0012']['VLMVTITG']; ?>" <?php echo ($arrRegist['0012']['BG_MVTO_CONTA_ITG'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_RS_VLMVTITG']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_PC_VLMVTITG']; ?>" /></td>
                </tr>
                <?php
            // RESULTADO
            } else {
                ?>
                <tr>
                    <td>ENTRADAS</td>
                    <td><input type="text" value="<?php echo $arrRegist['0013']['BB_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0011']['BB_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_RS_BB_IN']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_PC_BB_IN']; ?>" /></td>
                </tr>
                <tr>
                    <td>SAÍDAS</td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['BB_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0012']['BB_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_RS_BB_OUT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_PC_BB_OUT']; ?>" /></td>
                </tr>
                <tr>
                    <td>RESULTADO CENTRALIZAÇÃO</td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_BB_PROJETADO']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_BB_REALIZADO']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_RS_BB_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['0014']['DIF_PC_BB_SOMA']; ?>" /></td>
                </tr>
                <?php
            }
        ?>
        </table>
	</fieldset>

    <br />

	<fieldset id="fsetBANCOOB" name="fsetBANCOOB" style="padding:10px;">
	<legend> BANCOOB </legend>
        <table width="800" cellpadding="10" cellspacing="2" style="text-align:right; margin-right:20px;">
        <tr>
            <td width="200">&nbsp;</td>
            <td width="150" align="right">PROJETADO</td>
            <td width="150" align="right">REALIZADO</td>
            <td width="150" align="right">DIFERENÇA(R$)</td>
            <td width="150" align="right">DIFERENÇA(%)</td>
        </tr>
        <?php
            // Se for ENTRADA
            if ($tpdmovto == 'E') { 
                ?>
                <tr>
                    <td>INSS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7563']['VLTTINSS']; ?>" <?php echo ($arrRegist['7563']['BG_INSS'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7561']['VLTTINSS']; ?>" <?php echo ($arrRegist['7561']['BG_INSS'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_RS_VLTTINSS']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_PC_VLTTINSS']; ?>" /></td>
                </tr>
                <?php
            // Se for SAIDA
            } else if ($tpdmovto == 'S') {
                ?>
                <tr>
                    <td>CARTÃO DE CRÉDITO</td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['VLCARCRE']; ?>" <?php echo ($arrRegist['7564']['BG_CARTAO_CREDITO'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7562']['VLCARCRE']; ?>" <?php echo ($arrRegist['7562']['BG_CARTAO_CREDITO'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_RS_VLCARCRE']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_PC_VLCARCRE']; ?>" /></td>
                </tr>
                <tr>
                    <td>CARTÃO DE DÉBITO</td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['VLCARDEB']; ?>" <?php echo ($arrRegist['7564']['BG_CARTAO_DEBITO'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7562']['VLCARDEB']; ?>" <?php echo ($arrRegist['7562']['BG_CARTAO_DEBITO'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_RS_VLCARDEB']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_PC_VLCARDEB']; ?>" /></td>
                </tr>
                <tr>
                    <td>GPS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['VLTTINSS']; ?>" <?php echo ($arrRegist['7564']['BG_GPS'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7562']['VLTTINSS']; ?>" <?php echo ($arrRegist['7562']['BG_GPS'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_RS_VLTTINSS']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_PC_VLTTINSS']; ?>" /></td>
                </tr>                
                <tr><!-- PRJ406-FGTS Odirlei(AMcom) -->
                    <td>CONVÊNIOS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['VLCONVEN']; ?>" <?php echo ($arrRegist['7564']['BG_CONVENIOS'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7562']['VLCONVEN']; ?>" <?php echo ($arrRegist['7562']['BG_CONVENIOS'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_RS_VLCONVEN']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_PC_VLCONVEN']; ?>" /></td>
                </tr>
                
                
                <?php
            // RESULTADO
            } else {
                ?>
                <tr>
                    <td>ENTRADAS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7563']['BCO_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7561']['BCO_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_RS_BCO_IN']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_PC_BCO_IN']; ?>" /></td>
                </tr>
                <tr>
                    <td>SAÍDAS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['BCO_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7562']['BCO_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_RS_BCO_OUT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_PC_BCO_OUT']; ?>" /></td>
                </tr>
                <tr>
                    <td>RESULTADO CENTRALIZAÇÃO</td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_BCO_PROJETADO']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_BCO_REALIZADO']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_RS_BCO_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7564']['DIF_PC_BCO_SOMA']; ?>" /></td>
                </tr>
                <?php
            }
        ?>
        </table>
	</fieldset>

    <br />

	<fieldset id="fsetSICREDI" name="fsetSICREDI" style="padding:10px;">
	<legend> SICREDI </legend>
        <table width="800" cellpadding="10" cellspacing="2" style="text-align:right; margin-right:20px;">
        <tr>
            <td width="200">&nbsp;</td>
            <td width="150" align="right">PROJETADO</td>
            <td width="150" align="right">REALIZADO</td>
            <td width="150" align="right">DIFERENÇA(R$)</td>
            <td width="150" align="right">DIFERENÇA(%)</td>
        </tr>
        <?php
            // Se for ENTRADA
            if ($tpdmovto == 'E') { 
                ?>
                <tr>
                    <td>SR TED</td>
                    <td><input type="text" value="<?php echo $arrRegist['7483']['VLTOTTED']; ?>" <?php echo ($arrRegist['7483']['BG_SR_TED'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7481']['VLTOTTED']; ?>" <?php echo ($arrRegist['7481']['BG_SR_TED'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_RS_VLTOTTED']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_PC_VLTOTTED']; ?>" /></td>
                </tr>
                <tr>
                    <td>INSS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7483']['VLTTINSS']; ?>" <?php echo ($arrRegist['7483']['BG_INSS'] == 3 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7481']['VLTTINSS']; ?>" <?php echo ($arrRegist['7481']['BG_INSS'] == 1 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_RS_VLTTINSS']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_PC_VLTTINSS']; ?>" /></td>
                </tr>
                <?php
            // Se for SAIDA
            } else if ($tpdmovto == 'S') {
                ?>
                <tr>
                    <td>GPS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['VLTTINSS']; ?>" <?php echo ($arrRegist['7484']['BG_GPS'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7482']['VLTTINSS']; ?>" <?php echo ($arrRegist['7482']['BG_GPS'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_RS_VLTTINSS']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_PC_VLTTINSS']; ?>" /></td>
                </tr>
                <tr>
                    <td>CONVÊNIOS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['VLCONVEN']; ?>" <?php echo ($arrRegist['7484']['BG_CONVENIOS'] == 4 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7482']['VLCONVEN']; ?>" <?php echo ($arrRegist['7482']['BG_CONVENIOS'] == 2 ? 'class="clsDestacar"' : ''); ?> /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_RS_VLCONVEN']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_PC_VLCONVEN']; ?>" /></td>
                </tr>
                <?php
            // RESULTADO
            } else {
                ?>
                <tr>
                    <td>ENTRADAS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7483']['SIC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7481']['SIC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_RS_SIC_IN']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_PC_SIC_IN']; ?>" /></td>
                </tr>
                <tr>
                    <td>SAÍDAS</td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['SIC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7482']['SIC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_RS_SIC_OUT']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_PC_SIC_OUT']; ?>" /></td>
                </tr>
                <tr>
                    <td>RESULTADO CENTRALIZAÇÃO</td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_SIC_PROJETADO']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_SIC_REALIZADO']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_RS_SIC_SOMA']; ?>" /></td>
                    <td><input type="text" value="<?php echo $arrRegist['7484']['DIF_PC_SIC_SOMA']; ?>" /></td>
                </tr>
                <?php
            }
        ?>
        </table>
	</fieldset>

    <br />

    <?php
        // Se for ENTRADA ou SAIDA
        if ($tpdmovto == 'E' || $tpdmovto == 'S') { 
            ?>
            <fieldset id="fsetTOTAL" name="fsetTOTAL" style="padding:10px;">
            <legend> TOTALIZAÇÃO </legend>
                <table width="800" cellpadding="10" cellspacing="2" style="text-align:right; margin-right:20px;">
                <tr>
                    <td width="200">&nbsp;</td>
                    <td width="150" align="right">PROJETADO</td>
                    <td width="150" align="right">REALIZADO</td>
                    <td width="150" align="right">DIFERENÇA(R$)</td>
                    <td width="150" align="right">DIFERENÇA(%)</td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_PROJETADO'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_REALIZADO'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_RS'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_PC'); ?>" /></td>
                </tr>
                </table>
            </fieldset>
            <?php
        // RESULTADO
        } else {
            ?>
            <fieldset id="fsetTOTAL" name="fsetTOTAL" style="padding:10px;">
            <legend> RESULTADO TOTAL </legend>
                <table width="800" cellpadding="10" cellspacing="2" style="text-align:right; margin-right:20px;">
                <tr>
                    <td width="200">&nbsp;</td>
                    <td width="150" align="right">PROJETADO</td>
                    <td width="150" align="right">REALIZADO</td>
                    <td width="150" align="right">DIFERENÇA(R$)</td>
                    <td width="150" align="right">DIFERENÇA(%)</td>
                </tr>
                <tr>
                    <td>ENTRADAS</td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_PROJETADO_IN'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_REALIZADO_IN'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_RS_IN'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_PC_IN'); ?>" /></td>
                </tr>
                <tr>
                    <td>SAÍDAS</td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_PROJETADO_OUT'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_REALIZADO_OUT'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_RS_OUT'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_PC_OUT'); ?>" /></td>
                </tr>
                <tr>
                    <td>RESULTADO CENTRALIZAÇÃO</td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_PROJETADO'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_REALIZADO'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_RS_SOMA'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_DIF_PC_SOMA'); ?>" /></td>
                </tr>
                <tr>
                    <td>SALDO C/C ATUALIZADO</td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_VLSLDCTA'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_VLSLDCTA'); ?>" /></td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td>SALDO FINAL C/C</td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_SALDO_PROJETADO'); ?>" /></td>
                    <td><input type="text" value="<?php echo getByTagName($reg_total->tags,'TOT_SALDO_REALIZADO'); ?>" /></td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                </table>
            </fieldset>
            <?php
        }
    ?>

	<br style="clear:both" />

    <?php
        // Se for ENTRADA ou SAIDA
        if ($tpdmovto == 'E' || $tpdmovto == 'S') { 
            echo '<p style="font-size: 11px;">* Valores destacados em amarelo serão utilizados para o cálculo do fluxo do dia.</p>';
        }
    ?>
	
</form>

<script type="text/javascript">
    var cTodosFormulario = $('input[type="text"]', '#frmOpcaoF');
    cTodosFormulario.css('text-align', 'right').desabilitaCampo();
    $('.clsDestacar','#frmOpcaoF').css({'background-color': '#FFEFB5'});
    trocaBotao('','','btnVoltarOpcaoF()');
</script>