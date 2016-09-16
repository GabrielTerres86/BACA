<?php
//************************************************************************//
//*** Fonte: contas_pendentes.php  	                                   ***//
//*** Autor: Lucas                                                     ***//
//*** Data : Abril/2012                   Última Alteração: 06/10/2015 ***//
//***                                                                  ***//
//*** Objetivo: Listagem de contas de tranf. com confirmação pendentes ***//
//***                                                                  ***//	 
//*** Alterações: 18/12/2014 - Melhorias Cadastro de Favorecidos TED   ***//
//***                         (André Santos - SUPERO) 	 			   ***//	 
//***             													   ***//	 
//***             06/10/2015 - Correcoes na parte de php que continha  ***//
//***                          alguns erros de codigficacao            ***//
//***                          (Tiago/Thiago R. #355990)               ***//
//************************************************************************//

session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], "H")) <> "") {
    exibeErro($msgError);
}

// Verifica se o n&uacute;mero da conta foi informado
if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"])) {
    exibeErro("Par&acirc;metros incorretos.");
}

$nrdconta = $_POST["nrdconta"];
$idseqttl = $_POST["idseqttl"];
$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 9999;

// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
if (!validaInteiro($nrdconta)) {
    exibeErro("Conta/dv inv&aacute;lida.");
}

// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
if (!validaInteiro($idseqttl)) {
    exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
}


// Monta o xml de requisi&ccedil;&atilde;o
$xmlGetPendentes = "";
$xmlGetPendentes .= "<Root>";
$xmlGetPendentes .= "	<Cabecalho>";
$xmlGetPendentes .= "		<Bo>b1wgen0015.p</Bo>";
$xmlGetPendentes .= "		<Proc>consulta-contas-pendentes</Proc>";
$xmlGetPendentes .= "	</Cabecalho>";
$xmlGetPendentes .= "	<Dados>";
$xmlGetPendentes .= "		<cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
$xmlGetPendentes .= "		<cdagenci>" . $glbvars["cdagenci"] . "</cdagenci>";
$xmlGetPendentes .= "		<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>";
$xmlGetPendentes .= "		<cdoperad>" . $glbvars["cdoperad"] . "</cdoperad>";
$xmlGetPendentes .= "		<nmdatela>" . $glbvars["nmdatela"] . "</nmdatela>";
$xmlGetPendentes .= "		<idorigem>" . $glbvars["idorigem"] . "</idorigem>";
$xmlGetPendentes .= "		<nrdconta>" . $nrdconta . "</nrdconta>";
$xmlGetPendentes .= "		<idseqttl>" . $idseqttl . "</idseqttl>";
$xmlGetPendentes .= "		<dtmvtolt>" . $glbvars["dtmvtolt"] . "</dtmvtolt>";
$xmlGetPendentes .= '		<nriniseq>' . $nriniseq . '</nriniseq>';
$xmlGetPendentes .= '		<nrregist>' . $nrregist . '</nrregist>';
$xmlGetPendentes .= "	</Dados>";
$xmlGetPendentes .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlGetPendentes);

// Cria objeto para classe de tratamento de XML
$xmlObjPendentes = getObjectXML($xmlResult);

$registros = $xmlObjPendentes->roottag->tags[0]->tags;
$qtregist = $xmlObjPendentes->roottag->tags[0]->attributes['QTREGIST'];

// Se ocorrer um erro, mostra cr&iacute;tica
if (strtoupper($xmlObjPendentes->roottag->tags[0]->name) == "ERRO") {
    exibeErro($xmlObjPendentes->roottag->tags[0]->tags[0]->tags[4]->cdata);
}

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
    echo '<script type="text/javascript">';
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
    echo 'redimensiona();';
    echo '</script>';
    exit();
}
?>

<script type="text/javascript">

<?php
//Armazena valores em array para uso posterior
foreach ($registros as $pendentes) {

    echo 'var aux = new Array();';
    echo 'var i = arrayPend.length;';
    echo 'aux[\'cddbanco\'] = "' . getByTagName($pendentes->tags, 'cddbanco') . '";';
    echo 'aux[\'cdageban\'] = "' . getByTagName($pendentes->tags, 'cdageban') . '";';
    echo 'aux[\'nrctatrf\'] = "' . getByTagName($pendentes->tags, 'nrctatrf') . '";';
    echo 'aux[\'nmtitula\'] = "' . getByTagName($pendentes->tags, 'nmtitula') . '";';
    echo 'aux[\'nrcpfcgc\'] = "' . getByTagName($pendentes->tags, 'nrcpfcgc') . '";';
    echo 'aux[\'dstransa\'] = "' . getByTagName($pendentes->tags, 'dstransa') . '";';
    echo 'aux[\'dsprotoc\'] = "' . getByTagName($pendentes->tags, 'dsprotoc') . '";';
    echo 'aux[\'cdispbif\'] = "' . getByTagName($pendentes->tags, 'nrispbif') . '";';
    echo 'arrayPend[i] = aux;';
}
?>
    reg = new Array();</script>

