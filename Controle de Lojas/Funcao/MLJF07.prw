//Bibliotecas
#Include 'Protheus.ch'
#Include "TOPCONN.ch"
#Include 'FWMVCDef.ch'

//----------------------------------------------------------------------
/*/{PROTHEUS.DOC} MLJF07
FUNÇÃO MLJF07 - Reimpressão de comprovante retira
@VERSION PROTHEUS 12
@SINCE 30/10/2024
/*/
//----------------------------------------------------------------------

User Function MLJF07()
  Local aArea     := FWGetArea()
  Local aPARAMIXB := {}
  Local oPanel    := Nil
  Local oFont     := TFont():New('Arial Black',,-23,.T.)
  Local lContinua := .T.
  Local nTamOrc   := FWTamSX3("L1_NUM")[1]
	Local cNumOrc   := Space(nTamOrc)

  Private oDialog := Nil
  Private lBtOK   := .F.

  If IsInCallStack("STIPOSMAIN")

    oDialog := FWDialogModal():New()
		oDialog:SetBackground( .T. ) 
		oDialog:SetTitle( 'Numero do Orcamento' )
		oDialog:SetSize( 080, 190 )
		oDialog:EnableFormBar( .T. )
		oDialog:SetCloseButton( .T. )
		oDialog:SetEscClose( .T. )
		oDialog:CreateDialog()
		oDialog:CreateFormBar()
		oDialog:addCloseButton(Nil, "Fechar")
    oDialog:addOkButton({|| fButtomOk() },'Confirmar')
		oPanel := oDialog:GetPanelMain()
		oTSay  := TSay():New(10,5,{|| "Nº Orcamento:"},oPanel,,oFont,,,,.T.,,,110,100,,,,,,.T.)
              @ 008,115 MSGET cNumOrc SIZE 050,020 FONT oFont OF oPanel PIXEL
		oDialog:Activate()

    If lBtOK .And. !Empty(cNumOrc)
      DBSelectArea("SL1")
      IF !SL1->(MSSeek(xFilial("SL1") + AllTrim(StrZero(Val(cNumOrc),nTamOrc)) ))
        FWAlertWarning("Nenhum orçamento encontrado com o número: " + AllTrim(StrZero(Val(cNumOrc),nTamOrc)),"Reimpressao de comprovantes!")
        lContinua := .F.
      EndIF 
    EndIF 

  EndIF

  IF lContinua
    IF LjProfile(8)
      If ExistBlock("SCRPED")
        ExecBlock("SCRPED" ,.F.,.F., aPARAMIXB )
      EndIF
    EndIF
  EndIF 

  FWRestArea(aArea)

Return

/*/{Protheus.doc} fButtomOk
    Botão OK 
/*/
Static Function fButtomOk()
    lBtOK := .T.
    oDialog:DeActivate()
Return 
