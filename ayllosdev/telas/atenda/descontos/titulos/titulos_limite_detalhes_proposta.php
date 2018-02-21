<?php
/* !
 * FONTE        : form_acionamentos.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 22/03/2016 
 * OBJETIVO     : Rotina para controlar a busca de acionamentos
 * --------------
 * ALTERAÇÕES   : 18/04/2017 - Alterações referentes ao projeto 337 - Motor de Crédito. (Reinert)
 *                12/06/2017 - Retornar o protocolo. (Jaison/Marcos - PRJ337)
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

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : '';

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>" . $nrdconta . "</nrdconta>";
$xml .= "   <nrctrlim>" . $nrctrlim . "</nrctrlim>";
$xml .= "   <dtinicio>01/01/0001</dtinicio>";
$xml .= "   <dtafinal>31/12/9999</dtafinal>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "CONS_ACIONAMENTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
   //echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);controlaOperacao();");';
   echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);fechaRotinaDetalhe();");';
   exit;

}

$registros = $xmlObj->roottag->tags[0]->tags;
$qtregist = $xmlObj->roottag->tags[1]->cdata;

?>

<div id='divResultadoAciona'>
    <fieldset id='tabConteudo'>
        <legend><b><?= utf8ToHtml('Detalhes Proposta: '); echo formataNumericos("zzz.zz9",$nrctrlim,"."); ?></b></legend>
        <div class='divRegistros'>
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
            <?php
            foreach ($registros as $r) {
                $dsoperacao = wordwrap(getByTagName($r->tags, 'operacao'),40, "<br />\n");
                if (getByTagName($r->tags, 'dsprotocolo')) {
                    $dsoperacao = '<a href="#" onclick="abreProtocoloAcionamento(\''.getByTagName($r->tags, 'dsprotocolo').'\');" style="font-size: inherit">'.$dsoperacao.'</a>';
                }
                ?>
                <tr>
                    <td><?= getByTagName($r->tags, 'acionamento'); ?></td>
                    <td><?= getByTagName($r->tags, 'nmagenci'); ?></td>
                    <td><?= getByTagName($r->tags, 'cdoperad'); ?></td>
                    <td><?= $dsoperacao; ?></td>
                    <td><?= getByTagName($r->tags, 'dtmvtolt'); ?></td>
                    <td><?= wordwrap(getByTagName($r->tags, 'retorno'),40, "<br />\n"); ?></td>
                </tr>
                <?php
            }
            ?>
            </tbody>
            </table>
        </div>
    </fieldset>
    <div id="divBotoesAcionamento" style="margin-top:5px;">
        <a href="#" class="botao gft" id="btVoltar" onclick="fechaRotinaDetalhe();//controlaOperacao('TESTE');bloqueiaFundo(divRotina);">Voltar</a>
    </div>
</div>

<script type="text/javascript">
dscShowHideDiv("divOpcoesDaOpcao2","divOpcoesDaOpcao1;divOpcoesDaOpcao3");

// Muda o título da tela
//$("#tdTitRotina").html("DESCONTO DE T&Iacute;TULOS - ACIONAM");

//formataLayout('divLimites');

// Bloqueia conteúdo que está átras do div da rotina
//blockBackground(parseInt($("#divRotina").css("z-index")));
//layoutPadrao();
hideMsgAguardo();
bloqueiaFundo(divRotina);

</script>


    