<form name="frmPendentes" class="formulario" id="frmPendentes" method="post">
    <div  id = "divTabelaPendentes" class="divRegistros">	
        <table>
            <thead>
                <tr>
                    <th>&nbsp;</th>
                    <th><?php echo utf8ToHtml('Conta/DV'); ?></th>
                    <th><?php echo utf8ToHtml('CPF/CNPJ');  ?></th>
                    <th><?php echo utf8ToHtml('Protocolo');  ?></th>
                    <th><?php echo utf8ToHtml('Situa&ccedil;&atilde;o');  ?></th>
                </tr>
            </thead>
            <tbody>
<?php foreach ($registros as $pendentes) { ?>	
                    <tr>
                        <td><span><input name="flgselec" id="flgselec" type="checkbox" value = "<?php echo getByTagName($pendentes->tags,'idseqreg'); ?>"  ></span>
                            <input name="flgselec" id="flgselec" type="checkbox" value = "<?php echo getByTagName($pendentes->tags,'idseqreg'); ?>" <?php echo (getByTagName($pendentes->tags, 'insitfav') == 3 ? 'disabled' : ''); ?>  >
                        </td>
                        <td onClick="detalhesPendentes( <? echo getByTagName($pendentes->tags, 'idseqreg'); ?> ); return false;" >
                            <span><?php echo getByTagName($pendentes->tags, 'dsctatrf'); ?></span>
    <?php echo getByTagName($pendentes->tags, 'dsctatrf'); ?>
                        </td>
                        <td onClick="detalhesPendentes( <?php echo getByTagName($pendentes->tags, 'idseqreg'); ?> ); return false;" >
                            <span><?php echo getByTagName($pendentes->tags, 'nrcpfcgc'); ?></span>
                            <?php echo getByTagName($pendentes->tags, 'nrcpfcgc'); ?>
                        </td>
                        <td onClick="detalhesPendentes( <?php echo getByTagName($pendentes->tags, 'idseqreg'); ?> ); return false;" >
                            <span><?php echo getByTagName($pendentes->tags, 'dsprotoc'); ?></span>
                            <?php echo getByTagName($pendentes->tags, 'dsprotoc'); ?>
                        </td>
                        <td onClick="detalhesPendentes( <?php echo getByTagName($pendentes->tags, 'idseqreg'); ?> ); return false;" >
                            <span><?php echo getByTagName($pendentes->tags, 'dstipfav'); ?></span>
                            <?php echo getByTagName($pendentes->tags, 'dstipfav'); ?>
                        </td>						
                    </tr>
                <script type="text/javascript">
                            ObjReg = new Object();
                            ObjReg.cddbanco = '<?php echo getByTagName($pendentes->tags,'cddbanco'); ?>';
                            ObjReg.cdageban = '<?php echo getByTagName($pendentes->tags,'cdageban'); ?>';
                            ObjReg.dsctatrf = '<?php echo getByTagName($pendentes->tags,'dsctatrf'); ?>';
                            ObjReg.nmtitula = '<?php echo getByTagName($pendentes->tags,'nmtitula'); ?>';
                            ObjReg.nrcpfcgc = '<?php echo getByTagName($pendentes->tags,'nrcpfcgc'); ?>';
                            ObjReg.dstransa = '<?php echo getByTagName($pendentes->tags,'dstransa'); ?>';
                            ObjReg.dsprotoc = '<?php echo getByTagName($pendentes->tags,'dsprotoc'); ?>';
                            ObjReg.inpessoa = '<?php echo getByTagName($pendentes->tags,'inpessoa'); ?>';
                            ObjReg.cdispbif = '<?php echo str_pad(getByTagName($pendentes->tags,'nrispbif'), 8, "0", STR_PAD_LEFT); ?>';
                            reg[ <?php echo getByTagName($pendentes->tags, 'idseqreg'); ?> ] = ObjReg;            </script>
                <?php } ?>	
                </tbody>
            </table>
        </div>

    </form>


    <div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
    <?php
    //
    if (isset($qtregist) and count($qtregist) == 0)
        $nriniseq = 0;
	
    // Se a paginação não está na primeira, exibe botão voltar
    if ($nriniseq > 1) {
        ?> <a class='paginacaoAnt'><<< Anterior</a> <?php
                } else {
                ?> &nbsp; <?php
                }
                ?>
            </td>
            <td>
                <?php
                if ($nriniseq) {
                ?> Exibindo <?php echo $nriniseq; ?> at&eacute; <?php if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <?php echo $qtregist; ?>
                <?php  } ?>
            </td>
            <td>
                <?php
                // Se a paginação não está na ultima página, exibe botão proximo
                if ($qtregist > ($nriniseq + $nrregist - 1)) {
                ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?php
                } else {
                ?> &nbsp; <?php
                }
                ?>
            </td>
        </tr>
    </table>
