<?php
/* !
 * FONTE        : form_conta.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/08/2015
 * OBJETIVO     : Tela do formulario de Contas
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

<form id="frmConta" name="frmConta" class="formulario" onSubmit="return false;" style="display: none" >
    
    <label for="cdcooper"><?php echo utf8ToHtml('Coop:') ?></label>
    <input type="text" id="cdcooper" name="cdcooper" />	
    <a href="#" onclick="pesquisaCooperativa(); return false;" >
        <img style="margin-top:2px;" src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" />
    </a>
    <input type="text" name="nmrescop" id="nmrescop" readonly="true" />
    
    <label for="cddregio"><?php echo utf8ToHtml('Regional:') ?></label>
    <input type="text" id="cddregio" name="cddregio" />	
    <a href="#" onclick="pesquisaRegional(); return false;" >
        <img style="margin-top:2px;" src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" />
    </a>
    <input type="text" name="dsdregio" id="dsdregio" readonly="true" />

    <label for="cdagenci"><?php echo utf8ToHtml('PA:') ?></label>
    <input type="text" id="cdagenci" name="cdagenci" />	
    <a href="#" onclick="pesquisaPA(); return false;" >
        <img style="margin-top:2px;" src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" />
    </a>
    <input type="text" id="nmresage" name="nmresage" readonly="true"/>	
    
     <br style="clear:both" />

    <label for="dtlanini"><?php echo utf8ToHtml('Periodo Lct:') ?></label>
    <input type="text" id="dtlanini" name="dtlanini" />	
    <label for="dtlanfim"><?php echo utf8ToHtml('Ate:') ?></label>
    <input type="text" id="dtlanfim" name="dtlanfim" />	
    
    <label for="dtarqini"><?php echo utf8ToHtml('Periodo Arq:') ?></label>
    <input type="text" id="dtarqini" name="dtarqini" />	
    <label for="dtarqfim"><?php echo utf8ToHtml('Ate:') ?></label>
    <input type="text" id="dtarqfim" name="dtarqfim" />	
    
    <label for="cdlancto">Lan&ccedil;amento:</label>
    <select id="cdlancto" name="cdlancto">
        <option value="">Todos</option> 
        <option value="CR">Credito</option> 
        <option value="DB">Debito</option> 
        <option value="AT">Antecipacao</option> 
    </select>
    
    <br style="clear:both" />
    
    <label for="nmarquiv"><?php echo utf8ToHtml('Arquivo:') ?></label>
    <input type="text" id="nmarquiv" name="nmarquiv" />	
    
    <label for="cdsituac">Situa&ccedil;&atilde;o:</label>
    <select id="cdsituac" name="cdsituac">
       <option value="">Todas</option> 
       <option value="0">Pendente</option> 
       <option value="1">Processado</option> 
       <option value="2">Erro</option> 
    </select>

    <br style="clear:both" />

</form>

<div id="divListaConta" name="divListaConta" style="display:none; margin-top:15px;">	
</div>	

<div id="divBotoesConta" style="display:none; margin-bottom: 15px; text-align:center; margin-top: 15px;" >
    <a href="#" class="botao" id="btVoltar"  	onClick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btVoltarArq"  	onClick="chamaRotinaArquivo(); return false;">Voltar</a>
    <a href="#" class="botao" id="btConsultar"  onClick="controlaOperacao('C'); return false;">Consultar</a>
    <a href="#" class="botao" id="btExportar"  	onClick="exportaContas(); return false;">Exportar</a>
</div>

<form class="formulario" id="frmExporta" style="display: none">
</form>