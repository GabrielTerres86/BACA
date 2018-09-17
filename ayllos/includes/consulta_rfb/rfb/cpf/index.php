<html>
        <head>
                <title>CPF e Captcha</title>
        </head>
        <body>
        <form method="post" action="processa.php">
                <p><span class="titleCats">CPF</span>
                  <br />
                  <input type="text" name="nrcpfcgc" maxlength="19" value="" required /> 
                  <br />
                  <span class="titleCats">Data</span>
                  <br />
                  <input type="text" name="dtnasctl" maxlength="19" value="" required /> 
                  <b style="color: red">Captcha</b>
                  <br />
                  <img src="getcaptcha.php" border="0">
                  <br />
                  <input type="text" name="dscaptch" maxlength="6" required />
                  <b style="color: red">O que vê na imagem acima?</b>
                  <br />
                </p>
                <p>
                  <input id="id_submit" name="enviar" type="submit" value="Consultar"/>
                </p>
        </form>
        </body>
</html>