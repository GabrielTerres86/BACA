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
 
session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

$dsprotocolo = (isset($_POST['dsprotocolo'])) ? $_POST['dsprotocolo'] : '';
$nmarquiv    = (isset($_POST['nmarquiv']))    ? $_POST['nmarquiv']    : '';

// Gera o arquivo
if ($dsprotocolo) {

    // Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <dsprotocolo>".$dsprotocolo."</dsprotocolo>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // craprdr / crapaca 
    $xmlResult = mensageria($xml, "CONPRO", "CONPRO_GERA_ARQ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
    if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
        exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)', false);
    }

    // Obtem nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    echo $xmlObjeto->roottag->tags[0]->cdata;

// Efetua o download
} else if ($nmarquiv) {

    //Chama função para mostrar PDF do impresso gerado no browser	 
    visualizaPDF($nmarquiv);

// Mostra a listagem
} else { ?>
    <div id='divResultadoAciona'>
        <fieldset id='tabConteudo'>
            <legend><b><?= utf8ToHtml('Detalhes Proposta: '); echo formataNumericos("zzz.zz9",$nrctremp,"."); ?></b></legend>
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
            <a href="#" class="botao" id="btVoltar" onclick="controlaOperacao('TESTE');bloqueiaFundo(divRotina);">Voltar</a>
        </div>
    </div>
    <form id="frmImprimir" name="frmImprimir">
        <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>" />
        <input type="hidden" name="nmarquiv" id="nmarquiv" />
    </form>
    <?php
}
?>