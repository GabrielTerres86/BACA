<?php
/*!
 * FONTE        : form_aprovadores.php
 * CRIAÇÃO      : André Clemer
 * DATA CRIAÇÃO : 20/07/2018
 * OBJETIVO     : Formulário de aprovadores
 */


session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

$cdalcada = (isset($_POST['cdalcada'])) ? $_POST['cdalcada'] : '';
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : $glbvars['cdcooper'];
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) != '') {		
	exibeErroNew($msgError);
}

$xml = new XmlMensageria();
$xml->add('cdcooprt',$cdcooper);
$xml->add('cdalcada_aprovacao',$cdalcada);

$xmlResult = mensageria($xml, "TELA_CADRES", "BUSCA_APROVADORES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
    exibeErroNew($msgErro);exit;
}

$registros = $xmlObj->roottag->tags[0]->tags;

// Opcao de Carregamento
if ( $cdalcada == 1 || true ) {

}

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","'.$msgErro.'","Alerta - Ayllos","desbloqueia()");');
}
?>
<div class="divRegistros">
    <table>
        <thead>
            <tr>
                <th align="left">C&oacute;digo</th>
                <th align="left">Nome</th>
                <?php if ($cddopcao != 'C') { ?>
                <th>&nbsp;</th> 
                <?php } ?>
            </tr>
        </thead>
        <tbody>
        <?php
        $count = count($registros);
        $cdaprovadores = array();
        if ( !$count ) { 
            $i = 0;					
            ?><tr><td colspan="<?php echo $cddopcao == 'C' ? '2' : '3'; ?>" style="font-size:12px; text-align:center;">N&atilde;o existem aprovadores para a al&ccedil;ada informada.</td></tr><?php
        // Caso a pesquisa retornou itens, exibilos em diversas linhas da tabela
        } else {  
            // Realiza um loop nos registros retornados e desenha cada um em uma linha da tabela
            for($i = 0; $i < $count; ++$i) {
                $cdaprovador = getByTagName($registros[$i]->tags,'cdaprovador');
                $nmaprovador = getByTagName($registros[$i]->tags,'nmaprovador');
                $dsemailaprovador = getByTagName($registros[$i]->tags,'dsemailaprovador');
                $cdaprovadores[] = $cdaprovador;
            ?>
                <tr onclick="PopupAprovadores.onClick_Registro('<?php echo $dsemailaprovador; ?>')" 
                    ondblclick="PopupAprovadores.onDblClick_Registro('<?php echo $cdalcada; ?>', '<?php echo $cdaprovador; ?>', '<?php echo $nmaprovador; ?>','<?php echo $dsemailaprovador; ?>')">
                    <td>
                        <input type="hidden" id="cdaprovador_<?php echo $i; ?>" name="cdaprovador[]" value="<?php echo $cdaprovador; ?>"/>
                        <?php echo $cdaprovador; ?>
                    </td>
                    <td>
                        <?php echo $nmaprovador; ?>
                    </td>
                    <?php if ($cddopcao != 'C') { ?>
                    <td>
                        <img onclick="PopupAprovadores.onClick_Excluir('<?php echo $cdaprovador; ?>','<?php echo $cdalcada; ?>');" src="<?php echo $UrlImagens; ?>geral/btn_excluir.gif" width="16" height="16" border="0"></a>
                    </td>
                    <?php } ?>
                </tr> 
            <? } // fecha o loop for
        } // fecha else ?> 
        </tbody>
    </table>
    <input type="hidden" id="cdaprovador_old" value="<?php echo implode(',', $cdaprovadores); ?>"/>
</div>
<ul class="complemento">
    <li class="txtNormalBold" style="width: 9%;">E-mail:</li>
    <li id="dsemail" class="txtNormal" style="width: 70%;"><?php echo getByTagName($registros[0]->tags,'dsemailaprovador'); ?></li>
</ul>