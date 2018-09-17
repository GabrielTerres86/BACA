<?php
/*!
 * FONTE        : form_dados.php
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : Junho/2016
 * OBJETIVO     : Mostrar tela manutenção Seguros - PENSEG
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {
    exibirErro('error',$msgError,'Alerta - Ayllos','',false);
}

$idcontrato     = (isset($_POST['idcontrato'   ])) ? $_POST['idcontrato'   ] : '' ;
$regNrproposta  = (isset($_POST['regNrproposta'])) ? $_POST['regNrproposta'] : '' ;
$regNrapolice   = (isset($_POST['regNrapolice' ])) ? $_POST['regNrapolice' ] : '' ;
$regNrendosso   = (isset($_POST['regNrendosso' ])) ? $_POST['regNrendosso' ] : '' ;
$regDtinivig    = (isset($_POST['regDtinivig'  ])) ? $_POST['regDtinivig'  ] : '' ;
$regDtfimvig    = (isset($_POST['regDtfimvig'  ])) ? $_POST['regDtfimvig'  ] : '' ;
$regNmsegura    = (isset($_POST['regNmsegura'  ])) ? $_POST['regNmsegura'  ] : '' ;
$regNmmarca     = (isset($_POST['regNmmarca'   ])) ? $_POST['regNmmarca'   ] : '' ;
$regDsmodelo    = (isset($_POST['regDsmodelo'  ])) ? $_POST['regDsmodelo'  ] : '' ;
$regDschassi    = (isset($_POST['regDschassi'  ])) ? $_POST['regDschassi'  ] : '' ;
$regDsplaca     = (isset($_POST['regDsplaca'   ])) ? $_POST['regDsplaca'   ] : '' ;
$regNranofab    = (isset($_POST['regNranofab'  ])) ? $_POST['regNranofab'  ] : '' ;
$regNranomod    = (isset($_POST['regNranomod'  ])) ? $_POST['regNranomod'  ] : '' ;
$regCdcooper    = (isset($_POST['regCdcooper'  ])) ? $_POST['regCdcooper'  ] : '' ;
$regNrdconta    = (isset($_POST['regNrdconta'  ])) ? $_POST['regNrdconta'  ] : '' ;
$regimgSitCoop  = (isset($_POST['regimgSitCoop'])) ? $_POST['regimgSitCoop'] : '' ;
$nrcpfSegurado	= (isset($_POST['regNrcpjcnpj' ])) ? $_POST['regNrcpjcnpj'] : '' ;
$nmdoSegurado	= (isset($_POST['regNmdosegur' ])) ? $_POST['regNmdosegur'] : '' ;

/*
$xml = "<Root>";
$xml .= " <Dados>";
$xml .= " <cooper>0</cooper>";
$xml .= " <flgativo>1</flgativo>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
if ($msgErro == "") {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
}

exibeErroNew($msgErro);
}

$cooperativas = $xmlObj->roottag->tags[0]->tags;
*/

// Montar o xml de Requisicao
$xml .= "<Root>";
$xml .= " <Dados>";
$xml .= "    <cddopcao>C</cddopcao>";
$xml .= "    <tipopera>X</tipopera>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_PRCINS", "BUSCAR_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------
if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){
$msgErro = $xmlObj->roottag->tags[0]->cdata;
if($msgErro == null || $msgErro == ''){
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
}
exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
}
$cooperativas = $xmlObj->roottag->tags[0]->tags;


function exibeErroNew($msgErro) {
    echo 'hideMsgAguardo();';
    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
    exit();
}

