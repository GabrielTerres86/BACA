<?php
/*************************************************************************
  Fonte: desconto_convenio.php
  Autor: Fabio Stein (Supero)       Ultima atualizacao: 
  Data : Julho/2018
  
  Objetivo: Listar os convenios para desconto de reciprocidade.
  
  Alteracoes: 

*************************************************************************/

session_start();
  
// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");    
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod(); 
    
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");
  
// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
if (!isset($_POST["nrdconta"])) {
  exibeErro("Par&acirc;metros incorretos.");
} 
  
$nrdconta = $_POST["nrdconta"];

// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
if (!validaInteiro($nrdconta)) {
  exibeErro("Conta/dv inv&aacute;lida.");

}

if (!isset($_POST["idrecipr"])) {
  $idrecipr = 0;
} else{
  $idrecipr = $_POST["idrecipr"];
}


// Carrega permissões do operador
include("../../../includes/carrega_permissoes.php");  
  
setVarSession("opcoesTela",$opcoesTela);

$xml  = "";
$xml .= "<Root>";
$xml .= " <Dados>"; 
$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "TELA_ATENDA_COBRAN", "BUSCA_CONVENIOS_DESCONTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
  exibirErro('error',$xmlObjeto->roottag->tags[0]->cdata,'Alerta - Ayllos','',false);
}

$convenios = $xmlObjeto->roottag->tags[0]->tags;

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
  echo '<script type="text/javascript">';
  echo 'hideMsgAguardo();';
  echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
  echo '</script>';
  exit();
}   
  
?>
<div id="divResultado">
  <div class="divRegistros">
    <table style="table-layout: fixed;">
      <thead style="display:none">
        <tr>
          <th>&nbsp;</th>
          <th>Conv&ecirc;nio</th>
          <th>Tipo</th>
          <th>Tarifa&#231;&#227;o</th>
        </tr>
      </thead>
      <tbody>
        <?  
          for ($i = 0; $i < count($convenios); $i++) {
          $convenio = getByTagName($convenios[$i]->tags, 'nrconven');
          $tipo = getByTagName($convenios[$i]->tags, 'dsorgarq');
          $tarifacao = getByTagName($convenios[$i]->tags, 'dstarifacao');
          $reciprocidade = getByTagName($convenios[$i]->tags, 'idrecipr');
          $qtbolcob = getByTagName($convenios[$i]->tags, 'qtbolcob');
          $situacao = (int)getByTagName($convenios[$i]->tags, 'situacao');
        ?>
          <tr id="convenio<?php echo $i; ?>">
            <td width="20">
            <?php
                $checkbox = "<input type='checkbox' ";
                $checkbox .= " value='". $convenio ."'";
                $checkbox .= " data-tipo='". $tipo ."'";
                $checkbox .= " data-idreciprocidade='". $reciprocidade ."'";
                if($idrecipr!=0&&$idrecipr==$reciprocidade){
                    $checkbox .= " checked ";
                }
                if($qtbolcob>0&&$situacao>0){
                    $checkbox .= " disabled";
                }
                $checkbox .= " >";
                echo($checkbox);
            ?>
                        </td>
            <td width="80"><? echo $convenio; ?></td>
            <td width="200"><? echo $tipo; ?></td>
            <td><? echo $tarifacao; ?></td>
            </tr>
        <?} // Fim do for ?>
      </tbody>
    </table>
    <script>
        //descontoConvenios={};
        if(descontoConvenios.length>0){
            var checkboxes = $('#divConvenios input[type="checkbox"]');
            $.each(checkboxes, function (idx, elm){

              var foundCheck = false;
              descontoConvenios.forEach(function(entry) {
                  if($(elm).val()==entry.convenio){
                     foundCheck = true;
                  }
              });//foreach
              $(elm).prop( "checked", foundCheck);
            });//foreach
          }
    </script>
  </div>
</div>

<div id="divBotoes">
  <input type="hidden" id= "dsdmesag"    name="dsdmesag" value="<?php echo $dsdmesag; ?>">  
  <a href="#" class="botao" onclick="salvarDescontoConvenio(); return false;">Salvar</a>  
  <a href="#" class="botao" onclick="sairDescontoConvenio(); return false;">Voltar</a>  
  
</div>

<script type="text/javascript">

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

var ordemInicial = new Array();

var arrayLargura = new Array();
arrayLargura[0] = '20px';
arrayLargura[1] = '80px';
arrayLargura[2] = '200px';


var arrayAlinha = new Array();
arrayAlinha[0] = 'center';
arrayAlinha[1] = 'center';
arrayAlinha[2] = 'left';
arrayAlinha[3] = 'left';

$("#divResultado .divRegistros table").formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

</script>
