<?php
/*!
* FONTE        : form_demonstracao_emprestimo.php
* CRIAÇÃO      : Diogo Carlassara (MoutS)
* DATA CRIAÇÃO : 26/06/2011 
* OBJETIVO     : Formulário de demonstração do IOF

ALTERACOES     : 28/06/2019 - Ajustado botão continuar para a nova operação "C_DEMONSTRATIVO_EMPRESTIMO" 
                              PRJ 438 - Sprint 13 (Mateus Z / Mouts)

*/	

?>
<div id="divProcDemonstEmprestimoFormulario">
    <form name="frmDemonstracaoEmprestimo" id="frmDemonstracaoEmprestimo" class="formulario">
        <fieldset>
            <legend><? echo utf8ToHtml('Demonstração da simulação de empréstimo') ?></legend>

            <label for="vlemprst">Valor:</label>
            <input name="vlemprst" id="vlemprst" type="text" value="" />

            <label for="vliofepr">IOF:</label>
            <input name="vliofepr" id="vliofepr" type="text" value=""/>
            <br />

            <label for="vlrtarif">Tarifa:</label>
            <input name="vlrtarif" id="vlrtarif" type="text" value=""/>

            <label for="vlrtotal">Valor Financiado:</label>
            <input name="vlrtotal" id="vlrtotal" type="text" value=""/>
            <br />

            <label for="vlpreemp">Prest. Estim.:</label>
            <input name="vlpreemp" id="vlpreemp" type="text" value="" />

            <?php if ($tpemprst == 2) { ?>
            <br />
            <label for="vlprecar"><?php echo utf8ToHtml('Prest. Carên. Estim.:') ?></label>
            <input name="vlprecar" id="vlprecar" type="text" value="" />
            <?php } ?>

            <label for="percetop">CET(%a.a.):</label>
            <input name="percetop" id="percetop" type="text" value="" />
            <br />

        </fieldset>
    </form>
    <div id="divBotoesFormSimulacao" style="margin-top:5px; margin-bottom:5px;">
        <? if ( $operacao == 'A_DEMONSTRATIVO_EMPRESTIMO' ) { ?>
            <a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
            <a href="#" class="botao" id="btSalvar"  onClick="controlaOperacao('A_FINALIZA'); return false;">Continuar</a>
        <? } else if ( $operacao == 'I_DEMONSTRATIVO_EMPRESTIMO' ) {?>
            <a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
            <a href="#" class="botao" id="btSalvar"  onClick="controlaOperacao('I_FINALIZA'); return false;">Continuar</a>
        <? } else { // PRJ 438 - Sprint 13 - Se for C_DEMONSTRATIVO_EMPRESTIMO (Mateus Z)?> 
            <a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('C_INICIO'); return false;">Voltar</a>
            <a href="#" class="botao" id="btSalvar"  onClick="controlaOperacao(''); return false;">Continuar</a>
        <? } ?>
    </div>
</div>

<script>

    $(document).ready(function() {
        highlightObjFocus($('#frmDemonstracaoEmprestimo'));
    });

</script>