<?php
/* !
 * FONTE        : form_opcao_n.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 22/01/2018 
 * OBJETIVO     : Formulario que apresenta a opcao N da tela CUSTOD
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

include('form_cabecalho.php');
?>

<form id="frmOpcao" class="formulario">

    <input type="hidden" id="cddopcao" name="cddopcao" value="" />
    <input type="hidden" id="inresgat" name="inresgat" value="" />
    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

    <fieldset>
        <legend> Filtro </legend>    

        <label for="nrdconta">Conta:</label>
        <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

        <input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />

        <label for="dtresgat"><? echo utf8ToHtml('Data do Resgate:') ?></label>
        <input type="text" id="dtresgat" name="dtresgat"/>

        <label for="nrcheque"><? echo utf8ToHtml('Número do Cheque:') ?></label>
        <input type="text" id="nrcheque" name="nrcheque"/>

    </fieldset>     

    <div id="divCheques">
      
    </div>

</form>

<div id="divBotoes" style="padding-bottom:10px">
    <a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btProsseguir" onclick="btnContinuar(); return false;" >Prosseguir</a>
    <a href="#" class="botao" id="btImprimir" onclick="geraImpressaoComprovante(frmOpcao); return false;" style="display:none">Imprimir</a>
</div>
