<?php
/*!
 * FONTE        : form_detalhe.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIAÇÃO : Março/2018
 * OBJETIVO     : Formulário para inclusão de horários
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

session_start();

require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');


 $cddopcao = $_POST['cddopcao'];
 $idhora_processamento = $_POST['idhora_processamento'];
 $dhprocessamento = $_POST['dhprocessamento'];
 $hh = '00';
 $mm = '00';

 $msgError = validaPermissao($glbvars["nmdatela"],$glbvars['nmrotina'],$cddopcao, false);

if ($msgError != '') {
    exibirErro('error', utf8ToHtml('Acesso não permitido.'), 'Alerta - Ayllos', 'estadoInicial()', false);
}	

 if (!empty($dhprocessamento)) {
     $partesHorario = explode(':', $dhprocessamento);
     $hh = $partesHorario[0];
     $mm = $partesHorario[1];
 }
?>

                    <form id="frmDet" name="frmDet" class="formulario detalhe" onSubmit="return false;" style="display:none; width: 50%; margin: auto;">
                        <fieldset>
                            <legend>Cadastro de hor&aacute;rios</legend>
                            <input type="hidden" id="idhora_processamento" name="idhora_processamento" value="<?php echo $idhora_processamento; ?>">
                            <label for="hh">Hor&aacute;rio:</label>
                            <input type="text" class="campoHora campo" id="hh" name="hh" value="<?php echo $hh; ?>">
                            <label for="mm"><b>:</b></label>
                            <input type="text" class="campoHora campo " id="mm" name="mm" value="<?php echo $mm; ?>">
                        </fieldset>
                    </form>
