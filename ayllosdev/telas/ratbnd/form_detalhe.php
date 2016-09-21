<?
/*!
 * FONTE        : form_detalhe.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 21/11/2013
 * OBJETIVO     : Formulário de detalhes - Tela RATBND
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?
    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<div id="divDetalhe">
    <form id="frmDetalhe" name="frmDetalhe" class="formulario" style="display:none">
        <fieldset>
            <br/>
            <label for="nrinfcad"><? echo utf8ToHtml('Inf. Cadastrais:') ?></label>
            <input id="nrinfcad" name="nrinfcad" type="text" value="<? echo $nrinfcad;?>"/>
            <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
            <input id="dsinfcad" name="dsinfcad" type="text" value="<? echo $dsinfcad;?>"/>

            <br/>
            <label for="nrgarope"><? echo utf8ToHtml('Garantia:') ?></label>
            <input id="nrgarope" name="nrgarope" type="text" value="<? echo $nrgarope;?>"/>
            <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
            <input id="dsgarope" name="dsgarope" type="text" value="<? echo $dsgarope;?>"/>

            <br/>
            <label for="nrliquid"><? echo utf8ToHtml('Liquidez:') ?></label>
            <input id="nrliquid" name="nrliquid" type="text" value="<? echo $nrliquid;?>"/>
            <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
            <input id="dsliquid" name="dsliquid" type="text" value="<? echo $dsliquid;?>"/>

            <? if ($inpessoa == 2) { ?>
                <br/>
                <label for="nrpatlvr"><? echo utf8ToHtml('Patr. garant./s&oacute;cios s/onus:') ?></label>
                <input id="nrpatlvr" name="nrpatlvr" type="text" value="<? echo $nrpatlvr;?>"/>
                <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                <input id="dspatlvr" name="dspatlvr" type="text" value="<? echo $dspatlvr;?>"/>

                <br/>
                <label for="nrperger"><? echo utf8ToHtml('Percepcao geral com rela&ccedil;&atilde;o a empresa:') ?></label>
                <input id="nrperger" name="nrperger" type="text" value="<? echo $nrperger;?>"/>
                <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                <input id="dsperger" name="dsperger" type="text" value="<? echo $dsperger;?>"/>
                <br />
            <? } else { ?>
                <br/>
                <label for="nrpatlvr"><? echo utf8ToHtml('Patr. pessoal livre:') ?></label>
                <input id="nrpatlvr" name="nrpatlvr" type="text" value="<? echo $nrpatlvr;?>"/>
                <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                <input id="dspatlvr" name="dspatlvr" type="text" value="<? echo $dspatlvr;?>"/>
            <? } ?>

            <br/>

            <input id="vlctrbnd" name="vlctrbnd" type="hidden" value="<? echo formataMoeda($vlctrbnd);?>"/>
            <input id="qtparbnd" name="qtparbnd" type="hidden" value="<? echo $qtparbnd;?>"/>
            <br/>
        </fieldset>
    </form>
</div>
<div id="divSituacao">
</div>

<script>

    $(document).ready(function() {

         highlightObjFocus($('#frmDetalhe'));
    });

</script>