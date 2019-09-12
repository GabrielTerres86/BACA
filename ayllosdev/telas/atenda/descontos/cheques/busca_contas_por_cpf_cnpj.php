<?php
/* !
 * FONTE        : busca_contas_por_cpf_cnpj.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 18/10/2018
 * OBJETIVO     : Buscar as contas do CPF/CNPJ digitado e exibir em uma tabela para selecionar	  
 * ALTERAÇÕES   : 
 * --------------
 *
 */

session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
isPostMethod();

$nrcpfcgc       = (isset($_POST['nrcpfcgc']))       ? $_POST['nrcpfcgc']       : '';
$nomeCampoConta = (isset($_POST['nomeCampoConta'])) ? $_POST['nomeCampoConta'] : '';
$nomeForm       = (isset($_POST['nomeForm']))       ? $_POST['nomeForm']       : '';

$xml  = '';
$xml .= '<Root>';
$xml .= '   <Dados>';
$xml .= '        <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
$xml .= '    </Dados>';
$xml .= '</Root>';

$xmlResult = mensageria($xml, "CADA0003", "BUSCAR_CONTAS_POR_CPF_CNPJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
    exibirErro('error',utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata),'Alerta - Aimaro','',false);
}

$contas = $xmlObjeto->roottag->tags;

// Se não retornou contas, apenas voltar e não mostrar critica
if(count($contas) == 0){
    exit;
}

// Se a proc reteornar apenas 1 conta, entao colocar essa conta no campo conta
if (count($contas) == 1) {
    $conta = formataContaDV(getByTagName($contas[0]->tags,'nrdconta'));
    echo "$('#". $nomeCampoConta. "','#". $nomeForm. "').val(\"$conta\");";
    echo "$('#". $nomeCampoConta. "','#". $nomeForm. "').trigger('keydown',{keyCode: 13});";
    exit;
}

?>
<table id="tbContasCpfCnpj" cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="300">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11" id="tdTitTelaEmp"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag SetFoco" id="tdTitTelaSim" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Contas do Avalista</td>
                                <td width="12" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'), $('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>     
                    </td> 
                </tr>    
                <tr>
                    <td class="tdConteudoTela" align="center">	
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <table border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" align="center" style="border: 1px solid #969FA9; background-color: #F4F3F0; padding: 0px;">
                                    <div id="divConteudoOpcao">
                                        <?
                                        include("tabela_contas_por_cpf_cnpj.php"); 
                                        ?>
                                    </div>
                                </td>
                            </tr>
                        </table>			    
                    </td> 
                </tr>
            </table>
        </td>
    </tr>
</table>