?>
<form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:block">
    <!--br style="clear:both" /-->

    <fieldset style="width:95%;" >
        <legend align="left"><?php echo 'Dados do Seguro' ?></legend>

        <input type="hidden" id="idcontrato" name="idcontrato" value="<?php echo $idcontrato; ?>" />

        <label for="regNrproposta"><?php echo utf8ToHtml('Nr. Proposta:') ?></label>
        <input id="regNrproposta" name="regNrproposta" type="text" value="<?php echo $regNrproposta; ?>" />
        <label for="regNrapolice"><?php echo utf8ToHtml('Nr. Ap&oacute;lice:') ?></label>
        <input id="regNrapolice" name="regNrapolice" type="text" value="<?php echo $regNrapolice; ?>" />
        <label for="regNrendosso"><?php echo utf8ToHtml('Nr. Endosso:') ?></label>
        <input id="regNrendosso" name="regNrendosso" type="text" value="<?php echo $regNrendosso; ?>" />
        <br style="clear:both" />

        <label for="regDtinivig"><?php echo utf8ToHtml('In&iacute;cio da Vig&ecirc;ncia:') ?></label>
        <input id="regDtinivig" name="regDtinivig" type="text" value="<?php echo $regDtinivig; ?>" />
        <label for="regDtfimvig"><?php echo utf8ToHtml('Final da Vig&ecirc;ncia:') ?></label>
        <input id="regDtfimvig" name="regDtfimvig" type="text" value="<?php echo $regDtfimvig; ?>" />
        <br style="clear:both" />

        <label for="regNmsegura"><?php echo utf8ToHtml('Seguradora:') ?></label>
        <input id="regNmsegura" name="regNmsegura" type="text" value="<?php echo $regNmsegura; ?>" />
    </fieldset>
    <!--br style="clear:both" /-->


    <fieldset style="width:95%;" >
        <legend align="left"><?php echo 'Dados do Ve&iacute;culo' ?></legend>

        <label for="regNmmarca"><?php echo utf8ToHtml('Marca:') ?></label>
        <input id="regNmmarca" name="regNmmarca" type="text" value="<?php echo $regNmmarca; ?>" />
        <label for="regDsmodelo"><?php echo utf8ToHtml('Modelo:') ?></label>
        <input id="regDsmodelo" name="regDsmodelo" type="text" value="<?php echo $regDsmodelo; ?>" />
        <br style="clear:both" />

        <label for="regDschassi"><?php echo utf8ToHtml('Chassi:') ?></label>
        <input id="regDschassi" name="regDschassi" type="text" value="<?php echo $regDschassi; ?>" />
        <label for="regDsplaca"><?php echo utf8ToHtml('Placa:') ?></label>
        <input id="regDsplaca" name="regDsplaca" type="text" value="<?php echo $regDsplaca; ?>" />
        <br style="clear:both" />

        <label for="regNranofab"><?php echo utf8ToHtml('Ano Fabr.:') ?></label>
        <input id="regNranofab" name="regNranofab" type="text" value="<?php echo $regNranofab; ?>" />
        <label for="regNranomod"><?php echo utf8ToHtml('Ano Mod.:') ?></label>
        <input id="regNranomod" name="regNranomod" type="text" value="<?php echo $regNranomod; ?>" />
        <br style="clear:both" />
    </fieldset>
    <!--br style="clear:both" /-->

	<fieldset style="width:95%;" >
        <legend align="left"><?php echo 'Dados do Segurado' ?></legend>

        <label for="regNmsegur"><?php echo utf8ToHtml('Nome:') ?></label>
        <input id="regNmsegur" name="regNmsegur" type="text" value="<?php echo $nmdoSegurado; ?>" />
        <label for="regNrdocpf"><?php echo utf8ToHtml('CPF:') ?></label>
        <input id="regNrdocpf" name="regNrdocpf" type="text" value="<?php echo $nrcpfSegurado; ?>" />
        <br style="clear:both" />
    </fieldset>

    <fieldset style="width:95%;" >
        <legend align="left"><?php echo 'Ajustar Ag&ecirc;ncia e Conta' ?></legend>


        <label for="regCdcooper"><?php echo utf8ToHtml('Ag&ecirc;ncia Importada:') ?></label>
        <input id="regCdcooper" name="regCdcooper" type="text" value="<?php echo $regCdcooper; ?>"></input>

        <label for="regimgSitCoop"><img id="imgSituac" name="imgSituac" src="<?php echo $UrlImagens; ?>icones/<?php echo $regimgSitCoop; ?>" /></label>

        <label for="regNrdconta"><?php echo utf8ToHtml('Conta/DV Importada:') ?></label>
        <input id="regNrdconta" name="regNrdconta" type="text" value="<?php echo $regNrdconta; ?>" />
        <br style="clear:both" />

        <label for="newCdcooper"><?php echo utf8ToHtml('Ag&ecirc;ncia Correta:') ?></label>
<!--        <input id="newCdcooper" name="newCdcooper" type="text" value="<?php echo $newCdcooper; ?>" /> -->
        <select id="newCdcooper" name="newCdcooper">
        <option value="0"><?php echo utf8ToHtml('-- SELECIONE -- ') ?></option>
        <?php
        foreach ($cooperativas as $r) {
            if ( getByTagName($r->tags, 'cdcooper') <> '' ) {?>
            <option value="<?= getByTagName($r->tags, 'cdcooper'); ?>"<?php if (getByTagName($r->tags, 'cdcooper') == $regCdcooper ) echo 'selected'; ?>><?php echo getByTagName($r->tags, 'nmrescop'); ?></option>
<?php       }
        }
        ?>
        </select>
        <label for="newNrdconta"><?php echo utf8ToHtml('Conta/DV Correta:') ?></label>
        <input id="newNrdconta" name="newNrdconta" type="text" />

        <a href="#" class="botao" id="btnOK">Ok</a>

        <br style="clear:both" />

<!--        <label for="newNmrescop"><?php echo utf8ToHtml('&nbsp;') ?></label>
        <input id="newNmrescop" name="newNmrescop" type="text"  />
    -->    <label for="newNmprimtl"><?php echo utf8ToHtml('&nbsp;') ?></label>
        <input id="newNmprimtl" name="newNmprimtl" type="text"  />
        <br style="clear:both" />
    </fieldset>

    <div id="divBotoes">
        <a href="#" class="botao" id="btGravar" name="btGravar" onClick="gravarSeguro();return false;" style="float:none;">Gravar</a>
        <a href="#" class="botao" id="btVoltar" name="btVoltar" onClick="encerraRotina();return false;"   style="float:none;">Voltar</a>
    </div>
    <br style="clear:both" />

</form>

<script type="text/javascript">
    // Bloqueia o conteudo em volta da divRotina
    blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
