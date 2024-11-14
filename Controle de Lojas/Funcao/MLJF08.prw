//Bibliotecas
#Include 'Protheus.ch'

//-------------------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF08
Funcao utilizada para controle de liberção do Pedido de Venda 
@VERSION PROTHEUS 12
@SINCE 14/11/2024
/*/
//-------------------------------------------------------------------------------

User Function MLJF08()
  Local aArea     := FWGetArea()
  Local cFunBkp   := FunName()
  Local oPanel    := Nil
  Local oFont     := TFont():New('Arial Black',,-23,.T.)
  Local nTamPed   := FWTamSX3("C5_NUM")[1]
  Local aMvPar    := {}
  Local lContinua := .T.
  Local nMv

  Private oDialog := Nil
  Private cNumPed := SL1->L1_DOCPED
  Private lBtOK   := .F.

  For nMv := 1 To 40
		aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
	Next nMv

  oDialog := FWDialogModal():New()
	oDialog:SetBackground( .T. ) 
	oDialog:SetTitle( 'Numero do Pedido' )
	oDialog:SetSize( 080, 200 )
	oDialog:EnableFormBar( .T. )
	oDialog:SetCloseButton( .T. )
	oDialog:SetEscClose( .T. )
	oDialog:CreateDialog()
	oDialog:CreateFormBar()
	oDialog:addCloseButton(Nil, "Fechar")
  oDialog:addOkButton({|| fButtomOk() },'Confirmar')
	oPanel := oDialog:GetPanelMain()
	oTSay  := TSay():New(10,5,{|| "Nº Pedido:"},oPanel,,oFont,,,,.T.,,,110,100,,,,,,.T.)
            @ 008,090 MSGET cNumPed SIZE 050,020 FONT oFont OF oPanel PIXEL
	oDialog:Activate()
  
  If lBtOK .And. !Empty(cNumPed)
    cNumPed := AllTrim(StrZero(Val(cNumPed),nTamPed))
    DBSelectArea("SC5")
    SC5->(dbSetOrder(1))
    IF !SC5->(MSSeek(xFilial("SC5") + cNumPed ))
      FWAlertWarning("Nenhum pedido encontrado com o número: " + cNumPed,"Liberacao de Pedido!")
      lContinua := .F.
    EndIF 
  EndIF

  If lContinua
    Do Case
      Case Upper(AllTrim(cCadastro)) == "VENDA ASSISTIDA - LIBERAR QUANTIDADE"
        
        DBSelectArea("SC9")
        IF SC9->(MsSeek(xFilial("SC9") + cNumPed ))
          While SC9->(!Eof()) .AND. SC9->C9_FILIAL + cNumPed == SL1->L1_FILIAL + cNumPed
            If Empty(SC9->C9_NFISCAL) .And. Empty(SC9->C9_BLEST)
              DBSelectArea("SC6")
              If SC6->(MSSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO ))
                If SC6->C6_QTDEMP > 0 
                  RecLock("SC6",.F.)
                    SC6->C6_QTDEMP := 0
                  SC6->(MsUnLock())
                EndIF 
                RecLock("SC9",.F.)
                  DbDelete()
                SC9->(MsUnLock()) 
              EndIF
            EndIF 
          SC9->(DBSkip())
          End
        EndIF

        SetFunName("MATA440")
        DBSelectArea("SC5")
        If SC5->(MSSeek(xFilial("SC5") + cNumPed))
          MATA440()
        EndIF 

      Case Upper(AllTrim(cCadastro)) == "VENDA ASSISTIDA - GERAR NOTA FISCAL"
        SetFunName("MATA460A")
        MATA460A()
    EndCase
  EndIF 

  For nMv := 1 To Len( aMvPar )
		&( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
	Next nMv

  SetFunName(cFunBkp)
  FWRestArea(aArea)

Return 

/*/{Protheus.doc} fButtomOk
    Botão OK 
/*/
Static Function fButtomOk()
    lBtOK := .T.
    oDialog:DeActivate()
Return
