#Include "PROTHEUS.ch"
#Include "FWMVCDef.ch"
#Include "TopConn.CH"

// ---------------------------------------------------------
/*/ Rotina XLOJ001
  
  Gera borderô após finalizar venda no Controle de Lojas

  @author Elvis Siqueira - Totvs Nordeste
  Retorno
  @historia
  06/02/2024 - Desenvolvimento da Rotina.
/*/
// ---------------------------------------------------------
User Function XLOJ001(pOrcam)
  
  Private aCampos  := {}
  Private cL1Num   := pOrcam
  Private aMVBanco := StrTokArr(SuperGetMV("MV_XLJBANC",.F.,""), "/")
  
  If !Empty(aMVBanco)
    fnGerBor()
  Else
    fnMonTela()
  EndIF 

Return

Static Function fnMonTela()

  Private aButtons := {{.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.T.,"Confirmar"},;
                       {.T.,"Fechar"},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil}}

  aAdd(aCampos,{"T1_NUM","C",TamSX3("L1_NUM")[1],0})

  oTempTRB1 := FWTemporaryTable():New("TRB1")
  oTempTRB1:SetFields(aCampos)
  oTempTRB1:AddIndex("01",{"T1_NUM"})
  oTempTRB1:Create()

  aCampos := {}

  aAdd(aCampos,{"T2_NUM"    ,"C",TamSX3("L1_NUM")[1],0})
  aAdd(aCampos,{"T2_CODBCO" ,"C",TamSX3("A6_COD")[1],0})
  aAdd(aCampos,{"T2_NOMBCO" ,"C",TamSX3("A6_NOME")[1],0})
  aAdd(aCampos,{"T2_AGENCIA","C",TamSX3("A6_AGENCIA")[1],0})
  aAdd(aCampos,{"T2_DVAGE"  ,"C",TamSX3("A6_DVAGE")[1],0})
  aAdd(aCampos,{"T2_NUMCON" ,"C",TamSX3("A6_NUMCON")[1],0})
  aAdd(aCampos,{"T2_DVCTA"  ,"C",TamSX3("A6_DVCTA")[1],0})
  aAdd(aCampos,{"T2_SUBCTA" ,"C",TamSX3("EA_SUBCTA")[1],0})

  oTempTRB2 := FWTemporaryTable():New("TRB2")
  oTempTRB2:SetFields(aCampos)
  oTempTRB2:AddIndex("01",{"T2_NUM","T2_CODBCO","T2_NUMCON"})
  oTempTRB2:Create()

  FWExecView("Selecionar Banco","BSLOJ001",MODEL_OPERATION_INSERT,,{|| .T.},,80,aButtons)

  oTempTRB1:Delete() 
  oTempTRB2:Delete() 

Return


// -----------------------------------------
/*/ Função ModelDef

   Define as regras de negocio.

  @author Totvs Nordeste
  Return
  @Since  28/04/2023
/*/
// -----------------------------------------
Static Function ModelDef() 
  Local oModel
  Local oStrTRB1 := fnM01TB1()
  Local oStrTRB2 := fnM01TB2()
  
  oModel := MPFormModel():New("Selecionar Banco",,,{|oModel| fnGerBor(oModel)})  

  oModel:SetDescription("Selecionar Banco")    
  oModel:AddFields("MSTCAB",,oStrTRB1)
  
  oModel:AddGrid("DETBCO","MSTCAB",oStrTRB2)

  oModel:SetPrimaryKey({"T1_NUM"})
  oModel:SetRelation("DETBCO",{{"T2_NUM","T1_NUM"}}, TRB2->(IndexKey(1)))
Return oModel

