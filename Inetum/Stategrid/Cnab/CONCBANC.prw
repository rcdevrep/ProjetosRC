#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  CONCBANC   ºAutor  ³Jader Berto         º Data ³  16/09/24   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Importador de Conciliação Bancária                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CONCBANC()
Local aArea   := GetArea()
Local cLegCin := ""
Local cLegVerd:= ""
Local cLegAma := ""
Local cLegVer := ""
Private oBrwDown, oBrowseUP
Private oRelacZX6
Private cCadastro := "Importação de Conciliação Bancária"
Private cAlias  := "ZX6"
Private aRotina := {{"Pesquisar" ,'PesqBrw' ,0,1}, {"Visualizar" ,'AxVisual' ,0,2}}   

Private aCoors := FWGetDialogSize( oMainWnd ) 

Private oPanelUp, oFWLayer, oPanelLeft
Private oDlgPrinc 

Define MsDialog oDlgPrinc Title 'Conciliação de Arquivos CNAB' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel 

// Cria o conteiner onde serão colocados os browses  
oFWLayer := FWLayer():New() 
oFWLayer:Init( oDlgPrinc, .F., .T. ) 
 
// Define Painel Superior 
oFWLayer:AddLine( 'UP', 30, .F. ) // Cria uma "linha" com 50% da tela
oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' ) // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' ) // Pego o objeto desse pedaço do container 
 
// Painel Inferior  
oFWLayer:AddLine( 'DOWN', 70, .F. ) 
oFWLayer:AddCollumn( 'LEFT' , 100, .T., 'DOWN' ) 
oPanelLeft := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' ) // Pego o objeto do pedaço esquerdo 
 


    cLegCin := "ZX6->ZX6_STATUS == '0' .OR. Empty(ZX6->ZX6_STATUS)"
    cLegVerd:= "ZX6->ZX6_MVEXEC #  'X' .AND. ZX6->ZX6_MVEXE2 #  'X'"
    cLegVer := "ZX6->ZX6_MVEXEC ==  'X' .AND. (ZX6->ZX6_MVEXE2 ==  'X' .OR. ZX6->ZX6_MVEXE2=='0' .OR. Empty(ZX6->ZX6_MVEXE2))"
    cLegAma := "ZX6->ZX6_MVEXEC # ZX6->ZX6_MVEXE2 .AND. !Empty(ZX6->ZX6_MVEXE2) .AND. (ZX6->ZX6_MVEXEC == 'X' .OR. ZX6->ZX6_MVEXE2 == 'X')"

    DbSelectArea(cAlias)

    /*
    cZX6Alias     := GetNextAlias()
    ChkFile("ZX6")
    dbChangeAlias("ZX6", cZX6Alias)
    ChkFile("ZX6")
    (cZX6Alias)->( dbGoTop() )
    */
    // Grid UP
    oBrowseUP := FWmBrowse():New()
    oBrowseUp:SetDescription("Arquivos")
    oBrowseUp:SetOwner( oPanelUp ) 
    oBrowseUp:SetAlias('ZX3')
	oBrowseUp:SetFilterDefault("ZX3_FILIAL = '"+xFilial("ZX3")+"'")     
    oBrowseUp:SetProfileID('1')   
    oBrowseUp:ForceQuitButton()
    oBrowseUp:SetIgnoreARotina( .T. )
    oBrowseUp:AddButton("Importar" ,{|| MsAguarde({|| fImp() },'Importando Extrato...'),oBrowseUp:GoBottom(),oBrwDown:Gotop()  },,2,,.F.)
    oBrowseUp:AddButton("Conf.Cnab",{||  fArqCnab()  },,2,,.F.)
    oBrowseUp:AddButton("Regras"   ,{||  U_REGRCONC()  },,2,,.F.)
    oBrowseUp:AddButton("APAGA TUDO"   ,{||  U_APAGA()  },,2,,.F.)
    //oBrowseUp:AddButton("UPD FILIAL"   ,{||  U_UPDFIL()  },,2,,.F.)
    
    oBrowseUp:DisableDetails()
    oBrowseUp:Activate()



	aAdd(aRotina, {'Pesquisar' 		, 'PesqBrw'	, 0, 1, 0, Nil})
	aAdd(aRotina, {'Visualizar'		, 'AxVisual', 0, 2, 0, Nil})
//	aAdd(aRotina, {'Incluir'   		, 'AxInclui', 0, 3, 0, Nil})
	aAdd(aRotina, {'Alterar'   		, 'AxAltera', 0, 4, 0, Nil})
	aAdd(aRotina, {'Excluir'   		, 'AxDeleta', 0, 5, 0, Nil})

    // Grid Down
    //Instânciando FWMBrowse, setando a tabela, a descrição
    oBrwDown := FWMBrowse():New()
    oBrwDown:SetAlias('ZX6')
    oBrwDown:SetOwner( oPanelLeft ) 
    oBrwDown:SetDescription("Linhas do Arquivo")
     
    //Adicionando legendas (alguns exemplos - PINK, WHITE, GRAY, YELLOW, ORANGE, BLACK, BLUE)
    oBrwDown:AddLegend( cLegCin                              , "GRAY"  ,  "Não Processado" )
    oBrwDown:AddLegend( cLegVerd                             , "GREEN" ,  "Sucesso em todos os Movimentos" )
    oBrwDown:AddLegend( cLegAma                              , "YELLOW",  "Sucesso em um dos Movimentos" )
    oBrwDown:AddLegend( cLegVer                              , "RED"   ,  "Falha em todos os Movimentos" )
    //oBrwDown:AddButton("Visualizar",{||  AxVisual('ZX6', ZX6->(Recno()))  },,2,,.F.)
    oBrwDown:AddButton("Legenda",{||  U_CONCLEG()  },,2,,.F.)
    oBrwDown:SetUseFilter(.F.)
    oBrwDown:SetDBFFilter(.F.)
    oBrwDown:SetMenuDef('') 
    oBrwDown:SetProfileID( '2' ) 
    oBrwDown:ForceQuitButton()  
    oBrwDown:DisableDetails() 
    oBrwDown:Activate()


    // RELACIONA GRIDS Up e Down
    oRelacZX6:= FWBrwRelation():New()   // Relacionamento entre os Paineis
    oRelacZX6:AddRelation( oBrowseUp , oBrwDown , { ;
        { 'ZX6_FILIAL', 'ZX3_FILIAL' },;
        { 'ZX6_ARQUIV', 'ZX3_ARQUIV' };
    } )
    oRelacZX6:Activate()

    Activate MsDialog oDlgPrinc Centered 
     
    RestArea(aArea)

Return




//Remover função após validação
User Function APAGA()

    cQuery := "DELETE FROM "+RETSQLNAME("ZX3")
    If TCSQLExec(cQuery) < 0
        FWAlertError("Erro ao excluir a ZX3", "Erro" )
    Else
        cQuery := "DELETE FROM "+RETSQLNAME("ZX6")
        If TCSQLExec(cQuery) < 0
            FWAlertError("Erro ao excluir a ZX6", "Erro" )
        Else
            FWAlertSuccess("ZX3 e ZX6 excluídas com sucesso.", "Sucesso" )
        EndIf
    EndIf

    oBrowseUp:Refresh(.T.)
    oBrwDown:Refresh(.T.)

