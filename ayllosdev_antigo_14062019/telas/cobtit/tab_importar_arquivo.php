<?php
/* !
 * FONTE        : tab_arquivo.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 15/06/2018
 * OBJETIVO     : Rotina para envio do arquivo.
 */
?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<form id="frmNomArquivo" name="frmNomArquivo" class="formulario" onSubmit="return false;" >
    <input type="hidden" id="flgreimp" name="flgreimp" value="0" />
    <br style="clear:both" />

    <fieldset>
        <legend align="left" style="font-weight:bold;">Nome do Arquivo</legend>
        <input type="text" id="nmarquiv" name="nmarquiv" />
        <div style="margin-left:5px; margin-bottom:7px; text-align:left; font-size:10px;">
            Ex: BM_DDMMAAAA_SS.csv
        </div>
        <div style="margin-left:22px; text-align:left; font-size:10px;">
            BM: Boletagem Massiva<br />
            DD: Dia com 2 d&iacute;gitos<br />
            MM: M&ecirc;s com 2 d&iacute;gitos<br />
            AAAA: Ano com 4 d&iacute;gitos<br />
            SS: Sequencial (Ex: 01)<br />
            .csv: Extens&atilde;o do Arquivo
        </div>
    </fieldset>

    <br style="clear:both" />

</form>

<div id="divBotoesEnviarEmail" style="margin-bottom: 5px; text-align:center;" >
    <a href="#" class="botao" id="btVoltar" onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
    <a href="#" class="botao" id="btEnviar" onClick="<?php echo 'confirmaImportacao(); '; ?> return false;">Importar</a>
</div>