// -----------------------------------------
/*/ Função fnGerBor

   Gerar Bordero.

  @author Totvs Nordeste
  Return
  @Since  28/04/2023
/*/
// -----------------------------------------
Static Function fnGerBor(oModel)
  Local lRet    := .T.
  Local oGrdBco := oModel:GetModel("DETBCO")
  Local cTmp    := "TMPBOR"
  Local cFiltro := ""
  Local cNumBor := ""
  Local cBanco  := ""
  Local cAgenc  := ""
  Local cConta  := ""
  Local cSubCC  := ""
  Local aRegTit := {}
  Local aRegBor := {}

  Private lMsErroAuto    := .F.
  Private lMsHelpAuto    := .T.
  Private lAutoErrNoFile := .T.

  dbSelectArea("SL1")
  SL1->(dbSetOrder(1))
  
  If ! SL1->(dbSeek(FWxFilial("SL1") + cL1NUM))
     Return lRet
  EndIf

 // -- Filtro SQL para para adicionar os titulos no borderô
 // -------------------------------------------------------
  cFiltro := "%" + "SE1.E1_FILIAL = '" + FWxFilial("SE1") + "'"
  cFiltro += " and SE1.E1_PREFIXO = '" + SL1->L1_SERIE + "'"
  cFiltro += " and SE1.E1_NUM = '" + SL1->L1_DOC + "'"
  cFiltro += " and SE1.E1_TIPO ='BOL'" + "%"
 // --------------------------------------------------------

  If Select(cTmp) > 0
     (cTmp)->(dbCloseArea())
  EndIf

  BeginSQL Alias cTmp
    Select SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO
      from %table:SE1% SE1
       where %exp:cFiltro%
         and SE1.E1_SALDO > 0
         and SE1.%NotDel%
  EndSQL

  While ! (cTmp)->(Eof())
    aAdd(aRegTit,{{"E1_FILIAL" , (cTmp)->E1_FILIAL},;
                  {"E1_PREFIXO", (cTmp)->E1_PREFIXO},;
                  {"E1_NUM"    , (cTmp)->E1_NUM},;
                  {"E1_PARCELA", (cTmp)->E1_PARCELA},;
                  {"E1_TIPO"   , (cTmp)->E1_TIPO}})

    (cTmp)->(dbSkip())
  EndDo

  (cTmp)->(dbCloseArea())

  If Empty(aRegTit)
     Return lRet
  EndIf

  If !Empty(aMVBanco)
    cBanco := aMVBanco[1]
    cAgenc := aMVBanco[2]
    cConta := aMVBanco[3]
    cSubCC := aMVBanco[4]
  Else
    cBanco := oGrdBco:GetValue("T2_CODBCO")
    cAgenc := oGrdBco:GetValue("T2_AGENCIA")
    cConta := oGrdBco:GetValue("T2_NUMCON")
    cSubCC := oGrdBco:GetValue("T2_SUBCTA")
  EndIF

 // -- Informações bancárias para o borderô
 // ---------------------------------------
  aAdd(aRegBor, {"AUTBANCO"   , PadR(cBanco,TamSX3("A6_COD")[1])})
  aAdd(aRegBor, {"AUTAGENCIA" , PadR(cAgenc,TamSX3("A6_AGENCIA")[1])})
  aAdd(aRegBor, {"AUTCONTA"   , PadR(cConta,TamSX3("A6_NUMCON")[1])})
  aAdd(aRegBor, {"AUTSITUACA" , PadR("1",TamSX3("E1_SITUACA")[1])})
  aAdd(aRegBor, {"AUTNUMBOR"  , PadR(cNumBor,TamSX3("E1_NUMBOR")[1])})
  aAdd(aRegBor, {"AUTSUBCONTA", PadR(cSubCC,TamSX3("EA_SUBCTA")[1])})
  aAdd(aRegBor, {"AUTESPECIE" , PadR("1",TamSX3("EA_ESPECIE")[1])})

  MsExecAuto({|a,b| FINA060(a,b)},3,{aRegBor, aRegTit})

  If lMsErroAuto
     MostraErro()
   else
    // -- Pegar no borderô, ajustar campos Novo Gestor
    // -----------------------------------------------
     If Select(cTmp) > 0
        (cTmp)->(dbCloseArea())
     EndIf

     BeginSQL Alias cTmp
       Select SE1.E1_NUMBOR
         from %table:SE1% SE1, %table:SEA% SEA
          where %exp:cFiltro%
            and SEA.EA_FILIAL  = SE1.E1_FILIAL
            and SEA.EA_PREFIXO = SE1.E1_PREFIXO
            and SEA.EA_NUM     = SE1.E1_NUM
            and SEA.EA_TIPO    = SE1.E1_TIPO
            and SE1.%NotDel%
            and SEA.%NotDel%
     EndSQL
 
     If ! (cTmp)->(Eof())
        dbSelectArea("SEA")
        SEA->(dbSetOrder(1))
 
        If SEA->(dbSeek(FWxFilial("SEA") + (cTmp)->E1_NUMBOR))
           While ! SEA->(Eof()) .and. SEA->EA_FILIAL == FWxFilial("SEA") .and.;
                 SEA->EA_NUMBOR == (cTmp)->E1_NUMBOR
             Reclock("SEA",.F.)
               Replace SEA->EA_BORAPI  with "S"
               Replace SEA->EA_SUBCTA  with PadR(oGrdBco:GetValue("T2_SUBCTA"),TamSX3("EA_SUBCTA")[1])
               Replace SEA->EA_ESPECIE with IIf(oGrdBco:GetValue("T2_CODBCO") == "001","2",StrZero(1,TamSX3("EA_ESPECIE")[1]))
               Replace SEA->EA_APIMAIL with "3"
               Replace SEA->EA_TRANSF  with "F" 
             SEA->(MsUnlock())

             SEA->(dbSkip())
           EndDo   
        EndIf
     EndIf

     (cTmp)->(dbCloseArea()) 
  EndIf
