<?php
/*!
* FONTE        : form_demonstracao_emprestimo.php
* CRIAÇÃO      : Rafael B. Arins (Envolti)
* DATA CRIAÇÃO : 07/06/2018
* OBJETIVO     : Formulário de demonstração do IOF

ALTERACOES     :

*/

?>
<div id="divProcDemonstEmprestimoFormulario">
    <form name="frmDemonstracaoEmprestimo" id="frmDemonstracaoEmprestimo" class="formulario">
        <fieldset>
            <legend><? echo utf8ToHtml('Demonstração da operação de empréstimo') ?></legend>

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

            <label for="vlpreemp">Prest.:</label>
            <input name="vlpreemp" id="vlpreemp" type="text" value="" />

            <?php if ($tpemprst == 2) { ?>
            <label for="vlprecar"><? echo utf8ToHtml('Vl. parcela carên.:') ?></label>
            <input name="vlprecar" id="vlprecar" type="text" value="" />
            <?php } ?>

            <label for="percetop">CET(%a.a.):</label>
            <input name="percetop" id="percetop" type="text" value="" />
            <br />

        </fieldset>
    </form>
    <div id="divBotoesFormSimulacao" style="margin-top:5px; margin-bottom:5px;">
        <? if ( $operacao == 'C_DEMONSTRATIVO_EMPRESTIMO' ) { ?>
            <a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('C_PROT_CRED'); return false;">Voltar</a>
            <a href="#" class="botao" id="btSalvar"  onClick="controlaOperacao('TC'); return false;">Continuar</a>
        <? } ?>
    </div>
</div>

<script>

    $(document).ready(function() {
        highlightObjFocus($('#frmDemonstracaoEmprestimo'));
    });

</script>
