<?php
/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 18/03/2019
 * Ultima alteração:
 */
setlocale(LC_ALL, "pt_BR", "pt_BR.iso-8859-1", "pt_BR.utf-8", "portuguese");
header("Content-Type: text/html; charset=UTF-8",true);

/*
    Códigos tpproduto
*/
$arrTpproduto = Array(
    //"0" => "CDC Diversos",
    //"1" => "CDC Veículos",
    "2" => "Empréstimos /Financiamentos",
    "4" => "Desconto Cheques",
    "5" => "Limite de Desconto de Título",//de Crédito"
    "6" => "Bordero Desconto Títulos",
    "7" => "Cartão de Crédito"



);

//error_reporting(E_ALL);
//ini_set('display_errors', 1);

include('includes/Autentica.php');
$autentica = new Autentica();
$retornoTelaUnica = Array(); 
include('includes/chamadas.php');

// teste Anderson
$teste = false;

if(validaEntradaUsuario()){
	
    /** $autentica Obtem todos os dados passados por parametro via $_POST (Dados class) */
    if(isset($_POST)){
		
        if(count($_POST)> 0){

            /*
            * Anderson Schloegel
            * Limpar dados que vem da autenticacao deixando somente numeros
            */

            if($teste === true) {

                    echo '<pre>';
                    
                    var_dump($_POST);
                
                    $_POST['cdcooper']   = preg_replace( '/[^0-9]/', '', $_POST['cdcooper'] );
                    $_POST['cdagenci']   = preg_replace( '/[^0-9]/', '', $_POST['cdagenci'] );
                    $_POST['cdoperad']   = $_POST['cdoperad'];
                    $_POST['nrcpfcgc']   = preg_replace( '/[^0-9]/', '', $_POST['nrcpfcgc'] );
                    $_POST['nrdconta']   = preg_replace( '/[^0-9]/', '', $_POST['nrdconta'] );
                    $_POST['tpproduto']  = preg_replace( '/[^0-9]/', '', $_POST['tpproduto'] );
                    $_POST['nrproposta'] = preg_replace( '/[^0-9]/', '', $_POST['nrproposta'] );
                    $_POST['dstoken']    = $_POST['dstoken'];

                    echo '<br>posterior teste';

                    var_dump($_POST);


                    echo '<br>posterior validacao';
                    
                    if(empty($_POST['cdagenci']) || ($_POST['cdagenci'] === 0) || ($_POST['cdagenci'] == 0) ){
                        $_POST['cdagenci'] = 1;
                    }

                    echo '<br>PA: ' . $_POST['cdagenci'];

                    die('<br>teste de sistema, por favor, atualize a pagina ');
            }

            /*
            * Anderson Schloegel
            * Limpar dados que vem da autenticacao deixando somente numeros
            */

            $_POST['cdcooper']   = preg_replace( '/[^0-9]/', '', $_POST['cdcooper'] );
            $_POST['cdagenci']   = preg_replace( '/[^0-9]/', '', $_POST['cdagenci'] );
            $_POST['cdoperad']   = $_POST['cdoperad'];
            $_POST['nrcpfcgc']   = preg_replace( '/[^0-9]/', '', $_POST['nrcpfcgc'] );
            $_POST['nrdconta']   = preg_replace( '/[^0-9]/', '', $_POST['nrdconta'] );
            $_POST['tpproduto']  = preg_replace( '/[^0-9]/', '', $_POST['tpproduto'] );
            $_POST['nrproposta'] = preg_replace( '/[^0-9]/', '', $_POST['nrproposta'] );
            $_POST['dstoken']    = $_POST['dstoken'];
            /*
            * Anderson Schloegel
            * Se o PA vier vazio, zerado ou nulo, colocar PA = 1
            * 05/05/2019
            */

            if(empty($_POST['cdagenci']) || ($_POST['cdagenci'] === 0) || ($_POST['cdagenci'] == 0) ){
                $_POST['cdagenci'] = 1;
            }

            /*
            * Anderson Schloegel
            * Gravar codigo da cooperativa em sessao
            * 09/05/2019
            */

            $_SESSION['globalCDCOOPER'] = $_POST['cdcooper'];
            $_SESSION['globalCDAGENCI']     = $_POST['cdagenci'];
            $_SESSION['globalNRDCONTA']     = $_POST['nrdconta'];
            $_SESSION['globalCDOPERAD']     = $_POST['cdoperad'];
            $_SESSION['globalNRPROPOSTA']   = $_POST['nrproposta'];
            $_SESSION['globalTPPRODUTO']    = $_POST['tpproduto'];
            $_SESSION['globalIDANALISE']    = -1;
            $_SESSION['globalDHINICIO']     = date('d/m/Y H:i:s');    
            // autentica
            $autentica->atribuiDados($_POST);

            /* Validar Parametros de Entrada */
            if($autentica->validaParametros()){

                /* Se efetuaLogin() retornar true (Sem erros) */
                if(efetuaLogin()){
                    $glbvars = $retornoTelaUnica['glbvars'];

                /* Validar permissão do usuario */
                    $rtValida = validarPermissao('TELUNI','','C');
                    if($rtValida === ""){
                /** Caso OK efetuaLogin() $retornoTelaUnica recebe o index glbvars, caso não retorna index 'error' */
                if(isset($retornoTelaUnica['glbvars'])){
                            //$glbvars = $retornoTelaUnica['glbvars'];
                    if(!isset($glbvars["cdcooper"])){
                        $keys = array_keys($_SESSION['glbvars']);
                        $glbvars = $_SESSION['glbvars'][$keys[0]];
                    }
                    /* Validar token */
                    validaToken($_POST['cdcooper'],$_POST['cdagenci'],1,5,$_POST['cdoperad']);
                    
                    /* Se não retornar nenhum erro */
                    if(!isset($retornoTelaUnica['error'])){
                        $_SESSION['glbvars'] = $retornoTelaUnica['glbvars'];
                        $_SESSION['params']  = $autentica->getParametros();

                        $url = 'http://'.$_SERVER['SERVER_NAME'].'/telas/tela_analise_credito';

                        try{
                            header('Location: '.$url);
                        }catch(\Exception $e ){
                            echo $e->getMessage();
                            $retornoTelaUnica['error'] = '3 - Não foi possível completar sua requisição.';
                        }
                    }//Fim validaToken();
                        }
                    }else{
                        $retornoTelaUnica['error'] = $rtValida;
                    }
                }//Fim efetuaLogin();
            }else{
                $retornoTelaUnica['error'] = '5 - Faltam parâmetros a serem informados.';
            }
        }//Fim valida $_POST|$_GET
    }
}
?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Tela Única - Testes Autenticação</title>

    <link rel="stylesheet" href="css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
