#Include "protheus.ch"

/*-----------------------------------------------------------------------------------------------------
  Fun��o: LJ720CTRL

  Tipo: Ponto de entrada
  
  Este ponto de entrada � executado no in�cio do programa LOJA720 na montagem da tela,
  permitindo configurar algumas propriedades de alguns objetos da tela, como por exemplo: 
  Radio Buttons e consulta padr�o para busca do cliente.
  
  � passado como par�metro um array com os controles que podem ser configurados,
  e deve ser retornado o array com as altera��es desejadas, efetuadas nos controles desejados.
  
  Retorno:
    Array 
-----------------------------------------------------------------------------------------------------*/
User Function LJ720CTRL()
  Local aRet := ParamIXB

  //-------------------------
  //Radio Button "Processo"
  //-------------------------
  aRet[1][2] := 2 //1=Troca; 2=Devolu��o
  aRet[1][3] := .F. //.T.=Permite editar, .F.=N�o permite editar

  //-------------------------
  //Radio Button "Origem"
  //-------------------------
  aRet[2][2] := 1 //1=Com Documento de Entrada; 2=Sem Documento de Entrada
  aRet[2][3] := .F. //.T.=Permite editar, .F.=N�o permite editar

  //-------------------------
  //Radio Button "Buscar Venda Por"
  //-------------------------
  aRet[3][2] := 2 //1=Cliente e Data; 2=No. Cupom / Nota
  aRet[3][3] := .T. //.T.=Permite editar, .F.=N�o permite editar

  //-------------------------
  //Consulta Padrao Cliente
  //-------------------------
  //aRet[4][2] := "XXX" //Consulta Padr�o do Cliente (deve existir no SXB)
  //aRet[4][3] := .T. //.T.=Permite editar, .F.=N�o permite editar

Return aRet
