<!DOCTYPE html>
<?php
/*!
 * FONTE        : form_consulta_imagem.php
 * CRIA��O      : Fabricio
 * DATA CRIA��O : 18/06/2012
 * OBJETIVO     : Mostrar campos da tela IMGCHQ.
 * --------------
 * ALTERA��ES   : 23/07/2012 - Ajuste para utilizar recurdo de calendario de UI Jquery. (Jorge)
 *                26/03/2013 - Ajustado a tela para novo layout padr�o (David Kruger).
 *                03/11/2014 - Adicionar campos e o link para o cart�o assinatura (Douglas - Chamado 177877)
 *                12/05/2015 - Trocado funcao do botao Gerar PDF. (Jorge/Elton) - SD 283911
 *                15/03/2016 - Projeto 316 - Novo bot�o para Salvar Imagem (Guilherme/SUPERO)
 * --------------
 */

?>
<style>
.ui-datepicker-trigger{
    float:left;
    margin-left:2px;
    margin-top:5px;
}
</style>
<script language="javascript">

    $(document).ready(function() {

        $("#dtcompen").val(" ");
        $("#dtcompen").setMask("DATE","","","divRotina");

        $.datepicker.setDefaults( $.datepicker.regional[ "pt-BR" ] );

        $( "#dtcompen" ).datepicker({
            defaultDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
            minDate: "-100Y",
            maxDate: "<?php echo $glbvars["dtmvtolt"]; ?>",
            showOn: "button",
            buttonImage: UrlSite + "imagens/geral/btn_calendario.gif",
            buttonImageOnly: true,
            buttonText: "Calendario"
        });

        $( "#dtcompen" ).datepicker( "option", "dateFormat", "dd/mm/yy" );
        $( "#dtcompen" ).datepicker( "option", "gotoCurrent", true );

    });
</script>

<div id="divConsultaImagem">
<form id="frmConsultaImagem" name="frmConsultaImagem" class="formulario">

    <hr style="background-color:#666; height:1px;" />

    <input type="hidden" name="hdnCooper" id="hdnCooper" value="<?php echo($glbvars["cdcooper"]); ?>" />
    <input type="hidden" name="hdnServSM" id="hdnServSM" value="<?php echo($GEDServidor); ?>" />

    <div id="divCooper">
        <label for="nmrescop"><?php echo utf8ToHtml('Cooperativa:') ?></label>
        <select id="nmrescop" name="nmrescop" onChange="buscaAgeCtl(1);">
        </select>
    </div>

    <label for="tiporeme"><?php echo utf8ToHtml('Remessa:') ?></label>
    <select id="tiporeme" name="tiporeme" onChange="mostraCamposChq();" class="campo" style="width: 300px;">
        <option></option>
        <option value="N"> Cheques Depositados (Nossa Remessa) </option>
        <option value="S"> Cheques da Cooperativa (Sua Remessa) </option>
    </select>

    <br style="clear:both;" />
    <hr style="background-color:#666; height:1px;" />
    <br/>

    <div id="divDadosChq">
    <fieldset style=" width:650px; margin-left:60px;">

        <label for="dtcompen"><?php echo utf8ToHtml('Data Compensa&ccedil;&atilde;o:') ?></label>
        <input id="dtcompen" name="dtcompen" type="text" size="10" maxlength="10" class="txtNormal" />

        <label for="bancochq"><?php echo utf8ToHtml('Banco do Cheque:') ?></label>
        <input id="bancochq" name="bancochq" type="text" size="3" maxlength="3" class="txtNormal"/>

        <div id="cartaoas"><a style="margin-left: 265px; margin-top: 7px; cursor:default">&nbsp;&nbsp;Cart&atilde;o Ass.</a> </div>

        </br>

        <label for="compechq"><?php echo utf8ToHtml('Compe do Cheque:') ?></label>
        <input id="compechq" name="compechq" type="text" size="3" maxlength="3" class="txtNormal"/>

        <label for="agencchq"><?php echo utf8ToHtml('Ag&ecirc;ncia do Cheque:') ?></label>
        <input id="agencchq" name="agencchq" type="text" size="4" maxlength="4" class="txtNormal"/>

        </br>

        <label for="contachq"><?php echo utf8ToHtml('Conta do Cheque:') ?></label>
        <input id="contachq" name="contachq" type="text" size="10" maxlength="10" class="txtNormal" onBlur="validarNumeroConta();"/>

        <label for="numerchq"><?php echo utf8ToHtml('N&uacute;mero do Cheque:') ?></label>
        <input id="numerchq" name="numerchq" type="text" size="6" maxlength="6" class="txtNormal"/>

    </fieldset>
    </div>

    <div id="divBotoes" style="margin-top:5px; margin-bottom :10px;display:none;">
        <a class="botao" href="" id="btnProcurar" onClick="preConsultaCheque();return false;" >Procurar</a>
        <a class="botao" href="" id="btnGerarPdf" width="76" height="20" border="0" onClick="preGerarPDF();return false;">Gerar PDF</a>
        <?php if (in_array("S", $opcoesTela) && $glbvars['cdcooper'] == 3) { ?>
        <a class="botao" href="" id="btnSalvarImg" width="76" height="20" border="0" onClick="SalvarZip();return false;">Salvar Imagens</a>
        <?php }?>

    </div>

    <br/>
    <br style="clear:both;" />

    <div id="divImagem">
    </div>

</form>
</div>
