<?php
/* !
 * FONTE        : form_manutencao.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 17/08/2015
 * OBJETIVO     : Tela do formulario de Manutenção Boletos Emprestimos
	 * ALTERACOES	: 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 */

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();
?>

<form id="frmManutencao" name="frmManutencao" class="formulario" onSubmit="return false;" >

    <label for="cdagenci">PA:</label>
    <input type="text" id="cdagenci" name="cdagenci" />	
    <a href="#" onclick="controlaPesquisaPac(); return false;" >
        <img style="margin-top:2px;" src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" />
    </a>
    
    <label for="nrdconta">Conta/DV:</label>
    <input type="text" id="nrdconta" name="nrdconta" class="conta" />	
    <a href="#" onclick="pesquisaAssociados(); return false;" >
        <img style="margin-top:2px;" src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" />
    </a>
    <input type="text" name="nmprimtl" id="nmprimtl" readonly />

    <label for="nrctremp">Contrato:</label>
    <input type="text" id="nrctremp" name="nrctremp" />	
    
    <br style="clear:both" />

    <label for="dtemissi">Data Emiss&atilde;o De:</label>
    <input type="text" id="dtemissi" name="dtemissi" />	
    <label for="dtemissf">At&eacute;:</label>
    <input type="text" id="dtemissf" name="dtemissf" />	

    <label for="dtvencti">Data Vencimento De:</label>
    <input type="text" id="dtvencti" name="dtvencti" />	
    <label for="dtvenctf">At&eacute;:</label>
    <input type="text" id="dtvenctf" name="dtvenctf" />	

    <br style="clear:both" />

    <label for="dtbaixai">Data Baixa De:</label>
    <input type="text" id="dtbaixai" name="dtbaixai" />	
    <label for="dtbaixaf">At&eacute;:</label>
    <input type="text" id="dtbaixaf" name="dtbaixaf" />	

    <label for="dtpagtoi">Data Pagamento De:</label>
    <input type="text" id="dtpagtoi" name="dtpagtoi" />	
    <label for="dtpagtof">At&eacute;:</label>
    <input type="text" id="dtpagtof" name="dtpagtof" />	

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