#INCLUDE 'Protheus.ch'
#INCLUDE 'PRTOPDEF.CH'

Static FR13_CONTROL := .F.

//----------------------------------------------------------------------------------------
/*/{PROTHEUS.DOC} FRTECF13
Indica se o ECF faz o arredondamento (.T.) ou o truncamento (.F.) dos valores.
@OWNER MADECENTER
@VERSION PROTHEUS 12
@SINCE 24/09/2024
/*/
//----------------------------------------------------------------------------------------
User Function FRTECF13()
	Local aArea    := FWGetArea()
  Local aAreaMDD := MDD->(FWGetArea())
  Local nPosEnt  := aScan(aHeader, {|x| Alltrim(x[2])=="LR_ENTREGA" })
  Local lRet     := .T.

  IF FR13_CONTROL .And. SB1->B1_VALEPRE == '1' //Produto do tipo Vale Presente
		fTelaPrc()
    aCols[N][nPosEnt] := '2'
    FR13_CONTROL := .F.
	Else
    FR13_CONTROL := .T.
  EndIF 
  
  FWRestArea(aAreaMDD)
  FWRestArea(aArea)

Return lRet

//--------------------------------------------------------------------------------------------------------------
/*/{PROTHEUS.DOC} fTelaPrc
FUNÇÃO fTelaPrc - Altera valor do Produto Vale Presente na tabela de preço Padrão.
/*/
//--------------------------------------------------------------------------------------------------------------

Static Function fTelaPrc(cTabRet,cCodPrd)
  Local oPanel   := Nil
  Local oDialog  := Nil
  Local nValor   := 0

  oDialog := FWDialogModal():New()
  oDialog:SetBackground( .T. ) 
  oDialog:SetTitle( 'R$ Vale Presente' )
  oDialog:SetSize( 090, 120 )
  oDialog:EnableFormBar( .T. )
  oDialog:SetCloseButton( .T. )
  oDialog:SetEscClose( .T. )
  oDialog:CreateDialog()
  oDialog:CreateFormBar()
  oDialog:AddButton('Confirmar' , { || IIF( Empty(nValor),MsgAlert("Necessário informar o valor!","Vale Presente"),oDialog:DeActivate())}, 'Confirmar' ,,.T.,.F.,.T.,)

  oPanel := oDialog:GetPanelMain()

    oSay1  := TSay():New(17,10,{|| "Valor: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
    @ 12,28 MSGET nValor SIZE 080,015 OF oPanel PICTURE PesqPict("SLR","LR_VRUNIT") PIXEL

  oDialog:Activate()

  If !Empty(nValor)
    DbSelectArea("MDD")
    IF MDD->(MSSeek(xFilial("MDD") + MDD->MDD_CODIGO))
      RecLock("MDD",.F.)
        MDD->MDD_VALOR := nValor
      MDD->(MSUnlock())
    EndIF
	aCOLS[N][5] := nValor
	aCOLS[N][6] := nValor
  EndIF 

Return