</head>
<body class=""> <!-- bg-dark -->

<div class="container mt-2">
    <?php
    if($autentica->getTipoEntrada() === 'homol_autentica'){ //Dados.php -> Defines topo arquivo.
        ?>
            <div class="card">
                <div class="card-header text-white bg-dark">
                    Tela Única - Teste Autenticação
                </div>
                <div class="card-body">
                    <form action="" method="POST">

                        <div class="form-row">

                            <div class="form-group col-md-3">
                                <!-- CDCOOPER -->
                                <label for="cdcooper">Cooperativa: </label>
                                <select name="cdcooper" class="form-control" id="cdcooper">
                                    <?php
                                    foreach($autentica->getCooperativas() as $key => $cooperativa){
                                        ?>
                                        <option value="<?php echo $key ?>"
                                            <?php
                                            if($autentica->getCdcooper() === $key)
                                                echo 'selected'
                                            ?>
                                        ><?=$key?> - <?php echo $cooperativa ?></option>
                                        <?php
                                    }
                                    ?>
                                </select><small>cdcooper: <span id='cdcooperSpan' ><?php echo $autentica->getCdcooper()  ?></span></small>
                            </div>

                            <!-- cdagenci -->
                            <div class="form-group col-md-3">
                                <label for="cdagenci" >cdagenci</label>
                                <input type="text" name="cdagenci" id="cdagenci" class="form-control"
                                    value="<?php echo $autentica->getCdagenci() ?>"
                                    required/>
                            </div>

                            <!-- cdoperad -->
                            <div class="form-group col-md-3">
                                <label for="cdoperad">cdoperad</label>
                                <input type="text" id="cdoperad" name="cdoperad" class="form-control"
                                    value="<?php echo $autentica->getCdoperad() ?>" required/>
                            </div>

                            <!-- nrcpfcgc -->
                            <div class="form-group col-md-3">
                                <label for="nrcpfcgc">nrcpfcgc</label>
                                <input type="text" id="nrcpfcgc" name="nrcpfcgc" class="form-control"
                                    value="<?php echo $autentica->getNrcpfcgc() ?>" required/>
                            </div>
                        </div>


                        <div class="form-row">

                            <!-- dstoken -->
                            <div class="form-group col-md-3">
                                <label for="dstoken">dstoken</label>
                                <input type="text" id="dstoken" name="dstoken" class="form-control"
                                    value="<?php echo $autentica->getDstoken() ?>" required/>
                            </div>

                            <!-- nrdconta -->
                            <div class="form-group col-md-3">
                                <label for="nrdconta">nrdconta</label>
                                <input type="text" id="nrdconta" name="nrdconta" class="form-control"
                                    value="<?php echo $autentica->getNrdconta() ?>" required/>
                            </div>

                            <!-- tpproduto -->
                            <div class="form-group col-md-3">
                                <label for="tpproduto">tpproduto</label>
                                <select id="tpproduto" name="tpproduto" class="form-control">
                                <?php
                                foreach($arrTpproduto as $key => $value){
                                    ?>
                                    <option value="<?php echo $key ?>" 
                                    <?php 
                                        if($autentica->getTpproduto() === $key)
                                            echo "selected";
                                    ?>
                                    ><?php echo $key." - ".$value; ?></option>
                                    <?php
                                }
                                ?>
                                </select>
                            </div>

                            <!-- nrproposta -->
                            <div class="form-group col-md-3">
                                <label for="nrproposta">nrproposta</label>
                                <input type="text" id="nrproposta" name="nrproposta" class="form-control"
                                    value="<?php echo $autentica->getNrproposta() ?>" required/>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary">Enviar</button>
                    </form>
                    <small>Normalmente dstoken se mantem como 'teste'</small>
                    <small>Valores padrão:</small>

                    <table class="table table-striped table-hover">
                        <thead>
                            <tr>
                                <th>Valor</th>
                                <th>Padrão Esperado</th>
                            </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td>cdcooper</td>
                            <td>integer | Código da Cooperativa</td>
                        </tr>
                        <tr>
                            <td>cdagenci</td>
                            <td>interger | Código da Agência</td>
                        </tr>
                        <tr>
                            <td>cdoperad</td>
                            <td>integer | Código do Operador</td>
                        </tr>
                        <tr>
                            <td>nrcpfcgc</td>
                            <td>integer | CPF/CNPJ</td>
                        </tr>
                        <tr>
                            <td>nrdconta</td>
                            <td>integer | número da conta</td>
                        </tr>
                        <tr>
                            <td>tpproduto</td>
                            <td>integer | tipo de produto | dev: 1</td>
                        </tr>
                        <tr>
                            <td>nrproposta</td>
                            <td>integer | Número da proposta </td>
                        </tr>
                        <tr>
                            <td>dstoken</td>
                            <td>string | dev: 'teste'</td>
                        </tr>
                        </tbody>
                    </table>
                    <small>Exemplo: ?cdcooper=1&cdagenci=1&cdoperad=1&nrcpfcgc=98528911543&dstoken=teste&nrdconta=442&tpproduto=1&nrproposta=123456</small>

                </div>
            </div>
        <?php
    }
    ?>
</div>

<!-- Modal -->
<div class="modal fade" id="errorModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header  text-white bg-danger">
        <h5 class="modal-title" id="exampleModalLabel">Erro</h5>
        </button>
      </div>
      <div class="modal-body">
        <?php 
            if(isset($retornoTelaUnica['error'])){
                echo $retornoTelaUnica['error'];
            }
        ?>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
      </div>
    </div>
  </div>
</div>

<script src="js/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
<script src="js/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
<script src="js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>

<script>

$(function(){

    var error = "<?php echo (isset($retornoTelaUnica["error"]) ? $retornoTelaUnica['error'] : '' ) ?>";
    if(error !== ""){
        $('#errorModal').modal('show')
    }

    $('#cdcooper').on('change',function(){
        $('#cdcooperSpan').text($(this).val());
    })
});

</script>

</body>
</html>