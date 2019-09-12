<?php
/**
 * Autor: Bruno Luiz Katzjarowski;
 * Data: 27/11/2018
 * Ultima alteração: 30/05/2019
 * 
 * Alterações: 30/05/2019 - Ajuste para pegar o número da conta formatado, para serer usado
 *                          no link do DigiDoc - PRJ 438 (Mateus Z / Mouts)
 *             20/05/2019 - P450 - Adicionado Botões Analisar e Alterar Rating
 *                          Luiz Otávio Olilnger Momm (AMCOM) 
 */

//Include de principal.php para recuperar variaveis globais contidas nas telas anteriores
include('principal.php');

// [20/05/2019] - P450
$permiteAlterarRating = false;
$oXML = new XmlMensageria();
$oXML->add('cooperat', $glbvars["cdcooper"]);

$xmlResult = mensageria($oXML, "TELA_PARRAT", "CONSULTA_PARAM_RATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

$registrosPARRAT = $xmlObj->roottag->tags[0]->tags;
foreach ($registrosPARRAT as $r) {
    if (getByTagName($r->tags, 'pr_inpermite_alterar') == '1') {
        $permiteAlterarRating = true;
    }
}
// [20/05/2019] - P450

// Verifica se o numero da conta foi informado
if (!isset($_POST["nrdconta"])) {
    exibeErro("Par&acirc;metros incorretos.");
}	

$nrdconta = $_POST["nrdconta"]; 

$xml  = "<Root>";
$xml .= "  <Dados>";
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <cdacesso>HABILITA_RATING_NOVO</cdacesso>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_PARRAT", "CONSULTA_PARAM_CRAPPRM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjPRM = getObjectXML($xmlResult);

$habrat = 'N';
if (strtoupper($xmlObjPRM->roottag->tags[0]->name) == "ERRO") {
    $habrat = 'N';
} else {
    $habrat = $xmlObjPRM->roottag->tags[0]->tags;
    $habrat = getByTagName($habrat[0]->tags, 'PR_DSVLRPRM');
}


$xml  = "<Root>";
$xml .= "  <Dados>";
$xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
$xml .= "  </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA", "BUSCA_LIMITE_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlLimites = new SimpleXMLElement($xmlResult);
?>
<!-- Script tela principal  -->
<script type="text/javascript" src="limite_credito/js/tela_principal.js?keyrand=<?php echo mt_rand(); ?>"></script>


<?php
    //Include da tabela da tela principal do limite de credito
    include('tabelas/tabela_tela_principal.php');
?>

<br style="clear:both" />

<form action="<?php echo $UrlSite; ?>telas/atenda/limite_credito/imprimir_dados.php" name="frmImprimir" id="frmImprimir" method="post">
    <input type="hidden" name="nrdconta" id="nrdconta" value="">
    <input type="hidden" name="nrctrlim" id="nrctrlim" value="">
    <input type="hidden" name="idimpres" id="idimpres" value="">
    <input type="hidden" name="flgemail" id="flgemail" value="">
    <input type="hidden" name="flgimpnp" id="flgimpnp" value="">
    <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form> 

<div id="divBotoes">

    <a href="#" class="botao" id="btVoltar">Voltar</a>
    <a href="#" class="botao" id="btAlterarLimite">Alterar</a>
    <a href="#" class="botao" id="btConsultarLimiteAtivo">Consultar Limite Ativo</a>
    <a href="#" class="botao" id="btConsultarLimiteProposto">Consultar Limite Proposto</a>
    <a href="#" class="botao" id="btIncluirNovoLimite">Incluir</a>
    <a href="#" class="botao" id="btImprimir">Imprimir</a>
    <a href="#" class="botao" id="btUltimasAlteracoes"><?php echo utf8ToHtml('Últimas Alterações') ?></a>
    </br>
    <a href="#" class="botao" id="btEfetivar">Efetivar</a>
    <a href="#" class="botao" id="btCancelarLimite">Cancelar Limite Atual</a>
    <a href="#" class="botao" id="btRenovar">Renovar</a>
    <a href="#" class="botao" id="btConsultarImagem">Consultar Imagem</a>
    <a href="#" class="botao" id="btExcluirNovoLimite">Excluir Novo Limite</a>
    <!-- 20/05/2019 - P450 -->
    <a href="#" class="botao" name="btnRatingMotor" id="btnRatingMotor" style="<? echo $dispL ?>" onClick="ratingMotor('1');">Analisar Rating</a>
    <?
    if ($permiteAlterarRating) {
    ?>
    <a href="#" class="botao" name="btnConfAlterarRating" id="btnConfAlterarRating" style="<? echo $dispT ?>" onClick="btnChequeRating();">Alterar Rating</a>
    <?
    }
    ?>
    <!-- 20/05/2019 - P450 -->

</div>

<script>
    var_globais.habrat = "<?php echo $habrat?>";
    var_globais.nrdconta = "<?php echo $nrdconta ?>";
    var_globais.nrdcontaFormatada = "<?php echo formataContaDVsimples($nrdconta) ?>";
</script>