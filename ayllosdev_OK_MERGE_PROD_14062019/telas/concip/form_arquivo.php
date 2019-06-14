<?php
/* !
 * FONTE        : form_arquivo.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Tela do formulario
 * --------------
 * ALTERAÇÕES   : 23/07/2018 - Adicionado campo de Liquidação no Filtro (PRJ 486 - Mateus Z / Mouts)
 * --------------
 */
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

    <!-- Filtro tipo de arquivo -->
    <label for="tpArquivo">&nbsp;<?php echo utf8ToHtml('Tipo:'); ?></label>
    <select id="tpArquivo" name="tpArquivo">
        <option value="0"><?php echo utf8ToHtml('--'); ?></option>
        <option value="1"><?php echo utf8ToHtml('CR'); ?></option>
        <option value="2"><?php echo utf8ToHtml('DB'); ?></option>
        <option value="3"><?php echo utf8ToHtml('AT'); ?></option>
    </select>

    <!-- Filtro banco Liquidante -->
    <label for="bcoliquidante">&nbsp;<?php echo utf8ToHtml('Banco Liquidante:'); ?></label>
    <select id="bcoliquidante" name="bcoliquidante" style="min-width:100px;max-width:130px;"></select>
    
    <!-- Filtro credenciadora -->
    <label for="credenciadora">&nbsp;<?php echo utf8ToHtml('Credenciadora:'); ?></label>
    <select id="credenciadora" name="credenciadora" style="min-width:100px;max-width:120px;"></select>

    <!-- PRJ 486 -->
    <label for="dtinicioliq"><?php echo utf8ToHtml('Liquidação:') ?></label>
    <input type="text" id="dtinicioliq" name="dtinicioliq" value="<?php echo $glbvars['dtmvtolt'] ?>"/>
    <label for="dtfinalliq"><?php echo utf8ToHtml('Ate:') ?></label>
    <input type="text" id="dtfinalliq" name="dtfinalliq" value="<?php echo $glbvars['dtmvtolt'] ?>"/>
    <!-- Fim PRJ 486 -->

    <!-- Forma transferencia -->
    <label for="formtran">Forma Transf:</label>
    <select id="formtran" name="formtran">
       <option value="0">Todas</option>
       <option value="3"><?php echo utf8ToHtml('LDL/LTR – 3'); ?></option>
       <option value="5"><?php echo utf8ToHtml('STR – 5'); ?></option>
    </select>

    <br style="clear:both" />
</form>

<div id="divListaArquivo" name="divListaArquivo" style="display:none;"></div>

<div id="divBotoesArquivo" style="display:none; margin-bottom: 15px; text-align:center; margin-top: 15px;" >
    <a href="#" class="botao" id="btVoltar"  onClick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btConsultar"  onClick="controlaOperacao('A'); return false;">Consultar</a>
    <a href="#" class="botao" id="btExportar" onClick="controlaOperacao('E'); return false;">Exportar</a>
</div>

<form class="formulario" id="frmExporta" style="display: none"></form>