</div>
<div id="divBotoes" style="margin-bottom:10px">
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="redimensiona(); carregaContas(); return false;" />
    <input id="btSalvar" type="image" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="showConfirmacao('Deseja confirmar as contas selecionadas?', 'Confirma&ccedil;&atilde;o - Ayllos', 'confirmaContas()', metodoBlock, 'sim.gif', 'nao.gif'); return false;" />
</div>


<form name="frmDetalhes" class="formulario" id="frmDetalhes" method="post" style="display: none;">
    <fieldset>
        <legend>Detalhes</legend>
        <div id="divDetalhes" style="padding-left:15px;">
            <div style = "text-align:left;"><label>Dados do Favorecido:</label></div>

            <br/><br/>

            <label for="cddbanco" style = "width:50px;"><?php echo utf8ToHtml('Banco:') ?></label>
            <input style="width:50px" class="campo" name="cddbanco" id="cddbanco"/>

            <label for="cdispbif" style = "width:50px;"><?php echo utf8ToHtml('ISPB:') ?></label>
            <input style="width:80px" class="campo" name="cdispbif" id="cdispbif"/>

            <label for="cdageban" style = "width:80px;"><?php echo utf8ToHtml('Agência:') ?></label>
            <input style="width:50px" class="campo" name="cdageban" id="cdageban"/>

            <br/><br/>   
            <label for="nrctatrf" style = "width:110px;"><?php echo utf8ToHtml('Conta&nbsp;Corrente:') ?></label>
            <input style="width:90px" class="campo" name="nrctatrf" id="nrctatrf" />

            <br/><br/>

            <div style = "padding-left:13px;">
                <label for="nmtitula"><?php echo utf8ToHtml('Nome do Titular:') ?></label>
                <input style = "width:323px;" class="campo" name="nmtitula" id="nmtitula" />
            </div>

            <br/><br/>		

            <div id = "CNPJ" style = "display: none;"><label for="nrcpfcgc"><?php echo utf8ToHtml('CNPJ do Titular:') ?></label></div>
            <div id = "CPF" style = "display: none;"><label for="nrcpfcgc"><?php echo utf8ToHtml('CPF do Titular:') ?></label></div>
            <input class="campo" name="nrcpfcgc" id="nrcpfcgc" />

            <br/><br/>

            <label for="dstransa"><?php echo utf8ToHtml('Data Pre-Cadastro:') ?></label>
            <input class="campo" name="dstransa" id="dstransa"/>

            <br/><br/>

            <div style = "padding-left:46px;">
                <label for="dsprotoc"><?php echo utf8ToHtml('Protocolo:') ?></label>
                <input style = "width:280px;" class="campo" name="dsprotoc" id="dsprotoc" />
            </div>

            <br/><br/>

            <div  style = "padding-left:200px;">
                <input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick=" escondeDetalhesPend(); return false;" />
            </div>
        </div>
    </fieldset>
</form>	

<script type="text/javascript">

            $('#divPesquisaRodape', '#divRotina').formataRodapePesquisa();
			
			$('a.paginacaoAnt').unbind('click').bind('click', function() {
    obtemCntsPendentes( <? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?> );
            });
            $('a.paginacaoProx').unbind('click').bind('click', function() {
    obtemCntsPendentes( <? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?> );
            });
						
			controlaListaPendentes();
            $("#divConteudoOpcao").css("height", "300");
            $("#divConteudoOpcao").css("width", "700");
// Esconde mensagem de aguardo
            hideMsgAguardo();
// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
            blockBackground(parseInt($("#divRotina").css("z-index")));


</script> 