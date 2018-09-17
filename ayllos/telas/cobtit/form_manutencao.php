<?php
/* !
 * FONTE        : form_manutencao.php
 * CRIAÇÃO      : Luis Fernando (GFT)
 * DATA CRIAÇÃO : 02/06/2018
 * OBJETIVO     : Tela do formulario de Manutenção Boletos de Borderôes
 */

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<form id="frmManutencao" name="frmManutencao" class="formulario" onSubmit="return false;" >

    <label for="cdagenci">PA:</label>
    <input type="text" id="cdagenci" name="cdagenci" class="navigation"/>	
    <a href="#" onclick="controlaPesquisaPac(); return false;" >
        <img style="margin-top:2px;" src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" />
    </a>
    
    <label for="nrdconta">Conta/DV:</label>
    <input type="text" id="nrdconta" name="nrdconta" class="conta navigation"/>	
    <a href="#" onclick="pesquisaAssociados('M'); return false;" >
        <img style="margin-top:2px;" src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" />
    </a>
    <input type="text" name="nmprimtl" id="nmprimtl" readonlyclass="navigation" />

    <label for="nrborder">Border&ocirc;:</label>
    <input type="text" id="nrborder" name="nrborder" class="navigation"/>	
    
    <br style="clear:both" />

    <label for="dtemissi">Data Emiss&atilde;o De:</label>
    <input type="text" id="dtemissi" name="dtemissi" class="navigation"/>	
    <label for="dtemissf">At&eacute;:</label>
    <input type="text" id="dtemissf" name="dtemissf" class="navigation"/>	

    <label for="dtvencti">Data Vencimento De:</label>
    <input type="text" id="dtvencti" name="dtvencti" class="navigation"/>	
    <label for="dtvenctf">At&eacute;:</label>
    <input type="text" id="dtvenctf" name="dtvenctf" class="navigation"/>	

    <br style="clear:both" />

    <label for="dtbaixai">Data Baixa De:</label>
    <input type="text" id="dtbaixai" name="dtbaixai" class="navigation"/>	
    <label for="dtbaixaf">At&eacute;:</label>
    <input type="text" id="dtbaixaf" name="dtbaixaf" class="navigation"/>	

    <label for="dtpagtoi">Data Pagamento De:</label>
    <input type="text" id="dtpagtoi" name="dtpagtoi" class="navigation"/>	
    <label for="dtpagtof">At&eacute;:</label>
    <input type="text" id="dtpagtof" name="dtpagtof" class="navigation"/>	

    <br style="clear:both" />

</form>

<div id="divTabfrmManutencao" name="divTabfrmManutencao" style="display:none; margin-top:15px;">
</div>	

<form class="formulario" id="frmImpBoleto" style="display: none">
</form>    

<div id="divBotoesfrmManutencao" style="display:none; margin-bottom: 15px; text-align:center; margin-top: 15px;" >
    <a href="#" class="botao" id="btVoltar"  		onClick="btnVoltar(); return false;">Voltar</a>
    <a href="#" class="botao" id="btBaixar"  		onClick="confirmaBaixaBoleto(); return false;">Baixar</a>
    <a href="#" class="botao" id="btEnviarEmail"  	onClick="enviarEmail(); return false;">Enviar E-mail</a>
    <a href="#" class="botao" id="btEnviarSMS"  	onClick="enviarSMS(); return false;">Enviar SMS</a>
    <a href="#" class="botao" id="btImprimir"  		onClick="confirmaImpressaoBoleto(); return false;">Imprimir</a>
    <a href="#" class="botao" id="btLogs"           onClick="consultarLog(1, 10); return false;">Logs</a>
    <a href="#" class="botao" id="btTelefones"  	onClick="consultarTelefone(1, 10); return false;"  style="margin-left: 30px;">Telefones</a>
    <a href="#" class="botao" id="btEmails"  		onClick="consultarEmail(1, 10); return false;">E-mails</a>
</div>