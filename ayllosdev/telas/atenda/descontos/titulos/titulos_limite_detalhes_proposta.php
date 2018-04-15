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

$tipo = (isset($_POST['tipo'])) ? $_POST['tipo'] : "CONTRATO";
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : 0;  //contrato

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
    $xml .= "   <nrctrlim>" . $nrctrlim . "</nrctrlim>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "OBTEM_PROPOSTA_ACIONA",
     $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
        $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);


    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	   echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);fechaRotinaDetalhe();");';
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
<div id='divResultadoAciona'>
    <fieldset id='divForm'>
        <div id="divFormContent">
            <label for="nrctrlim"><? echo utf8ToHtml('Proposta: ') ?></label>

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
            <?php } ?>
            </select>
        </div>
    </fieldset>
    <fieldset id='tabConteudo'>
        <legend id= 'tabConteudoLegend' ><b><?= utf8ToHtml('Detalhes Proposta: '); echo formataNumericos("zzz.zz9",$nrctrlim,"."); ?></b></legend>
        <div id="divAcionamento" class='divRegistros'>
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
                <tr id="">
                    <td id="acionamento">acionamento</td>
                    <td id="nmagenci">nmagenci</td>
                    <td id="cdoperad">cdoperad</td>
                    <td id="operacao"><a href="#" onclick="" style="font-size: inherit">dsoperacao</a></td>
                    <td id="dtmvtolt">dtmvtolt</td>
                    <td id="retorno">retorno</td>
                </tr>
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

<script type="text/javascript">

    formatarTelaAcionamentosDaProposta();

    dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");
    hideMsgAguardo();
    bloqueiaFundo(divRotina);

</script>

    
