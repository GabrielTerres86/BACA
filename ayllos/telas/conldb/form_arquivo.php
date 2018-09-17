<?php
/* !
 * FONTE        : form_arquivo.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Tela do formulario
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

<form id="frmArquivo" name="frmArquivo" class="formulario" onSubmit="return false;" style="display: none">

    <label for="dtinicio"><?php echo utf8ToHtml('Periodo:') ?></label>
    <input type="text" id="dtinicio" name="dtinicio" value="<?php echo $glbvars['dtmvtolt'] ?>"/>	
    <label for="dtafinal"><?php echo utf8ToHtml('Ate:') ?></label>
    <input type="text" id="dtafinal" name="dtafinal" value="<?php echo $glbvars['dtmvtolt'] ?>"/>
    <br style="clear:both" />

</form>

<div id="divListaArquivo" name="divListaArquivo" style="display:none;">	
</div> 

<div id="divBotoesArquivo" style="display:none; margin-bottom: 15px; text-align:center; margin-top: 15px;" >
    <a href="#" class="botao" id="btVoltar"  onClick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btConsultar"  onClick="controlaOperacao('A'); return false;">Consultar</a>
</div>