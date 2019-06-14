<?php
/********************************************************************************

 ALTERAÇÕES: 12/12/2016 - Removida validação do HTTP_REFER  (Guilherme/SUPERO)

********************************************************************************/

class ParamInjection {

    var $Nome; // Nome ou chave do parâmetro
    var $Tipo; // Tipo de dado 0 = número e 1 = texto
    var $Min;  // Tamanho máximo
    var $Max;  // Tamanho mínimo


    /**
     * Cria um parâmetro com tratamento diferenciado
     *
     * @param string $nome
     * @param integer $tipo
     * @param integer $min
     * @param integer $max
     * @return ParamInjection
     */
    function ParamInjection($nome, $tipo = 1, $min = 0, $max = 100) {

        $this->Nome = $nome;
        $this->Tipo = $tipo;
        $this->Min  = $min;
        $this->Max  = $max;

    }

    /**
     * É texto?
     *
     * @return bool
     */
    function isTexto() {
        return ($this->Tipo == 1);
    }

    /**
     * É número?
     *
     * @return bool
     */
    function isNumero() {
        return ($this->Tipo == 0);
    }


    /**
     * Faz a verificação do parâmetro
     *
     * @param mixed $valor
     */
    function doProteger($valor) {

        if ($this->isNumero() && !$this->isValidaType($valor)) {
            die("Parâmetros Incorretos! [1]");
        }

        if (strlen($valor) < $this->Min) {
            die("Parâmetros Incorretos! [2]");
        }

        if (strlen($valor) > $this->Max) {
            die("Parâmetros Incorretos! [3]");
        }

    }



    function isValidaType($valor) {

        if ($valor == "") {
            return true;
        }

        $valor = ereg_replace("[.,]","",$valor);

        // Para não deixar passar a letra 'e', que é considerada um valor, junto com números
        if (!ereg('^[0-9]*$', $valor)) {
            return false;
        }

        if (is_numeric($valor)) {
            return true;
        }
        else {
            return false;
        }
    }

}

class AntiInjection {

    var $Palavras;     // Palavras maliciosas
    var $ParamsEx;     // Armazena os parâmetros que possuem tratamento diferenciado
    var $MagicQuotes;  // Verifica se o magic quotes está habilitado
    var $_HTTP_REFERER = true; //Nao deixa acessa a pagina fora da mesma janela. Quando for abrir em POP-up deve desabilitar essa função

    function AntiInjection() {

        $this->Palavras = array("from","select","insert","delete","where","drop table","show tables","/*","*/","--","#","//","/","\\","\\\\",";","'",'"');
        $this->ParamsEx = array();
        $this->MagicQuotes = get_magic_quotes_gpc();

    }

    function isHTTP_REFERER($is) {
        $this->_HTTP_REFERER = $is;
    }

    /**
     * Remove os valores maliciosos encontrados no array
     *
     * @param array $array
     */
    function doValidar(&$array) {

/*
        // Se a pessoa digitar a URL direto no browser, não pode deixar passar.
        if ($this->_HTTP_REFERER) {
            if ($_SERVER['HTTP_REFERER'] == "") {
                die("Parâmetros Incorretos! [4]");
            }
        }
*/

        foreach($array as $key => $value) {
            if (is_array($array[$key])) {

                $this->doValidar($array[$key]);

            } else {

                if (!$this->MagicQuotes)
                    $array[$key] = addslashes($array[$key]);

                $array[$key] = str_replace($this->Palavras, "", trim($array[$key]));

            }

        }

    }

    /**
     * Trata os valores maliciosos encontrados no array
     *
     * @param array $array
     */
    function doProteger(&$array) {

        foreach($this->ParamsEx as $value) {
            if (array_key_exists($value->Nome, $array)) {
                $value->doProteger($array[$value->Nome]);
            }
        }

        $this->doValidar($array);

    }

    /**
     * Adiciona uma palavra maliciosa
     *
     * @param string $palavra
     */
    function add($palavra) {

        $this->Palavras[] = $palavra;

    }

    /**
     * Remove uma palavra maliciosa
     *
     * @param string $palavra
     */
    function del($palavra) {

        foreach($this->Palavras as $key => $value) {

            if ($value == $palavra)
                $this->Palavras[$key] = null;

        }

    }

    /**
     * Adiciona um parâmetro com tratamento diferenciado
     *
     * @param string $chave
     */
    function addParam($nome, $tipo = 1, $min = 0, $max = 100) {

        $this->ParamsEx[] = new ParamInjection($nome, $tipo, $min, $max);

    }

}

class AntiNomeDaTabela extends AntiInjection {

    function AntiNomeDaTabela() {

        parent::AntiInjection();

        $this->add("2");
        $this->del("//");
        $this->addParam("teste", 1, 1, 3);

    }

}

class AntiClientScript {
    function AntiClientScript(){
        if($_GET){
            foreach($_GET as $get => $value){
                $value = strip_tags($value,'<(.*?)>');
                $_GET[$get] = $value;
            }
        }

        if($_POST){
            foreach($_POST as $post => $value){
                $value = strip_tags($value,'<(.*?)>');
                $_POST[$post] = $value;
            }
        }

        if($_SERVER){
            $_SERVER["PHP_SELF"] = preg_replace('/[^a-z0-9_-]+/i','', $_SERVER["PHP_SELF"]);
        }
    }

    function AntiScript($valor){
        return strip_tags($valor,'<(.*?)>^#$!@*= !&+-%~`\'"\\/');
    }
}



?>