Return lRet
 
//-------------------------------------
/*/ Função fnM01TB1()
  Estrutura do detalhe do cabeçalho.					  
/*/
//--------------------------------------
Static Function fnM01TB1()
  Local oStruct := FWFormModelStruct():New()
 
  oStruct:AddTable("TRB1",{"T1_NUM"},"Venda")
  oStruct:AddField("No Orcamento","No Orcamento","T1_NUM","C",TamSX3("L1_NUM")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Return oStruct

//-------------------------------------
/*/ Função fnM01TB2()
  Estrutura do detalhe dos produtos.							  
/*/
//--------------------------------------
Static Function fnM01TB2()
  Local oStruct := FWFormModelStruct():New()
 
  oStruct:AddTable("TRB2",{"T2_NUM","T2_CODBCO","T2_NUMCON"},"Bancos")
  oStruct:AddField("Orcamento","Orcamento","T2_NUM"    ,"C",TamSX3("L1_NUM")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Banco"    ,"Banco"    ,"T2_CODBCO" ,"C",TamSX3("A6_COD")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Nome"     ,"Nome"     ,"T2_NOMBCO" ,"C",TamSX3("A6_NOME")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Agência"  ,"Agência"  ,"T2_AGENCIA","C",TamSX3("A6_AGENCIA")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Dig. Ag." ,"Dig. Ag." ,"T2_DVAGE"  ,"C",TamSX3("A6_DVAGE")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Conta"    ,"Conta"    ,"T2_NUMCON" ,"C",TamSX3("A6_NUMCON")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Dig. Cta" ,"Dig. Cta" ,"T2_DVCTA"  ,"C",TamSX3("A6_DVCTA")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("SubConta" ,"SubConta" ,"T2_SUBCTA" ,"C",TamSX3("EE_SUBCTA")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Return oStruct

//-------------------------------------------------------------------
/*/ Função ViewDef()
    Definição da View
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 
  Local oModel   := ModelDef() 
  Local oStrTRB1 := fnV01TB1()
  Local oStrTRB2 := fnV01TB2()
  Local oView

  oView := FWFormView():New() 
   
  oView:SetModel(oModel)    
  oView:AddField("FCAB",oStrTRB1,"MSTCAB") 
  oView:AddGrid("FDET",oStrTRB2,"DETBCO") 

 // --- Definição da Tela
 // ---------------------
  oView:CreateHorizontalBox("BXCAB",05)
  oView:CreateHorizontalBox("BXDET",95)  

 // --- Definição dos campos
 // ------------------------    
  oView:SetOwnerView("FCAB","BXCAB")
  oView:SetOwnerView("FDET","BXDET")

  oView:SetViewAction("ASKONCANCELSHOW",{|| .F.})           // Tirar a mensagem do final "Há Alterações não..."
  oView:SetAfterViewActivate({|oView| fnLerBco(oView)})    // Carregar dados antes de montar a tela
  oView:ShowInsertMsg(.F.)
Return oView

//-------------------------------------------
/*/ Função fnV01TB1
   Estrutura do detalhe do Cabeçalho (View)
/*/
//-------------------------------------------
Static Function fnV01TB1()
  Local oViewTB1 := FWFormViewStruct():New() 

 // -- Montagem Estrutura
 //      01 = Nome do Campo
 //      02 = Ordem
 //      03 = Título do campo
 //      04 = Descrição do campo
 //      05 = Array com Help
 //      06 = Tipo do campo
 //      07 = Picture
 //      08 = Bloco de PictTre Var
 //      09 = Consulta F3
 //      10 = Indica se o campo é alterável
 //      11 = Pasta do Campo
 //      12 = Agrupamnento do campo
 //      13 = Lista de valores permitido do campo (Combo)
 //      14 = Tamanho máximo da opção do combo
 //      15 = Inicializador de Browse
 //      16 = Indica se o campo é virtual (.T. ou .F.)
 //      17 = Picture Variavel
 //      18 = Indica pulo de linha após o campo (.T. ou .F.)
 // --------------------------------------------------------
  oViewTB1:AddField("T1_NUM","01","No Orcamento","No Orcamento",Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewTB1

//-------------------------------------------
/*/ Função fnV01TB2
   Estrutura do detalhe do Grid (View)
/*/
//-------------------------------------------
Static Function fnV01TB2()
  Local oViewTB2 := FWFormViewStruct():New() 

  oViewTB2:AddField("T2_CODBCO" ,"01","Banco"    ,"Banco"    ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB2:AddField("T2_NOMBCO" ,"02","Nome"     ,"Nome"     ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB2:AddField("T2_AGENCIA","03","Agência"  ,"Agência"  ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB2:AddField("T2_DVAGE"  ,"04","Dig. Age.","Dig. Age.",Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB2:AddField("T2_NUMCON" ,"05","Conta"    ,"Conta"    ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB2:AddField("T2_DVCTA"  ,"06","Dig. Cta" ,"Dig. Cta" ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB2:AddField("T2_SUBCTA" ,"07","SubConta" ,"SubConta" ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewTB2

//-------------------------------------------------
/*/ Função fnLerBco
  Carregar os possíveis bancos para envie Boleto.
  @Parâmetro: oView = Objecto View
/*/
//--------------------------------------------------
Static Function fnLerBco(oView)
  Local oModel  := FwModelActive()
  Local oCabTB1 := oModel:GetModel("MSTCAB")
  Local oGrdTB2 := oModel:GetModel("DETBCO")
  Local cQuery  := ""

  oCabTB1:SetValue("T1_NUM", cL1NUM)

  cQuery := "Select SA6.A6_COD, SA6.A6_NOME, SA6.A6_AGENCIA, SA6.A6_DVAGE, SA6.A6_NUMCON, SA6.A6_DVCTA,"
  cQuery += "       SEE.EE_SUBCTA"
  cQuery += "  from " + RetSqlName("SA6") + " SA6, " + RetSqlName("SEE") + " SEE"
  cQuery += "   where SA6.D_E_L_E_T_ <> '*'"
  cQuery += "     and SA6.A6_FILIAL  = '" + FWxFilial("SA6") + "'"
  cQuery += "     and SA6.A6_BCOOFI  <> ''"
  cQuery += "     and SEE.D_E_L_E_T_ <> '*'"
  cQuery += "     and SEE.EE_FILIAL  = '" + FWxFilial("SEE") + "'"
  cQuery += "     and SEE.EE_CODIGO  = SA6.A6_COD"
  cQuery += "     and SEE.EE_AGENCIA = SA6.A6_AGENCIA"
  cQuery += "     and SEE.EE_DVAGE   = SA6.A6_DVAGE"
  cQuery += "     and SEE.EE_CONTA   = SA6.A6_NUMCON"
  cQuery += "     and SEE.EE_DVCTA   = SA6.A6_DVCTA"
  cQuery += "  Order by SA6.A6_COD"
  cQuery := ChangeQuery(cQuery)
  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"QSA6",.F.,.T.)      
  
  If QSA6->(Eof())
     Help(,,"HELP",,"Não bancos configurados para emissão de boletos.",1,0)

     QSA6->(dbCloseArea())

     Return
  EndIf

  oGrdTB2:SetNoInsertLine(.F.)
  oGrdTB2:SetNoDeleteLine(.F.)
  oGrdTB2:SetNoUpdateLine(.F.)

  While ! QSA6->(Eof())
     oGrdTB2:AddLine()

     oGrdTB2:SetValue("T2_CODBCO" , QSA6->A6_COD)
     oGrdTB2:SetValue("T2_NOMBCO" , QSA6->A6_NOME)
     oGrdTB2:SetValue("T2_AGENCIA", QSA6->A6_AGENCIA)
     oGrdTB2:SetValue("T2_DVAGE"  , QSA6->A6_DVAGE)
     oGrdTB2:SetValue("T2_NUMCON" , QSA6->A6_NUMCON)
     oGrdTB2:SetValue("T2_DVCTA"  , QSA6->A6_DVCTA)
     oGrdTB2:SetValue("T2_SUBCTA" , QSA6->EE_SUBCTA)

     QSA6->(dbSkip())
  EndDo

  QSA6->(dbCloseArea())

  oGrdTB2:SetNoInsertLine(.T.)
  oGrdTB2:SetNoDeleteLine(.T.)
  oGrdTB2:SetNoUpdateLine(.T.)
  oGrdTB2:GoLine(1)
  oView:Refresh()
Return
