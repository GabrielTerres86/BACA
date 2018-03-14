<? 
/*!
 * FONTE        : form_cadris.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 25/04/2016
 * OBJETIVO     : Formulario do cadastro.
 * --------------
 * ALTERAÇÕES   : 
 
    14/02/2018 - #822034 Alterada a forma como é criado o xml para ganhar performance;
                 inclusão de filtro de contas e ordenação por conta;
                 tela não carrega mais todas as contas ao entrar nas opções (Carlos)

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
        <!-- Campos aparecem apenas nas ops C e E -->
        <label for="ctaini" class="clsConta"><?php echo 'Da conta:' ?></label>        
        <input type="text" id="ctaini" name="ctaini" class="clsConta" />

        <label for="ctafim" class="clsConta"><?php echo ' a '; ?></label>        
        <input type="text" id="ctafim" name="ctafim" class="clsConta" />
        
        <button class="botao" id="btnOK2" name="btnOK2" style="text-align:right; margin:2px" 
                onclick="listaContas(); return false;">OK</button>
        
        <!-- Fim Campos aparecem apenas nas ops C e E -->
        
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