Return


User Function UPDFIL()
Local xFil := ""
Local cAllBank := GetMv("MV_XBANCO")


    DbSelectArea("SA6")
    SA6->(DbSetOrder(1))
    SA6->(DbgoTop())
    
    While SA6->(!EOF())
        xFil := ""
        If SA6->A6_BLOCKED <> '1' .AND. SA6->A6_COD $ cAllBank

            cQuery := "SELECT TOP 1 E5_FILIAL FROM SE5010 WHERE E5_BANCO = '"+SA6->A6_COD+"' AND E5_AGENCIA = '"+SA6->A6_AGENCIA+"' AND E5_CONTA = '"+SA6->A6_NUMCON+"'"

            DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP2",.T.,.T.)

            dbSelectArea("TMP2")
            TMP2->(dbGoTop())
            
            iF !TMP2->(Eof())
                xFil := TMP2->E5_FILIAL
            EndiF

            TMP2->(DbCloseArea())
           
        EndIf


        Reclock("SA6", .F.)
            SA6->A6_FILPROC := xFil
        SA6->(MsUnlock())

    SA6->(DbSkip())
    End

Return

Static Function fImp()
Local aParamBox := {}   
Private cArqCort:= "" 
Private cArquivo:= ""   
Private cBank
Private cTpArq



    aAdd( aParamBox,{1,"Banco"              ,Space(3)  ,""                   ,"",""     ,"",0,.T.}) 
    aAdd( aParamBox,{1,"Tipo de Layout"    ,Space(2)  ,""                   ,"","Z9SX5"          ,"",0,.T.}) 
    aAdd( aParamBox,{6,"Aponte o arquivo:"  ,Space(100),"","","",70,.F.,"Todos os arquivos (*.*) |*.*"})

    DbSelectArea("ZZV")
    ZZV->(DbSetOrder(1))


    //Se a pergunta for confirmada
    If ParamBox( aParamBox, "Parâmetros para Consulta")

 
        cBank   := MV_PAR01
        cTpArq  := MV_PAR02

        If !ZZV->(DbSeek(xFilial("ZZV") + cBank + cTpArq))
            MsgStop("Layout não cadastrado para o banco "+cBank+". Utilize a funcionalidade Conf.Cnab e cadastre o layout do banco!!!","Erro")
            return
        EndIf

        if !File(MV_PAR03)
            MsgStop("Arquivo inválido!!!","Erro")
            return
        Else
            cArquivo := MV_PAR03
            cArqCort := Alltrim(SubStr(cArquivo, RAt("\", cArquivo)+1,len(cArquivo)))
            cArqCort := SubStr(cArqCort, 1, TamSx3("ZX6_ARQUIV")[1])
        Endif


        oProcess := MsNewProcess():New( { || U_fCONCIMP() } , "Importação de registros " , "Aguarde..." , .F. )
        oProcess:Activate()
    EndIf
        
Return

User Function CONCLEG()
Local cCadastro:= "Legenda"
LOCAL aCores := {{ 'BR_CINZA'   , 'Não Processado'     },;
                 { 'BR_VERDE'   , 'Sucesso em todos os Movimentos'},;
                 { 'BR_AMARELO' , 'Sucesso em um dos Movimentos'  },;
                 { 'BR_VERMELHO', 'Falha em todos os Movimentos'  }}

	BrwLegenda(cCadastro,"Legenda",aCores)

Return()


User Function fConcJob()
Local cAllBank := ""
Local aAllBank := {}
Local nAllBank := 0



    RPCSetType(3)
    RpcSetEnv("01", "0101" , , , , GetEnvServer() , {} )

    cAllBank := GetMv("MV_XBANCO") //001,033,104,208,237,341,422,745

    aAllBank := separa(cAllBank, ",")

    For nAllBank := 1 to len(aAllBank)
        fcProc(aAllBank[nAllBank])
    Next nAllBank

Return


Static Function fcProc(cBancJob)
Local aDirect := DIRECTORY("\Finnet\Arquivos\Extrato\Proc\*.*", "D")
Local cPath   := "\Finnet\Arquivos\Extrato\Proc"
Local aFiles  
Local nFile, nDir
Local dxData    := SuperGetMV("MV_XDTFILE",.T.,Date())
Private cArqCort:= "" 
Private cArquivo:= "" 
Private cBank   := cBancJob
Private cTpArq  := "03"

    For nDir := 1 to Len(aDirect)
        If aDirect[nDir][1] # "." .AND. aDirect[nDir][1] # ".."
            aFiles  := Directory(cPath+"\"+aDirect[nDir][1]+"\*.*")
            nFile   := 1
            For nFile := 1 to Len(aFiles)
                //Se o arquivo foi criado no dia corrente, processa
                If aFiles[nFile][3] == dxData
                    cArquivo := cPath+"\"+aDirect[nDir][1]+"\"+aFiles[nFile][1]
                    cArqCort := SubStr(aFiles[nFile][1], 1, TamSx3("ZX6_ARQUIV")[1])
                    U_fCONCIMP()

                EndIf
            Next nFile
        EndIf
    Next nDir

Return

User Function fCONCIMP()

Local cLinha
Local cBanco

Local oJsonCnab
Local oJsonIt
Local nTotCampo
Local nItCampo
Local nValini
Local nValFim
Local cTpCampo
Local cData
Local cValor
Local nImp := 0
Local aRegras := {}
Local nRegra
Local cMovExec
Local cRet      := ""
Local aLogAuto := {}
Local nAuto
Local aBaixa    := {}
Local aLinha    := {}
Local cTextBanc := ""
Local cTextAgen := ""
Local cTextDVA  := ""
Local cTextCont := ""
Local cTextDVC  := ""
Local nRecE1E2  := 0
Local nJuros
Local nMulta
Local nValRec
Local cLinArq   := "0001"
Local lExist    := .F.
Local cStatus   := "0"
Local aMov      := {}
Local nMov      
Local cNomProc  := ""
Local lSucesso  := .F.
Local lAuto     := isBlind()
Local aMovReg   := {}
Local cFilReg
Local cFilBkp
Local cFilSA6
Local lDisarm   := .F.

//Operação a ser realizada (3 = Baixa, 5 = cancelamento, 6 = Exclusão)
Default nOpc := 3

//Valor a ser baixado
Default nVlrPag := 0

//Sequência de baixa a ser cancelada.
Default nSeqBx := 1

Private lMsErroAuto := .F.
Private lAutoErrNoFile	:= .T.
Private cHistBaixa := ""


    DbSelectArea("SA1")         

    DbSelectArea("ZX2")
    ZX2->(DbSetOrder(1))
    ZX2->(DbGoTop())

    While ZX2->(!EOF())

        aMovReg   := {}
        AADD(aMovReg, ZX2->ZX2_PROCES)
        If !Empty(ZX2->ZX2_PROCE2) .AND. ZX2->ZX2_PROCE2 <> "0"
            AADD(aMovReg, ZX2->ZX2_PROCE2)
        EndIf

        AADD(aRegras, {ZX2->ZX2_ROTINA,;                        //01
                       aMovReg,;                                //02
                       ZX2->ZX2_CODCLI,;                        //03
                       ZX2->ZX2_LOJA,;                          //04
                       ZX2->ZX2_NATUR,;                         //05
                       ZX2->ZX2_BANCO,;                         //06
                       ZX2->ZX2_AGENCI,;                        //07
                       ZX2->ZX2_DVAGEN,;                        //08
                       ZX2->ZX2_CONTA,;                         //09
                       ZX2->ZX2_DVCONT,;                        //10
                       ZX2->ZX2_EXPRES,;                        //11
                       ZX2->ZX2_CDCOND,;                        //12
                       ZX2->ZX2_FILPRC})                        //13
    ZX2->(DbSkip())
    End

    oJsonCnab := JsonObject():New()   
    oJsonCnab["CAMPOS"] := {}

    ZZV->(DbGoTop())
    If ZZV->(DbSeek(xFilial("ZZV") + cBank + cTpArq)) 
        While ZZV->(!EOF()) .AND. ZZV->ZZV_BANCO == cBank .AND. ZZV->ZZV_TIPARQ == cTpArq

            oJsonIt := JsonObject():New()
            oJsonIt["BANCO"]  := ZZV->ZZV_BANCO
            oJsonIt["CAMPO"]  := ZZV->ZZV_CAMPO
            oJsonIt["VALINI"] := ZZV->ZZV_VALINI
            oJsonIt["VALFIM"] := ZZV->ZZV_VALFIM

            AADD(oJsonCnab["CAMPOS"], oJsonIt)
        ZZV->(DbSkip())
        End
    EndIf

    nTotCampo := Len(oJsonCnab["CAMPOS"])

    DbSelectArea("ZX3")
    ZX3->(DbSetOrder(2))
    
    DbSelectArea("ZX6")
    ZX6->(DbSetOrder(1))
    ZX6->(DbGoTop())

    
    DbSelectArea("SA6")
    SA6->(DbSetOrder(1))
    //SA6->(DbSetOrder(3))

    FT_FUSE(cArquivo) //Abre o arquivo texto

    If !lAuto
        oProcess:SetRegua1(FT_FLASTREC()) //Preenche a regua com a quantidade de registros encontrados
    EndIf
    FT_FGOTOP() //coloca o arquivo no topo
    While !FT_FEOF()
        

        lDisarm   := .F.
        cStatus   := "0"
        cRet      := ""
        
        cLinha  := FT_FREADLN()
        If SubString(cLinha, 8,1) == "3"

            lExist := .F.
           
            If !lAuto
                oProcess:IncRegua1('Processando Linha: ' + Alltrim(Str(nImp)))
            EndIf

            //????? REMOVIDA A VALIDAÇÃO DE IMPORTAÇÃO DUPLICADA
            
            //DBseek("ZX6")

          
            
            nItCampo:= 1
            Begin Transaction
             
                Reclock("ZX6", !lExist)
                    ZX6->ZX6_USER   := UsrFullName()
                    If !lExist
                        ZX6->ZX6_STATUS := '0'
                    EndIf
                    For nItCampo := 1 to nTotCampo
                        

                        cBanco     := Alltrim(oJsonCnab["CAMPOS"][nItCampo]:BANCO)
                        cTpCampo   := TamSx3(Alltrim(oJsonCnab["CAMPOS"][nItCampo]:CAMPO))[3] 
                        nValini    := oJsonCnab["CAMPOS"][nItCampo]:VALINI
                        nValFim    := oJsonCnab["CAMPOS"][nItCampo]:VALFIM - nValini + 1
                        
                        If cBanco  # SubString(cLinha,1 , 3)
                            If !lAuto
                                MsgStop("Este arquivo não corresponde ao banco "+cBanco+"!!!","Erro")
                            Else
                                conout("Este arquivo não corresponde ao banco "+cBanco+"!!!")
                            EndIf
                            ZX6->(MsUnlock())
                            DisarmTransaction()
                            return                  
                        EndIf
                        If cTpCampo == "C"
                            &(oJsonCnab["CAMPOS"][nItCampo]:CAMPO) := SubString(cLinha, nValini, nValFim)
                        ElseIf cTpCampo == "D"
                            cData := SubString(cLinha, nValini, nValFim) 
                            &(oJsonCnab["CAMPOS"][nItCampo]:CAMPO) := STOD(Substring(cData,5,4)+Substring(cData,3,2)+Substring(cData,1,2))
                        ElseIf cTpCampo == "N"
                            cValor := SubString(cLinha, nValini, nValFim)
                            cValor := Stuff (cValor, Len(cValor)-1, 0, ".")
                            &(oJsonCnab["CAMPOS"][nItCampo]:CAMPO) := val(cValor)
                        EndIf
                    Next nItCampo
                    ZX6->ZX6_ARQUIV:= cArqCort
                    ZX6->ZX6_NUM   := cLinArq
                    ZX6->ZX6_DTIMP := Date()
                    ZX6->ZX6_HRIMP := Time()
                    cFilSA6 := fBuscFil(ZX6->ZX6_CODBAN, Alltrim(ZX6->ZX6_AGENCI), Alltrim(ZX6->ZX6_CCORRE))
                    ZX6->ZX6_FILIAL := cFilSA6
                ZX6->(MsUnlock())


                If ZX3->(Dbseek(cFilSA6 + ALLTRIM(cArqCort)))
                    DisarmTransaction()
                    lDisarm := .T.
                    FT_FSKIP()
                EndIf
            
                /*
                
                */

                If nImp == 0
                    Reclock("ZX3", .T.)
                        ZX3->ZX3_FILIAL := cFilSA6
                        ZX3->ZX3_ARQUIV:= cArqCort
                        ZX3->ZX3_DTIMP := Date()
                        ZX3->ZX3_HRIMP := Time()
                    ZX3->(MsUnlock())
                EndIf

               

                //Desfaz a transação e retorna para a próxima linha do arquivo, caso o registro já tenha sido importado para a Filial
                
                /*If ZX6->(DbSeek(cFilSA6 + PADR(cArqCort, TamSx3("ZX6_ARQUIV")[1]) + cLinArq))

                    DisarmTransaction()
                    lDisarm := .T.
            
                EndIf     */           

            End Transaction

            If lDisarm
                cLinArq := Soma1(cLinArq)    
                nImp++
                FT_FSKIP()
                Loop
            EndIf
            /*
            
            */
            

            cFilBkp   := cFilAnt


            //Execução das Regras de Movimentos--------------------------------------------------------------------------------------
            nRegra := 1
            For nRegra := 1 To Len(aRegras)


                cMovExec := ""
                lMsErroAuto := .F.
                aFINA100 := {}

                cTextBanc := ZX6->ZX6_CODBAN
                cTextAgen := ZX6->ZX6_AGENCI
                cTextDVA  := ""
                cTextCont := ZX6->ZX6_CCORRE
                cTextDVC  := ""
                
                nJuros    := ZX6->ZX6_JUROS
                nMulta    := ZX6->ZX6_MULTA
                nValRec   := ZX6->ZX6_VLPAGO          
                
                

                If &(aRegras[nRegra][1]) .AND. substr(cFilSA6,1,2) == substr(aRegras[nRegra][13],1,2)

                    aMov := aRegras[nRegra][2]

                    IF(Len(aMov) > 1) 
                        IF((aMov[1] == "3" .AND. aMov[2] == "4") .OR. (aMov[1] == "4" .AND. aMov[2] == "3") )
                            cFilReg := aRegras[nRegra][13]
                            cFilAnt := cFilReg
                            If !VldImp(cTextBanc, cValToChar(val(cTextAgen)), cValToChar(val(cTextCont)) , ZX6->ZX6_BAIXA, ZX6->ZX6_VLPAGO, cFilReg)

                                /*aLinha   := {}
                                AADD(aLinha, {"E5_FILIAL"       ,cFilReg                                                   ,Nil})
                                AADD(aLinha, {"E5_DATA"         ,ZX6->ZX6_BAIXA                                                 ,Nil})
                                AADD(aLinha, {"E5_VALOR"        ,ZX6->ZX6_VLPAGO                                           ,Nil})
                                AADD(aLinha, {"E5_NATUREZ"      ,aRegras[nRegra][5]                                        ,Nil})
                                If nMov == 1
                                    AADD(aLinha, {"E5_BANCO"    ,cTextBanc                                               ,Nil})
                                    AADD(aLinha, {"E5_AGENCIA"  ,cValToChar(val(cTextAgen))                              ,Nil})
                                    AADD(aLinha, {"E5_CONTA"    ,fBuscConta(cTextBanc,cTextAgen,cTextCont)                             ,Nil})
                                Else
                                    AADD(aLinha, {"E5_BANCO"    ,aRegras[nRegra][6]                                        ,Nil})
                                    AADD(aLinha, {"E5_AGENCIA"  ,aRegras[nRegra][7]                              ,Nil})
                                    AADD(aLinha, {"E5_CONTA"    ,aRegras[nRegra][9]                               ,Nil})
                                EndIf
                                AADD(aLinha, {"E5_HISTOR"       ,ZX6->ZX6_DESLAN                                           ,Nil})
                                AADD(aLinha, {"E5_CCC"          ,IF(cFilReg="2901","90505000","40000401")                  ,Nil})
                                AADD(aLinha, {"E5_RECPAG"       ,"P"                                                       ,Nil})
                                AADD(aLinha, {"E5_MOEDA"        ,"M1"                                                      ,Nil})
                                AADD(aLinha, {"E5_DTDIGIT"      ,ZX6->ZX6_BAIXA                                                 ,Nil})
                                AADD(aLinha, {"E5_DTDISPO"      , DataValida(ZX6->ZX6_BAIXA)                                    ,Nil})
                                MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aLinha,3)*/

                                dDataOrig := dDataBase
                                dDataBase := DataValida(ZX6->ZX6_BAIXA)
                                cNumero := GetMV("MV_TRANAUT")
                                cNumero := SOMA1(cNumero)

                                IF(aMov[1] == "3")

                                    aFINA100 := {  {"CBCOORIG"          ,cTextBanc                                 ,Nil},;
                                                    {"CAGENORIG"         ,fBuscAgenc(cTextBanc,cTextAgen,cTextCont) ,Nil},;
                                                    {"CCTAORIG"          ,fBuscConta(cTextBanc,cTextAgen,cTextCont) ,Nil},;
                                                    {"CNATURORI"         ,aRegras[nRegra][5]                     ,Nil},;
                                                    {"CBCODEST"          ,aRegras[nRegra][6]                     ,Nil},;
                                                    {"CAGENDEST"         ,aRegras[nRegra][7]                     ,Nil},;
                                                    {"CCTADEST"          ,aRegras[nRegra][9]                     ,Nil},;
                                                    {"CNATURDES"         ,aRegras[nRegra][5]                     ,Nil},;
                                                    {"CTIPOTRAN"         ,"TB"                      ,Nil},;
                                                    {"CDOCTRAN"          ,cNumero             ,Nil},;
                                                    {"NVALORTRAN"        ,ZX6->ZX6_VLPAGO                      ,Nil},;
                                                    {"CHIST100"          ,"TESTE CNAB"  ,Nil},;
                                                    {"CBENEF100"         ,"TESTE CNAB"  ,Nil},;
                                                    {"NAGLUTINA"         ,2                         ,Nil},; 
                                                    {"NCTBONLINE"        ,1                         ,Nil},;                                                 
                                                    {"DDATACRED"         ,DataValida(ZX6->ZX6_BAIXA)          ,Nil}}

                                ELSE

                                    aFINA100 := {  {"CBCOORIG"           ,aRegras[nRegra][6]                                 ,Nil},;
                                                    {"CAGENORIG"         ,aRegras[nRegra][7]                ,Nil},;
                                                    {"CCTAORIG"          ,aRegras[nRegra][9]  ,Nil},;
                                                    {"CNATURORI"         ,aRegras[nRegra][5]                     ,Nil},;
                                                    {"CBCODEST"          ,cTextBanc                     ,Nil},;
                                                    {"CAGENDEST"         ,fBuscAgenc(cTextBanc,cTextAgen,cTextCont)                     ,Nil},;
                                                    {"CCTADEST"          ,fBuscConta(cTextBanc,cTextAgen,cTextCont)                     ,Nil},;
                                                    {"CNATURDES"         ,aRegras[nRegra][5]                     ,Nil},;
                                                    {"CTIPOTRAN"         ,"TB"                      ,Nil},;
                                                    {"CDOCTRAN"          ,cNumero             ,Nil},;
                                                    {"NVALORTRAN"        ,ZX6->ZX6_VLPAGO                      ,Nil},;
                                                    {"CHIST100"          ,"TESTE CNAB"  ,Nil},;
                                                    {"CBENEF100"         ,"TESTE CNAB"  ,Nil},;
                                                    {"NAGLUTINA"         ,2                         ,Nil},; 
                                                    {"NCTBONLINE"        ,1                         ,Nil},;                                                 
                                                    {"DDATACRED"         ,DataValida(ZX6->ZX6_BAIXA)          ,Nil}}

                                ENDIF
     
                                MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,7)

                                PUTMV("MV_TRANAUT",cNumero)

                                dDataBase := dDataOrig
                                If lMsErroAuto                                    
                                    aLogAuto := GetAutoGRLog()
                                    nAuto := 1
                                    For nAuto := 1 To Len(aLogAuto)
                                        cRet +=  aLogAuto[nAuto] + CRLF
                                    Next nAuto
                                Else
                                    cRet     += "TRANSFERENCIA REALIZADO COM SUCESSO"
                                    lSucesso  := .T.

                                EndIf

                            Else
                                cRet +=  "Movimento já realizado pela rotina padrão."
                            EndIf

                            If !lSucesso
                                cMovExec := "X"
                            EndIf


                            Reclock("ZX6", .F.)
                            
                            IF("SUCESSO" $ cRet)
                                cStatus := "1"
                            ENDIF
                            
                            ZX6->ZX6_RESULT := cRet
                            ZX6->ZX6_STATUS := cStatus
                            ZX6->ZX6_FILPRC := cFilReg
                            ZX6->ZX6_USER   := UsrFullName()
                            ZX6->(MsUnlock())




                        ENDIF
                    ELSE

                        For nMov := 1 to Len(aMov)

                            /*
                            If nMov := 1
                                cFilReg := ZX6->ZX6_FILIAL 
                            Else
                                cFilReg := aRegras[nRegra][13]
                            Endif
                            */

                            cFilReg := aRegras[nRegra][13]
                            cFilAnt := cFilReg

                            
                            If nMov == 1 .AND. ZX6->ZX6_STATUS # "1" .AND. (ZX6->ZX6_MVEXEC == "X" .OR. Empty(ZX6->ZX6_MVEXEC)) .OR.;
                            nMov == 2 .AND. (ZX6->ZX6_MVEXE2 == "X" .OR. Empty(ZX6->ZX6_MVEXE2))

                                lSucesso  := .F.
                                cNomProc  := ""

                                If aMov[nMov] # "0"

                                    If aMov[nMov] == "1"
                                        cNomProc := "Baixa a Pagar"
                                    ElseIf aMov[nMov] == "2"
                                        cNomProc := "Baixa a Receber"
                                    ElseIf aMov[nMov] == "3"
                                        cNomProc := "Mov.Ban.Deb"
                                    ElseIf aMov[nMov] == "4"
                                        cNomProc := "Mov.Ban.Cred"
                                    EndIf

                                    nRecE1E2 := fSearch(aMov[nMov], ZX6->ZX6_FILIAL, PADR(aRegras[nRegra][3], TamSx3("A2_COD")[1]), PADR(aRegras[nRegra][4], TamSx3("A2_LOJA")[1]))
                                    
                                    //If !Empty(aRegras[nRegra][6])
                                        //cTextBanc := aRegras[nRegra][6]
                                    //EndIf
                                    If !Empty(aRegras[nRegra][7])
                                        cTextAgen := aRegras[nRegra][7]
                                    EndIf
                                    If !Empty(aRegras[nRegra][8])
                                        cTextDVA := aRegras[nRegra][8]
                                    EndIf
                                    If !Empty(aRegras[nRegra][9])
                                        cTextCont := aRegras[nRegra][9]
                                    EndIf
                                    If !Empty(aRegras[nRegra][10])
                                        cTextDVC := aRegras[nRegra][10]
                                    EndIf
                                    
                                    If !Empty(cRet)
                                        cRet += CRLF+Replicate("-",140)+CRLF+CRLF
                                    EndIf

                                    cRet += "[Linha "+cLinArq+" | Processo: "+cNomProc+" | Regra aplicada: "+Alltrim(aRegras[nRegra][12])+" - "+Alltrim(aRegras[nRegra][11])+"]"+CRLF

                                    //Baixa a Pagar
                                    If aMov[nMov] == "1"

                                        If nRecE1E2 > 0

                                            cMovExec := aMov[nMov]

                                            cHistBaixa := "Teste Baixa fina080"

                                            DbSelectArea("SE2")
                                            SE2->(dbSetOrder(1))
                                            
                                            SE2->(DbGo(nRecE1E2))

                                            aBaixa := {}        
                                            
                                            Aadd(aBaixa, {"E2_FILIAL", SE2->E2_FILIAL,  nil})
                                            Aadd(aBaixa, {"E2_PREFIXO", SE2->E2_PREFIXO,  nil})
                                            Aadd(aBaixa, {"E2_NUM", SE2->E2_NUM,      nil})
                                            Aadd(aBaixa, {"E2_PARCELA", SE2->E2_PARCELA,  nil})
                                            Aadd(aBaixa, {"E2_TIPO", SE2->E2_TIPO,     nil})
                                            Aadd(aBaixa, {"E2_FORNECE", SE2->E2_FORNECE,  nil})
                                            Aadd(aBaixa, {"E2_LOJA", SE2->E2_LOJA ,    nil})
                                            Aadd(aBaixa, {"AUTMOTBX", "NOR",            nil})
                                            Aadd(aBaixa, {"AUTBANCO", "001",            nil})
                                            Aadd(aBaixa, {"AUTAGENCIA", "AG001",          nil})
                                            Aadd(aBaixa, {"AUTCONTA", "CTA001 ",     nil})
                                            Aadd(aBaixa, {"AUTDTBAIXA", ZX6->ZX6_BAIXA   ,        nil})
                                            Aadd(aBaixa, {"AUTDTCREDITO", ZX6->ZX6_BAIXA   ,        nil})
                                            Aadd(aBaixa, {"AUTHIST", cHistBaixa,       nil})
                                            Aadd(aBaixa, {"AUTVLRPG", nVlrPag,          nil})

                                            //Pergunte da rotina
                                            AcessaPerg("FINA080", .F.)                  
                                            
                                            //Chama a execauto da rotina de baixa manual (FINA080)
                                            MsExecauto({|x,y,z,v| FINA080(x,y,z,v)}, aBaixa, nOpc, .F., nSeqBx)
                                            
                                            If lMsErroAuto
                                                
                                                aLogAuto := GetAutoGRLog()
                                                
                                                nAuto := 1
                                                For nAuto := 1 To Len(aLogAuto)
                                                    cRet +=  aLogAuto[nAuto] + CRLF
                                                Next nAuto


                                            Else
                                                cRet      += "Baixa efetuada com sucesso"
                                                lSucesso  := .T.

                                            EndIf

                                        Else
                                            cRet     += "Foram encontrados mais de 1 ou nenhum título para baixa."

                                        EndIf


                                    //Baixa a Receber
                                    ElseIf aMov[nMov] == "2"            //Baixa a Receber - FINA070
                                        cMovExec := aMov[nMov]

                                        If nRecE1E2 > 0

                                            cHistBaixa := "Teste Baixa fina080"

                                            aBaixa := {} 

                                            SE1->(DbGoto(nRecE1E2))


                                            RECLOCK("SE1",.F.)
                                            SE1->E1_PORTADO := cTextBanc
                                            SE1->E1_AGEDEP  := fBuscAgenc(cTextBanc,cTextAgen,cTextCont)//cTextAgen
                                            SE1->E1_CONTA   := fBuscConta(cTextBanc,cTextAgen,cTextCont)//cValToChar(val(cTextCont))
                                            MSUNLOCK()

                                            Aadd(aBaixa, {"E1_FILIAL"  , SE1->E1_FILIAL           , nil})
                                            Aadd(aBaixa, {"E1_PREFIXO" , SE1->E1_PREFIXO           , nil})
                                            Aadd(aBaixa, {"E1_NUM"     , SE1->E1_NUM               , nil})
                                            Aadd(aBaixa, {"E1_PARCELA" , SE1->E1_PARCELA           , nil})
                                            Aadd(aBaixa, {"E1_TIPO"    , SE1->E1_TIPO              , nil})
                                            //Aadd(aBaixa, {"E1_DTDISPO"    , ZX6->ZX6_BAIXA         , nil})

                                            //dDataBase := ZX6->ZX6_BAIXA


                                            //Consultar cliente
                                            If !Empty(aRegras[nRegra][3])
                                                    
                                                SA1->(DbSetOrder(1))   
                                                If SA1->(DBSeek(xFilial("SA1")+PADR(aRegras[nRegra][3], TamSx3("A2_COD")[1])+PADR(aRegras[nRegra][4], TamSx3("A2_LOJA")[1])))
                                                
                                                    Aadd(aBaixa, {"E1_CLIENTE"      , SA1->A1_COD           , nil})
                                                    Aadd(aBaixa, {"E1_LOJA"         , SA1->A1_LOJA          , nil})
                                                EndIf
                                            EndIf

                                            Aadd(aBaixa, {"AUTJUROS"    , nJuros                         , nil})
                                            Aadd(aBaixa, {"AUTMULTA"    , nMulta                         , nil})
                                            Aadd(aBaixa, {"AUTVALREC"   , nValRec                        , nil})     
                                            Aadd(aBaixa, {"AUTMOTBX"    , "NOR"                          , nil})
                                            Aadd(aBaixa, {"AUTDTBAIXA"  , ZX6->ZX6_BAIXA                 , nil})
                                            Aadd(aBaixa, {"AUTDTCREDITO"  , ZX6->ZX6_BAIXA                 , nil})
                                            Aadd(aBaixa, {"AUTHIST"     , cHistBaixa                     , nil})     


                                            
                                            MSExecAuto({|a,b| FINA070(a,b)},aBaixa,3) //3-Inclusao
                                            
                                            If lMsErroAuto
                                                
                                                aLogAuto := GetAutoGRLog()

                                                nAuto := 1
                                                For nAuto := 1 To Len(aLogAuto)
                                                    cRet +=  aLogAuto[nAuto] + CRLF
                                                Next nAuto

                                            Else
                                                cRet      += "BAIXA REALIZADA COM SUCESSO"+CRLF+"Título: "+SE1->E1_NUM+CRLF+"Prefixo: "+SE1->E1_PREFIXO+CRLF+"Cliente: "+SA1->A1_COD+"/"+SA1->A1_LOJA
                                                lSucesso  := .T.

                                            EndIf
                                        Else
                                            cRet     += "Foram encontrados mais de 1 ou nenhum título para baixa."

                                        EndIf

                                    //Mov.Ban.Deb
                                    ElseIf aMov[nMov] == "3"            //Mov.Ban.Deb - FINA100
                                        cMovExec := aMov[nMov]

                                        If !VldImp(cTextBanc, cValToChar(val(cTextAgen)), cValToChar(val(cTextCont)) , ZX6->ZX6_BAIXA, ZX6->ZX6_VLPAGO, cFilReg)
                                                                    
                                            aLinha   := {}

                                            //ZX6->ZX6_CODBAN, Alltrim(ZX6->ZX6_AGENCI), Alltrim(ZX6->ZX6_CCORRE)
                                            
                                            AADD(aLinha, {"E5_FILIAL"       ,cFilReg                                                   ,Nil})
                                            AADD(aLinha, {"E5_DATA"         ,ZX6->ZX6_BAIXA                                                 ,Nil})
                                            AADD(aLinha, {"E5_VALOR"        ,ZX6->ZX6_VLPAGO                                           ,Nil})
                                            AADD(aLinha, {"E5_NATUREZ"      ,aRegras[nRegra][5]                                        ,Nil})
                                            If nMov == 1
                                                AADD(aLinha, {"E5_BANCO"    ,cTextBanc                                               ,Nil})
                                                AADD(aLinha, {"E5_AGENCIA"  ,fBuscAgenc(cTextBanc,cTextAgen,cTextCont)                              ,Nil})
                                                AADD(aLinha, {"E5_CONTA"    ,fBuscConta(cTextBanc,cTextAgen,cTextCont)                             ,Nil})
                                            Else
                                                AADD(aLinha, {"E5_BANCO"    ,aRegras[nRegra][6]                                        ,Nil})
                                                AADD(aLinha, {"E5_AGENCIA"  ,aRegras[nRegra][7]                              ,Nil})
                                                AADD(aLinha, {"E5_CONTA"    ,aRegras[nRegra][9]                               ,Nil})
                                            EndIf
                                            AADD(aLinha, {"E5_HISTOR"       ,ZX6->ZX6_DESLAN                                           ,Nil})
                                            AADD(aLinha, {"E5_CCC"          ,IF(cFilReg="2901","90505000","40000401")                  ,Nil})
                                            AADD(aLinha, {"E5_RECPAG"       ,"P"                                                       ,Nil})
                                            AADD(aLinha, {"E5_MOEDA"        ,"M1"                                                      ,Nil})
                                            AADD(aLinha, {"E5_DTDIGIT"      ,ZX6->ZX6_BAIXA                                                 ,Nil})
                                            AADD(aLinha, {"E5_DTDISPO"      , DataValida(ZX6->ZX6_BAIXA)                                    ,Nil})

                                            MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aLinha,3)
                                            
                                            If lMsErroAuto
                                                
                                                aLogAuto := GetAutoGRLog()

                                                nAuto := 1
                                                For nAuto := 1 To Len(aLogAuto)
                                                    cRet +=  aLogAuto[nAuto] + CRLF
                                                Next nAuto


                                            Else
                                                cRet     += "MOVIMENTO REALIZADO COM SUCESSO"
                                                lSucesso  := .T.

                                            EndIf

                                        Else
                                            cRet +=  "Movimento já realizado pela rotina padrão."
                                        EndIf
                                        
                                    //Mov.Ban.Cred
                                    ElseIf aMov[nMov] == "4"            //Mov.Ban.Cred -  FINA100
                                        cMovExec := aMov[nMov]

                                        If !VldImp(cTextBanc, cValToChar(val(cTextAgen)), cValToChar(val(cTextCont)) , ZX6->ZX6_BAIXA, ZX6->ZX6_VLPAGO, cFilReg )
                                                
                                                aLinha   := {}

                                                AADD(aLinha, {"E5_FILIAL"   ,cFilReg                                                 ,Nil})
                                                AADD(aLinha, {"E5_DATA"     ,ZX6->ZX6_BAIXA                                               ,Nil})
                                                AADD(aLinha, {"E5_VALOR"    ,ZX6->ZX6_VLPAGO                                         ,Nil})
                                                AADD(aLinha, {"E5_NATUREZ"  ,aRegras[nRegra][5]                                      ,Nil})
                                                If nMov == 1
                                                    AADD(aLinha, {"E5_BANCO"    ,cTextBanc                                               ,Nil})
                                                    AADD(aLinha, {"E5_AGENCIA"  ,fBuscAgenc(cTextBanc,cTextAgen,cTextCont)                              ,Nil})
                                                    AADD(aLinha, {"E5_CONTA"    ,fBuscConta(cTextBanc,cTextAgen,cTextCont)                              ,Nil})
                                                Else
                                                    AADD(aLinha, {"E5_BANCO"    ,aRegras[nRegra][6]                                               ,Nil})
                                                    AADD(aLinha, {"E5_AGENCIA"  ,aRegras[nRegra][7]                               ,Nil})
                                                    AADD(aLinha, {"E5_CONTA"    ,aRegras[nRegra][9]                              ,Nil})
                                                EndIf
                                                AADD(aLinha, {"E5_HISTOR"   ,ZX6->ZX6_DESLAN                                         ,Nil})
                                                AADD(aLinha, {"E5_CCC"      ,IF(cFilReg="2901","90505000","40000401")                ,Nil})
                                                AADD(aLinha, {"E5_RECPAG"   ,"R"                                                     ,Nil})
                                                AADD(aLinha, {"E5_MOEDA"    ,"M1"                                                    ,Nil})
                                                AADD(aLinha, {"E5_DTDIGIT"  ,ZX6->ZX6_BAIXA                                               ,Nil})
                                                AADD(aLinha, {"E5_DTDISPO"  , DataValida(ZX6->ZX6_BAIXA)                                  ,Nil})


                                                //AADD(aFINA100, aLinha)



                                                MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aLinha,4)

                                                If lMsErroAuto
                                                    //MostraErro()
                                                    
                                                    aLogAuto := GetAutoGRLog()

                                                    nAuto := 1
                                                    For nAuto := 1 To Len(aLogAuto)
                                                        cRet +=  aLogAuto[nAuto] + CRLF
                                                    Next nAuto

                                                    

                                                Else
                                                    cRet      += "MOVIMENTO REALIZADO COM SUCESSO"
                                                    lSucesso  := .T.

                                                EndIf                                      

                                        Else
                                            cRet +=  "Movimento já realizado pela rotina padrão."
                                        EndIf
                            
                                    
                                    EndIf

                                    If !lSucesso
                                        cMovExec := "X"
                                    EndIf


                                    Reclock("ZX6", .F.)
                                        If nMov == 1
                                            ZX6->ZX6_MVEXEC := cMovExec
                                        Else
                                            ZX6->ZX6_MVEXE2 := cMovExec
                                        EndIf
                                    
                                        If ZX6->ZX6_MVEXEC # "X" .AND. ZX6->ZX6_MVEXE2 # "X"
                                            cStatus := "1"
                                        ElseIf ZX6->ZX6_MVEXEC == "X" .AND. (ZX6->ZX6_MVEXE2 == "X" .OR. Empty(ZX6->ZX6_MVEXE2) .OR. ZX6_MVEXE2 == "0")
                                            cStatus := "3"
                                        ElseIf ZX6->ZX6_MVEXEC # ZX6->ZX6_MVEXE2 .AND. !Empty(ZX6->ZX6_MVEXE2) .AND. ZX6->ZX6_MVEXE2 # "0"
                                            cStatus := "2"
                                        EndIf
                                        //FAZER UM CONTEM A EXPRESSÃO NO CRET PARA RECUPERAR SE O TITULO JÁ FOI BAIXADO.

                                        IF("Baixado" $ cRet)
                                            cStatus := "1"
                                        ENDIF
                                        
                                        ZX6->ZX6_RESULT := cRet
                                        ZX6->ZX6_STATUS := cStatus
                                        ZX6->ZX6_FILPRC := cFilReg
                                        ZX6->ZX6_USER   := UsrFullName()
                                    ZX6->(MsUnlock())


                                EndIf
                            EndIf
                        Next nMov
                    ENDIF

                        cFilAnt := cFilBkp

                    EndIf

                Next nRegra
            //-----------------------------------------------------------------------------------------------------------------------            
            
            cLinArq := Soma1(cLinArq)

            nImp++
        EndIf



    
        FT_FSKIP()
    EndDo

    If lAuto
        If !Empty(cBanco)
            U_RELCONC()
        EndIf
    EndIf



    If !lAuto
        MsgInfo(cValToChar(nImp) + " linhas processadas", "Finalizado")

        oBrowseUp:Refresh(.T.)
        oBrwDown:Refresh(.T.)
    EndIf


Return


// 
Static Function fArqCnab()
Local aArea   := GetArea()
Local cTabela     := "ZZV"
Private cCadastro := "Configurações CNAB para Importação"
Private aRotina   := {}

    //Montando o Array aRotina, com funções que serão mostradas no menu
    aAdd(aRotina,{"Pesquisar",  "AxPesqui", 0, 1})
    aAdd(aRotina,{"Visualizar", "AxVisual", 0, 2})
    aAdd(aRotina,{"Incluir",    "AxInclui", 0, 3})
    aAdd(aRotina,{"Alterar",    "AxAltera", 0, 4})
    aAdd(aRotina,{"Excluir",    "AxDeleta", 0, 5})
    AADD(aRotina, { "Tipos de Layouts","U_fLayout()"   , 0, 3 })
 
    //Selecionando a tabela e ordenando
    DbSelectArea(cTabela)
    (cTabela)->(DbSetOrder(1))
     
    //Montando o Browse
    mBrowse(6, 1, 22, 75, cTabela)
     
    //Encerrando a rotina
    (cTabela)->(DbCloseArea())
    RestArea(aArea)

Return



Static Function fSearch(nTpMov, cXFilial, cCliFor, cLoja)
Local nRec   := 0
Local cQuery := ""
Local cAlias 
Local nTot   := 0

    If nTpMov == "1"


    ElseIf nTpMov == "2"

        cAlias := GetNextAlias()

        cQuery += "SELECT R_E_C_N_O_ REC FROM "+RetSqlName("SE1")+" "+CRLF
        cQuery += "WHERE D_E_L_E_T_ <> '*' "+CRLF
        cQuery += "AND E1_BAIXA = ' ' "+CRLF
        //
        IF(!EMPTY(ZX6->ZX6_CDTVEN))
            cQuery += "AND E1_VENCTO >= '"+DTOS(ZX6->ZX6_CDTVEN-5)+"' "+CRLF 
            cQuery += "AND E1_VENCTO <= '"+DTOS(ZX6->ZX6_CDTVEN+5)+"' "+CRLF
        ELse
            cQuery += "AND E1_VENCTO >= '"+DTOS(ZX6->ZX6_BAIXA-5)+"' "+CRLF 
            cQuery += "AND E1_VENCTO <= '"+DTOS(ZX6->ZX6_BAIXA+5)+"' "+CRLF
        ENDIF
        cQuery += "AND E1_VALOR = "+cValtoChar(ZX6->ZX6_VLPAGO)
        cQuery += "AND SUBSTRING(E1_FILIAL,1,2) = '"+ALLTRIM(cXFilial)+"' "+CRLF
        cQuery += "AND E1_CLIENTE = '"+cCliFor+"' "+CRLF
        cQuery += "AND E1_LOJA = '"+cLoja+"' "+CRLF


        TCQuery cQuery NEW ALIAS (cAlias)

        While !(cAlias)->(Eof())

            nTot++
            if nTot == 1
                nRec := (cAlias)->REC
            EndIf

        (cAlias)->(DbSkip())
        End

        If nTot > 1
            nRec := 0
        EndIf

        (cAlias)->(DbCloseArea())

    EndIf

Return nRec


Static Function VldImp(cBanco, cAgencia, cConta, dDtImp, nValor, cXFilial)
Local cQuery := ""
Local cAlias
Local lRet   := .F. 

        cBanco   := PADR(cBanco, TamSx3("IG_BCOEXT")[1])
        cAgencia := PADR(cAgencia, TamSx3("IG_AGEEXT")[1])
        cConta   := PADR(cConta, TamSx3("IG_CONEXT")[1])


        cAlias := GetNextAlias()

        cQuery += "SELECT R_E_C_N_O_ REC FROM "+RetSqlName("SIG")+" "+CRLF
        cQuery += "WHERE D_E_L_E_T_ <> '*' "+CRLF
        cQuery += "AND IG_FILIAL = '"+cXFilial+"' "+CRLF
        cQuery += "AND IG_BCOEXT = '"+cBanco+"' "+CRLF
        cQuery += "AND IG_AGEEXT =  '"+cAgencia+"' "+CRLF
        cQuery += "AND IG_CONEXT = '"+cConta+"' "+CRLF
        cQuery += "AND IG_VLREXT = "+cValToChar(nValor)+ " "+CRLF
        cQuery += "AND IG_DTEXTR = '"+DTOS(dDtImp)+"' "+CRLF


        TCQuery cQuery NEW ALIAS (cAlias)

        If !(cAlias)->(Eof())

            //Já existe movimento
            lRet := .T.

        Endif

        (cAlias)->(DbCloseArea())

Return lRet



Static Function fBuscFil(xBanco, xAgencia, xConta)
Local xFil          := xFilial("ZX3")
Local cQuery		:= ""
Local cAlias		:= GetNextAlias()

    cQuery := "SELECT  TOP 1 A6_FILIAL, CASE WHEN (CAST(A6_AGENCIA AS INT) = '"+cValtoChar(val(xAgencia))+"' AND TRIM(A6_NUMCON) like '%"+cValtoChar(val(xConta))+"') THEN 1 ELSE 2 END PRIOR  "
	cQuery += "FROM "+RETSQLNAME("SA6")+" (NOLOCK) WHERE "
	cQuery += "D_E_L_E_T_ = '' AND A6_COD = '"+xBanco+"' AND "
    cQuery += "A6_BLOCKED <> '1' AND "
    //cQuery += "A6_FILPROC <> '' AND "
	cQuery += " ((CAST(A6_AGENCIA AS INT) = '"+cValtoChar(val(xAgencia))+"' AND TRIM(A6_NUMCON) like '%"+cValtoChar(val(xConta))+"') OR "
    
    cQuery += " (CAST(A6_AGENCIA AS INT) = '"+cValtoChar(val(xAgencia))+"' AND TRIM(A6_NUMCON) like '%"+SUBSTR(cValtoChar(val(xConta)),1,5)+"%')) "
    cQuery += " ORDER BY PRIOR"



	TCQuery cQuery NEW ALIAS (cAlias)

	if !(cAlias)->(Eof())
        
        //If Empty((cAlias)->A6_FILPROC)
            //xFil := Alltrm((cAlias)->A6_FILIAL)+"01"
        //ELse
            //xFil := (cAlias)->A6_FILPROC
        //EndIf
        
        xFil := (cAlias)->A6_FILIAL
    Endif

    (cAlias)->(DbCloseArea())

    If Empty(xFil)
        xFil := xFilial("ZX3")
    EndIf

Return xFil


Static Function fBuscConta(xBanco, xAgencia, xConta)
Local cConta        := xConta
Local cQuery		:= ""
Local cAlias		:= GetNextAlias()

    cQuery := "SELECT  TOP 1 A6_NUMCON, CASE WHEN (CAST(A6_AGENCIA AS INT) = '"+cValtoChar(val(xAgencia))+"' AND TRIM(A6_NUMCON) like '%"+cValtoChar(val(xConta))+"') THEN 1 ELSE 2 END PRIOR  "
	cQuery += "FROM "+RETSQLNAME("SA6")+" (NOLOCK) WHERE "
	cQuery += "D_E_L_E_T_ = '' AND A6_COD = '"+xBanco+"' AND "
    cQuery += "A6_BLOCKED <> '1' AND "
    //cQuery += "A6_FILPROC <> '' AND "
	cQuery += " ((CAST(A6_AGENCIA AS INT) = '"+cValtoChar(val(xAgencia))+"' AND TRIM(A6_NUMCON) like '%"+cValtoChar(val(xConta))+"') OR "
    cQuery += " (CAST(A6_AGENCIA AS INT) = '"+cValtoChar(val(xAgencia))+"' AND TRIM(A6_NUMCON) like '%"+SUBSTR(cValtoChar(val(xConta)),1,5)+"%')) "
    cQuery += " ORDER BY PRIOR"



	TCQuery cQuery NEW ALIAS (cAlias)

	if !(cAlias)->(Eof())
        cConta := (cAlias)->A6_NUMCON
    Endif

    (cAlias)->(DbCloseArea())

    If Empty(cConta)
        cConta := xConta
    EndIf

Return cConta


Static Function fBuscAgenc(xBanco, xAgencia, xConta)
Local cConta        := xConta
Local cQuery		:= ""
Local cAlias		:= GetNextAlias()

    cQuery := "SELECT  TOP 1 A6_AGENCIA, CASE WHEN (CAST(A6_AGENCIA AS INT) = '"+cValtoChar(val(xAgencia))+"' AND TRIM(A6_NUMCON) like '%"+cValtoChar(val(xConta))+"') THEN 1 ELSE 2 END PRIOR  "
	cQuery += "FROM "+RETSQLNAME("SA6")+" (NOLOCK) WHERE "
	cQuery += "D_E_L_E_T_ = '' AND A6_COD = '"+xBanco+"' AND "
    cQuery += "A6_BLOCKED <> '1' AND "
    //cQuery += "A6_FILPROC <> '' AND "
	cQuery += " ((CAST(A6_AGENCIA AS INT) = "+cValtoChar(val(xAgencia))+" AND TRIM(A6_NUMCON) like '%"+cValtoChar(val(xConta))+"') OR "
    cQuery += " (CAST(A6_AGENCIA AS INT) = "+cValtoChar(val(xAgencia))+" AND TRIM(A6_NUMCON) like '%"+SUBSTR(cValtoChar(val(xConta)),1,5)+"%')) "
    cQuery += " ORDER BY PRIOR"



	TCQuery cQuery NEW ALIAS (cAlias)

	if !(cAlias)->(Eof())
        cConta := (cAlias)->A6_AGENCIA
    Endif

    (cAlias)->(DbCloseArea())

    If Empty(cConta)
        cConta := xConta
    EndIf

Return cConta

