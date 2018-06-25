<?php
/* !
 * FONTE        : form_arquivos.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 14/06/2018
 * OBJETIVO     : Tela do formulario de Arquivos de Boletagem Massiva para Títulos descontados
 * --------------
 * ALTERACOES	:
 * --------------
 */

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<form id="frmArquivos" name="frmArquivos" class="formulario" onSubmit="return false;">

    <label for="dtarqini">Data De:</label>
    <input type="text" id="dtarqini" name="dtarqini" dtini="<?php echo '01'.substr($glbvars["dtmvtolt"],2,8); ?>" class="navigation"/>
    <label for="dtarqfim">At&eacute;:</label>
    <input type="text" id="dtarqfim" name="dtarqfim" dtfim="<?php echo $glbvars["dtmvtolt"]; ?>" class="navigation"/>

    <label for="nmarquiv">Nome do Arquivo:</label>
    <input type="text" id="nmarquiv" name="nmarquiv" class="navigation"/>

    <a href="#" class="botao" id="btEnviar" onClick="carregaArquivos(1,15); return false;">Consultar</a>

    <br style="clear:both" />

</form>

<div id="divTabfrmArquivos" name="divTabfrmArquivos" style="display:none;"></div>

<form class="formulario" id="frmImpBoleto" style="display: none"></form>

<div id="divBotoesfrmArquivos" style="display:none; margin-bottom: 15px; text-align:center; margin-top: 15px;" >
    <a href="#" class="botao" id="btVoltar"   onClick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btImprimir" onClick="btnImprimir(); return false;">Imprimir</a>
    <a href="#" class="botao" id="btArquivo"  onClick="abreImportacao(); return false;" style="margin-left: 30px;">Importar Arquivo</a>
    <a href="#" class="botao" id="btGerar"    onClick="confirmaGerarBoleto(); return false;">Gerar Boletos</a>
    <a href="#" class="botao" id="btArquivo"  onClick="confirmaGerarArquivoParceiro(); return false;" style="margin-left: 30px;">Gerar Arquivo Parceiro</a>
</div>
