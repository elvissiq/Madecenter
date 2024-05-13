#Include 'Protheus.ch'
/*/
  @param
  @return Não retorna nada
  @author Totvs Nordeste (Elvis Siqueira)
  @owner Totvs S/A
  @version Protheus 10, Protheus 11,Protheus 12
  @since 09/05/2024 
  @sample
        Ponto de Entrada utilizado para realizar a Reserva dos produtos da venda sem a exibicao da interface para o usuario.
        Este ponto de entrada eh utilizado apenas para selecionar as opcoes que o sistema passa como parametro, ou seja,
        utiliza o mesmo conceito como se estivesse utilizando a interface (tela) para o ususario fazer a selecao das opcoes,
        porem a selecao eh feita por este PE sem a exibicao da interface.			
  @obs
  @project
  @menu 
  @history
  09/05/2024 - Desenvolvimento da Rotina.
/*/

User Function LJRESERV()
  Local aArea := FWGetArea()
  Local aRet  := {} //Retorno da funcao
  Local cOper := PARAMIXB[1] //Tipo de Operação em execução (1=Momento; 2=Momento)
  
  Private aLojas    := PARAMIXB[2] //Lojas disponiveis para efetuar a Reserva
  Private aProdutos := PARAMIXB[3] //Produtos da venda que a serem reservados
  Private aEstoque  := PARAMIXB[4] //Saldos dos Estoques nas lojas/armazem
  Private lConfirma := .F.

  Do Case 
    Case cOper == "1"
      fSelectLj()
      //fReserva()
      aRet := { lConfirma, aLojas, aProdutos, aEstoque }
    Case cOper != "1"
      aRet := { lConfirma, aLojas, aProdutos, aEstoque }
  End Case 

  FWRestArea(aArea)
  
Return aRet

/*/{Protheus.doc} fSelectLj
Tela para seleção das Lojas e Produtos
@type function
@return return_type, return_description
/*/
Static Function fSelectLj()
  Local oDlgConsulta
  Local oLojas
  Local oTodasLojas
  Local oProdutos
  Local oTodosProds
  Local oOk 			  := LoadBitmap(GetResources(), "LBOK")
  Local oNo 			  := LoadBitmap(GetResources(), "LBNO")
  Local lTodasLojas	:= .F.
  Local lTodosProds	:= .F.
  Local nX

	DEFINE MSDIALOG oDlgConsulta TITLE "Identificação de lojas" FROM 0,0 TO 300,490 PIXEL OF oDlgVA
			
		@ 08,08 LISTBOX oLojas FIELDS HEADER "","Loja" FIELDSIZES 14,130 SIZE 230,55 PIXEL /*FONT "Arial"*/ OF oDlgConsulta
		oLojas:SetArray(aLojas)
		oLojas:bLDblClick := {|| (aLojas[oLojas:nAt,1] := !aLojas[oLojas:nAt,1]) }
		oLojas:bLine := {|| {If(aLojas[oLojas:nAt,1],oOk,oNo),aLojas[oLojas:nAt,3] }}
			
		@ 65,12 CHECKBOX oTodasLojas VAR lTodasLojas PROMPT "Selecionar Todas" SIZE 53,8 PIXEL OF oDlgConsulta;
		ON CHANGE {|| aEval(aLojas,{|x| x[1]:= lTodasLojas }),oLojas:Refresh() }
			
		@ 75,08 LISTBOX oProdutos FIELDS HEADER "","Codigo","Descrição","Quant." FIELDSIZES 14,40,123,40 SIZE 230,55 PIXEL /*FONT "Arial"*/ OF oDlgConsulta
		oProdutos:SetArray(aProdutos)
		oProdutos:bLDblClick := {|| (aProdutos[oProdutos:nAt,1] := !aProdutos[oProdutos:nAt,1])}
		oProdutos:bLine := {|| {If(aProdutos[oProdutos:nAt,1],oOk,oNo),;
		aProdutos[oProdutos:nAt,3],aProdutos[oProdutos:nAt,4],;
		Transform(aProdutos[oProdutos:nAt,5],PesqPict("SL2","L2_QUANT")) }}
			
		@ 133,12 CHECKBOX oTodosProds VAR lTodosProds PROMPT "Selecionar Todos" SIZE 53,8 PIXEL OF oDlgConsulta;
		ON CHANGE {|| aEval(aProdutos,{|x| x[1]:= lTodosProds }),oProdutos:Refresh() }
			
		DEFINE SBUTTON FROM 133, 180 TYPE 1 ACTION (lContinua := .T. ,oDlgConsulta:End()) ENABLE PIXEL OF oDlgConsulta
		DEFINE SBUTTON FROM 133, 210 TYPE 2 ACTION oDlgConsulta:End() ENABLE PIXEL OF oDlgConsulta
			
	ACTIVATE MSDIALOG oDlgConsulta CENTERED
  
  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Limpa os arrays aLojas e aProdutos. Deixa so os que foram selecionados   ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

  nCont := 0
  For nX := Len(aLojas) to 1 Step -1
		If !aLojas[nX][1]
			aDel( aLojas, nX )
			nCont ++
		Endif
	Next nX
	aSize( aLojas, Len(aLojas)-nCont )
	
	nCont := 0
	For nX := Len(aProdutos) to 1 Step -1
		If !aProdutos[nX][1]
			aDel( aProdutos, nX )
			nCont ++
		Endif
	Next nX
	aSize( aProdutos, Len(aProdutos)-nCont )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se foi selecionada alguma loja ou produto para a pesquisa       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aScan(aLojas,{ |x| x[1] }) == 0
		Aviso( "Atenção", "Não foi selecionada nenhuma loja para consulta", {"Ok"} )
		lContinua := .F.
	Endif
	If aScan(aProdutos,{ |x| x[1] }) == 0
		Aviso( "Atenção", "Não foi selecionado nenhum produto para consulta", {"Ok"} )
		lContinua := .F.
	Endif

Return
