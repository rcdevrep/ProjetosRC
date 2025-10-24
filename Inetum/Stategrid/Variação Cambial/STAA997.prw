#INCLUDE "TOTVS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³STAA997  ºAutor  ³Vagner Almeida	     º Data ³  04/10/24   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para Vincular Contrato                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATE GRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function STAA997()

    Local aArea := GetArea()

    Local  oDlg
    Local  oGet1
    Local  oSay1
    Local  oTButOk
    //Local  oTButCanc
    Local  cGet1 := SPACE(TamSx3("CN9_NUMERO")[1])

    DEFINE MSDIALOG oDlg FROM 0,0 TO 100,200 TITLE "Vincular Contrato" PIXEL 

        oDlg:lEscClose := .F.

        oSay1 := tSay():New( 010, 020,{||"Número:"},oDlg,,,,,,.T.,,,100,20)
        oGet1 := TGet():New( 005, 009, { | u | If( PCount() == 0, cGet1, cGet1 := u ) },oDlg, ;
                             060, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGet1",,,,)
        oGet1:bValid    := {|| FValContra(cGet1)}
        oGet1:cF3       := 'CN9'

        oTButOk   := TButton():New( 030, 030, "Ok",      oDlg,{|| FAtuContra(cGet1, .T., oDlg)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
        //oTButCanc := TButton():New( 030, 055, "Cancelar",oDlg,{|| oDlg:End()                  }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   

    ACTIVATE MSDIALOG oDlg CENTERED
    
    RestArea(aArea)
Return

Static Function FValContra(cGet1)

    Local lRet  := .T.
    Local cUser := RetCodUsr()

    /*BeginSQL Alias 'CN9TEMP'

        SELECT CN9.CN9_NUMERO
             , CN9.CN9_SITUAC
          FROM %table:CN9% CN9
         WHERE CN9.%notDel%
           AND CN9.CN9_FILIAL = %xfilial:CN9% 
           AND CN9.CN9_NUMERO = %exp:cGet1% 
           AND CN9.CN9_SITUAC = %exp:'05'% 

    EndSQL
 
    If CN9TEMP->(EOF())
        MsgInfo("Contrato não está Vigente!", "Atenção")
        lRet := .F.
    EndIf

    CN9TEMP->(DBCloseArea())
 
    If lRet
 
        BeginSQL Alias 'CNNTEMP'

            SELECT CNN_CONTRA
            FROM %table:CNN% CNN
            WHERE CNN.%notDel%
               AND CNN_FILIAL   = %xfilial:CNN% 
               AND CNN_CONTRA   = %exp:cGet1% 
               AND CNN_USRCOD   = %exp:cUser% 

        EndSQL

        If CNNTEMP->(EOF())
            Aviso("Acesso","Usuário sem permissão para manipular este contrato.",{"OK"})
            lRet := .F.
        EndIf

        CNNTEMP->(DBCloseArea())

    EndIf*/

Return(lRet)

Static Function FAtuContra(cGet1, lAtu, oDlg)

    Local cChave    :=  ''
    Local cWhere    :=  "%E2_FORNECE = '" + SF1->F1_FORNECE + "' AND " +; 
                        " E2_LOJA    = '" + SF1->F1_LOJA    + "' AND " +;
                        " E2_NUM     = '" + SF1->F1_DOC     + "' %"
               
    If lAtu
		//RecLock("SF1", .F.)
        //SF1->F1_XCONTRA := cGet1
		//SF1->(MsUnlock())

        BeginSql Alias 'QRYSE2'

            SELECT E2_NUM
                 , E2_PREFIXO 
                 , E2_TIPO
                 , E2_PARCELA
                 , E2_FORNECE
                 , E2_LOJA
              FROM %table:SE2% SE2
             WHERE SE2.%notDel% 
               AND E2_FILIAL   = %xFilial:SE2%
               AND E2_TIPO     = %exp:'NF'%
               AND %Exp:cWhere%

        EndSql

        DbSelectArea('QRYSE2')
        QRYSE2->(DbGoTop())
    
        cChave := QRYSE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA)

        DBSelectArea("SE2")
        DBSetOrder(1)

        If SE2->( DBSeek( FWxFilial( "SE2" ) + cChave ) )
            RecLock("SE2",.F.)
                SE2->E2_MDCONTR := cGet1
            SE2->(MsUnLock("SE2"))
        EndIf

        QRYSE2->(DbCloseArea())

    EndIf

    oDlg:End()

Return()
