<?php
/**
 * Autor: Bruno Luiz Katzjarowski;
 * Data: 27/11/2018
 * Ultima alteração:
 * 
 * Alterações:
 */

//Include de principal.php para recuperar variaveis globais contidas nas telas anteriores
include('principal.php');


// Verifica se o n�mero da conta foi informado
if (!isset($_POST["nrdconta"])) {
    exibeErro("Par&acirc;metros incorretos.");
}	

$nrdconta = $_POST["nrdconta"]; 

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

</div>

<script>
    var_globais.nrdconta = "<?php echo $nrdconta ?>";
</script>