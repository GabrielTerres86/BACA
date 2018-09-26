<?php
/* !
 * FONTE        : form_acionamentos.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 22/03/2016 
 * OBJETIVO     : Rotina para controlar a busca de acionamentos
 * --------------
 * ALTERAÇÕES   : 18/04/2017 - Alterações referentes ao projeto 337 - Motor de Crédito. (Reinert)
 *                12/06/2017 - Retornar o protocolo. (Jaison/Marcos - PRJ337)
                  15/04/2018 - Alteração para carregar propostas dos contratos (Leonardo Oliveira - GFT)
				  19/04/2018 - Adaptação da tela para quando for selecionardo uma proposta. (Leonardo Oliveira - GFT)
 * -------------- 
 */
?>

<?php
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
session_start();
require_once("../../../../includes/config.php");
require_once("../../../../includes/funcoes.php");	
require_once("../../../../includes/controla_secao.php");	
require_once("../../../../class/xmlfile.php");	
isPostMethod();


require_once("../../../../includes/carrega_permissoes.php");

setVarSession("opcoesTela",$opcoesTela);

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"D")) <> "") {
    exibeErro($msgError);       
}   



    // Função para exibir erros na tela através de javascript
    function exibeErro($msgErro) { 
        echo 'hideMsgAguardo();';
        echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
        exit();
    }




$tipo = (isset($_POST['tipo'])) ? $_POST['tipo'] : "CONTRATO";
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0;  //contrato
$nrctrmnt = (isset($_POST['nrctrmnt'])) ? $_POST['nrctrmnt'] : 0;  //proposta

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "   <nrctrlim>" . $nrctrlim . "</nrctrlim>";
    $xml .= "   <nrctrmnt>" . $nrctrmnt . "</nrctrmnt>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "OBTEM_PROPOSTA_ACIONA",
     $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
        $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);


    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	   echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Aimaro","bloqueiaFundo(divRotina);fecharRotinaGenerico(\''.$tipo.'\');");';
        exit;
    }

    $propostas = $xmlObj->roottag->tags[0]->tags;

    

    if($nrctrlim==0)
    {
        $nrctrlim = getByTagName($propostas->tags[0]->tags, 'nrctrlim');
    }
    echo '<script type="text/javascript">';
    echo '    $("nrprolim", "#tabForm").val("'.$nrctrlim.'");';
    echo '    nrctrlim = '.$nrctrlim.';';
    echo '    carregarAcionamentosDaProposta("'.$tipo.'",nrctrlim);';
    echo '</script>';

?>
<div id="divResultadoAciona">
    <fieldset id="divForm">
        <div id="divFormContent">

            <input id="tipo" name ="tipo" type="hidden" value="<? echo $tipo ?>"/>
            <input id="nrctrmnt" name ="nrctrmnt" type="hidden" value="<? echo $nrctrmnt ?>"/>
            <label for="nrctrlim"><? echo utf8ToHtml('Proposta: ') ?></label>
            
            <?php 
                //propsta
                if($tipo === "PROPOSTA"){ ?>

                    <?php foreach($propostas as $p){ ?> 
                        <?php 
                            $valor_retira_ponto_virgula = str_replace(",","",getByTagName($p->tags, 'vllimite'));
                            $valor_retira_ponto_virgula = str_replace(".","",$valor_retira_ponto_virgula);
                            $valor_formatado = formataNumericos('zzz.zz9,99',$valor_retira_ponto_virgula,'.,'); 
                            $value = getByTagName($p->tags, 'nrctrlim').' - '.getByTagName($p->tags, 'dtpropos').' - '.$valor_formatado;
                        ?>

                        <input id="nrctrlim" name ="nrctrlim" type="text" value="<? echo $value ?>"/>

                <?php
                    break;
                    } // end for each ?>

            <?php
                //contrato
                } else { // else?>

                <select id="nrctrlim" name ="nrctrlim" >
                <?php foreach($propostas as $p){ ?> 
                    <option 
                        value="<? echo getByTagName($p->tags, 'nrctrlim');?>">
                        <?php 
                            $valor_retira_ponto_virgula = str_replace(",","",getByTagName($p->tags, 'vllimite'));
                            $valor_retira_ponto_virgula = str_replace(".","",$valor_retira_ponto_virgula);
                            $valor_formatado = formataNumericos('zzz.zz9,99',$valor_retira_ponto_virgula,'.,'); 
                            echo  getByTagName($p->tags, 'nrctrlim').' - '.getByTagName($p->tags, 'dtpropos').' - '.$valor_formatado;
                        ?>
                    </option>
                <?php } // end for each ?>

            <?php } // end if ?>
            </select>
        </div>
    </fieldset>
    <fieldset id="tabConteudo">
        <legend id="tabConteudoLegend" ><b><?= utf8ToHtml('Detalhes Proposta: '); echo formataNumericos("zzz.zz9",$nrctrlim,"."); ?></b></legend>
        <div id="divAcionamento" class="divRegistros">
            <table>
            <thead>
                <tr>
                    <th>Acionamento</th>
                    <th>PA</th>
                    <th>Operador</th>
                    <th>Opera&ccedil;&atilde;o</th>
                    <th>Data e Hora</th>
                    <th>Retorno</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
            </table>
        </div>
    </fieldset>
    <div id="divBotoesAcionamento" style="margin-top:5px;">
        <a href="#" class="botao" id="btVoltar" onclick="fecharRotinaGenerico('<? echo $tipo ?>');">Voltar</a>
    </div>
    <form id="frmImprimir" name="frmImprimir">
        <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
        <input type="hidden" name="nmarquiv" id="nmarquiv" />
    </form>
</div>

    
